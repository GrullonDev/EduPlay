import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:edu_play/core/auth/independent_student_loader.dart';
import 'package:edu_play/features/auth/pages/email_verification_gate_page.dart';
import 'package:edu_play/features/child_pin/pages/child_pin_page.dart';
import 'package:edu_play/features/parents_dashboard/pages/parents_dashboard_page.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_page.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/features/teacher_dashboard/pages/teacher_dashboard_page.dart';
import 'package:edu_play/utils/child_portal_link.dart';

/// Listens to [FirebaseAuth.authStateChanges] and routes the user to the
/// correct screen without going through the login page when they already
/// have a valid (persisted) session.
///
/// Role resolution:
///   • Unauthenticated, returning child (saved PIN/shared link) → [StudentDashboardPage]
///   • Unauthenticated, first visit    → [ChildPinPage] (access screen)
///   • UID exists in `parents/{uid}`              → [ParentsDashboardPage]
///   • UID exists in `teachers/{uid}`              → [TeacherDashboardPage]
///   • UID exists in `independent_students/{uid}` → [IndependentStudentLoader]
///   • Unknown role                 → [StudentDashboardPage] (guest)
class AuthGate extends StatelessWidget {
  /// [auth]/[firestore] default to the app's singletons; tests inject
  /// [firebase_auth_mocks]/[fake_cloud_firestore] fakes instead.
  AuthGate({super.key, FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  /// Caches only successful role lookups, keyed by uid, so redundant
  /// `authStateChanges()` emissions for an already-resolved session (e.g. a
  /// token refresh) don't hit Firestore again — reducing how often the
  /// transient-error race below is even triggered. Errors and "no role" are
  /// never cached, so they're always re-checked.
  static final Map<String, String> _roleCache = {};

  @visibleForTesting
  static void resetCacheForTest() => _roleCache.clear();

  @visibleForTesting
  Future<String?> resolveRoleForTest(String uid) => _resolveRole(uid);

  static const _roleLookupTimeout = Duration(seconds: 8);

  Future<String?> _resolveRole(String uid) async {
    final cached = _roleCache[uid];
    if (cached != null) return cached;

    final parentDoc = await firestore
        .collection('parents')
        .doc(uid)
        .get()
        .timeout(_roleLookupTimeout);
    if (parentDoc.exists) {
      _roleCache[uid] = 'parent';
      return 'parent';
    }

    final teacherDoc = await firestore
        .collection('teachers')
        .doc(uid)
        .get()
        .timeout(_roleLookupTimeout);
    if (teacherDoc.exists) {
      _roleCache[uid] = 'teacher';
      return 'teacher';
    }

    final independentStudentDoc = await firestore
        .collection('independent_students')
        .doc(uid)
        .get()
        .timeout(_roleLookupTimeout);
    if (independentStudentDoc.exists) {
      _roleCache[uid] = 'independent_student';
      return 'independent_student';
    }

    return null;
  }

  /// Renders the destination for a *successfully resolved* role (or a
  /// genuine "no role" result). Shared by the happy path and by
  /// [_RoleResolutionRetry] once its retry succeeds.
  Widget _buildForRole(User user, String? role) {
    // Unknown role — sign out to avoid an infinite loop.
    if (role == null) {
      // Anonymous sign-in is used by the child portal. A child's anonymous
      // session persists across app restarts, so `user` is already non-null
      // here on every return visit — route them exactly as a fresh,
      // unauthenticated visitor would be (remembered PIN → dashboard,
      // otherwise the PIN entry screen) instead of a dead-end spinner.
      if (user.isAnonymous) return const _NoSessionEntry();
      Future.microtask(() => auth.signOut());
      return const StudentDashboardPage(username: null);
    }

    // Email not yet verified → show the hard gate.
    // Anonymous users (child kiosk) are always considered verified so
    // they are never blocked by this check.
    if (!user.isAnonymous && !(user.emailVerified)) {
      return EmailVerificationGatePage(role: role);
    }

    switch (role) {
      case 'teacher':
        return const TeacherDashboardPage();
      case 'parent':
        return const ParentsDashboardPage();
      case 'independent_student':
        return const IndependentStudentLoader();
      default:
        if (!user.isAnonymous) {
          Future.microtask(() => auth.signOut());
        }
        return const StudentDashboardPage(username: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Firebase can emit redundant events for the same signed-in user (e.g.
      // on token refresh); collapsing those avoids re-running role
      // resolution — and hitting the transient-error race — more than
      // necessary.
      stream: auth.authStateChanges().distinct(
            (prev, next) => prev?.uid == next?.uid,
          ),
      builder: (context, authSnap) {
        // Still waiting for Firebase to restore the session
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        final user = authSnap.data;

        // Not logged in → access screen, unless this is a returning child
        // (saved PIN or a parent-shared link), who should skip straight in.
        if (user == null) return const _NoSessionEntry();

        // Logged in → resolve role from Firestore
        return FutureBuilder<String?>(
          future: _resolveRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const _SplashLoader();
            }

            // A Firestore error (token-refresh race, network blip, cold
            // reconnect — all plausible while navigating) is NOT the same
            // as "authenticated user with no role". Treating it that way
            // used to trigger a real, silent FirebaseAuth.signOut() here —
            // retry instead.
            if (roleSnap.hasError) {
              return _RoleResolutionRetry(gate: this, user: user);
            }

            return _buildForRole(user, roleSnap.data);
          },
        );
      },
    );
  }
}

// ── Retries role resolution after a transient Firestore error ─────────────────

class _RoleResolutionRetry extends StatefulWidget {
  const _RoleResolutionRetry({required this.gate, required this.user});
  final AuthGate gate;
  final User user;

  @override
  State<_RoleResolutionRetry> createState() => _RoleResolutionRetryState();
}

class _RoleResolutionRetryState extends State<_RoleResolutionRetry> {
  static const _backoffs = [
    Duration(milliseconds: 800),
    Duration(milliseconds: 1600),
    Duration(milliseconds: 3200),
  ];

  late Future<String?> _future;

  @override
  void initState() {
    super.initState();
    _future = _retry();
  }

  Future<String?> _retry() async {
    Object? lastError;
    for (final backoff in _backoffs) {
      await Future.delayed(backoff);
      try {
        return await widget.gate._resolveRole(widget.user.uid);
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError!;
  }

  void _manualRetry() => setState(() => _future = _retry());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }
        if (snap.hasError) {
          return _RoleResolutionErrorScreen(onRetry: _manualRetry);
        }
        return widget.gate._buildForRole(widget.user, snap.data);
      },
    );
  }
}

class _RoleResolutionErrorScreen extends StatelessWidget {
  const _RoleResolutionErrorScreen({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: Color(0xFF1E1B6A)),
              const SizedBox(height: 16),
              const Text(
                'No pudimos verificar tu sesión.\nRevisa tu conexión e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF1E1B6A), fontSize: 15),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── No-session entry point ─────────────────────────────────────────────────────

/// Decides what an unauthenticated visitor sees first.
///
/// A returning child (one who already resolved a PIN before, or who arrived
/// via a parent-shared link) should never be forced to re-enter their PIN —
/// they skip straight into [StudentDashboardPage], which resolves their
/// identity itself. Everyone else lands on [ChildPinPage], the actual access
/// screen (enter PIN / register / play as guest).
class _NoSessionEntry extends StatelessWidget {
  const _NoSessionEntry();

  @override
  Widget build(BuildContext context) {
    // Synchronous check first: a parent-shared link embeds both the profile
    // and PIN directly in the URL fragment.
    if (childProfileFromUrl() != null && pinFromUrl() != null) {
      return const StudentDashboardPage(username: null);
    }

    return FutureBuilder<bool>(
      future: StudentSessionNavigationService.hasRememberedChildPin(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }
        if (snap.data == true) {
          return const StudentDashboardPage(username: null);
        }
        return const ChildPinPage();
      },
    );
  }
}

// ── Splash / loading screen ────────────────────────────────────────────────────

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F7FF),
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E1B6A),
          strokeWidth: 3,
        ),
      ),
    );
  }
}

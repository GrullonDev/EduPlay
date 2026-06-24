import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:edu_play/features/auth/pages/email_verification_gate_page.dart';
import 'package:edu_play/features/child_portal/pages/child_portal_page.dart';
import 'package:edu_play/features/parents_dashboard/pages/parents_dashboard_page.dart';
import 'package:edu_play/features/teacher_dashboard/pages/teacher_dashboard_layout.dart';

/// Listens to [FirebaseAuth.authStateChanges] and routes the user to the
/// correct screen without going through the login page when they already
/// have a valid (persisted) session.
///
/// Role resolution:
///   • Unauthenticated              → [ChildPortalPage] (guest, child-first UX)
///   • UID exists in `parents/{uid}`  → [ParentsDashboardPage]
///   • UID exists in `teachers/{uid}` → [TeacherDashboardLayout]
///   • Unknown role                 → [ChildPortalPage] (guest)
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static Future<String?> _resolveRole(String uid) async {
    final db = FirebaseFirestore.instance;

    final parentDoc = await db.collection('parents').doc(uid).get();
    if (parentDoc.exists) return 'parent';

    final teacherDoc = await db.collection('teachers').doc(uid).get();
    if (teacherDoc.exists) return 'teacher';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        // Still waiting for Firebase to restore the session
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _SplashLoader();
        }

        final user = authSnap.data;

        // Not logged in → child dashboard (guest mode, no PIN)
        if (user == null) return const ChildPortalPage();

        // Logged in → resolve role from Firestore
        return FutureBuilder<String?>(
          future: _resolveRole(user.uid),
          builder: (context, roleSnap) {
            if (roleSnap.connectionState == ConnectionState.waiting) {
              return const _SplashLoader();
            }

            final role = roleSnap.data;

            // Unknown role — sign out to avoid an infinite loop.
            if (role == null) {
              // Anonymous sign-in is used by the child portal — leave it alone.
              if (user.isAnonymous) return const _SplashLoader();
              Future.microtask(() => FirebaseAuth.instance.signOut());
              return const ChildPortalPage();
            }

            // Email not yet verified → show the hard gate.
            // Anonymous users (child kiosk) are always considered verified so
            // they are never blocked by this check.
            if (!user.isAnonymous && !(user.emailVerified)) {
              return EmailVerificationGatePage(role: role);
            }

            switch (role) {
              case 'teacher':
                return const TeacherDashboardLayout();
              case 'parent':
                return const ParentsDashboardPage();
              default:
                if (!user.isAnonymous) {
                  Future.microtask(() => FirebaseAuth.instance.signOut());
                }
                return const ChildPortalPage();
            }
          },
        );
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/utils/child_portal_link.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF8F7FF);

// ── Child Portal Page ─────────────────────────────────────────────────────────
//
// Accessible at /#/child-portal
//
// Entry modes:
//   1. With PIN (via route args or URL fragment query param):
//      Validates PIN → shows the child's profile + active practice sessions.
//   2. Without PIN (guest browse):
//      Shows a friendly "Ask your parent to create a profile" screen.

class ChildPortalPage extends StatefulWidget {
  const ChildPortalPage({super.key, this.pinFromArgs});

  /// PIN passed programmatically via Navigator arguments.
  final String? pinFromArgs;

  @override
  State<ChildPortalPage> createState() => _ChildPortalPageState();
}

class _ChildPortalPageState extends State<ChildPortalPage> {
  _PortalState _state = const _Loading();

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  Future<void> _resolve() async {
    // 1. Determine the PIN.
    final pin = widget.pinFromArgs ?? pinFromUrl();

    if (pin == null || pin.isEmpty) {
      if (mounted) setState(() => _state = const _Guest());
      return;
    }

    // 2. Fast path: profile data is embedded in the URL as a base64 `d=` param.
    //    No Firebase auth and no Firestore round-trip required — resolves instantly.
    final urlProfile = childProfileFromUrl();
    if (urlProfile != null) {
      final sessions = await _loadSessions(urlProfile.id);
      if (!mounted) return;
      setState(
          () => _state = _ProfileView(profile: urlProfile, sessions: sessions));
      return;
    }

    // 3. Fallback for links generated before the `d=` param was introduced:
    //    anonymous auth + Firestore global PIN index.
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance
            .signInAnonymously()
            .timeout(const Duration(seconds: 8));
      } catch (_) {
        if (mounted) setState(() => _state = const _Guest(hadPin: true));
        return;
      }
    }

    final profile = await ChildProfilesService.findByPinGlobal(pin);
    if (!mounted) return;

    if (profile == null) {
      setState(() => _state = const _Guest(hadPin: true));
      return;
    }

    final sessions = await _loadSessions(profile.id);
    if (!mounted) return;
    setState(() => _state = _ProfileView(profile: profile, sessions: sessions));
  }

  /// Loads active practice sessions for [childId].
  /// Fails silently (returns empty list) so a Firestore rules gap never
  /// prevents the child's profile from showing.
  Future<List<PracticeSession>> _loadSessions(String childId) async {
    try {
      return await PracticeSessionsService.getActiveSessionsByChildId(childId);
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_state) {
          _Loading() => const _LoadingView(),
          _Guest(hadPin: final hadPin) => _GuestView(hadPin: hadPin),
          _ProfileView(profile: final p, sessions: final s) =>
            _ChildProfileView(profile: p, sessions: s),
        },
      ),
    );
  }
}

// ── State types ───────────────────────────────────────────────────────────────

sealed class _PortalState {
  const _PortalState();
}

class _Loading extends _PortalState {
  const _Loading();
}

class _Guest extends _PortalState {
  const _Guest({this.hadPin = false});
  final bool hadPin;
}

class _ProfileView extends _PortalState {
  const _ProfileView({required this.profile, required this.sessions});
  final ChildProfile profile;
  final List<PracticeSession> sessions;
}

// ── Loading view ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2),
    );
  }
}

// ── Guest view ────────────────────────────────────────────────────────────────

class _GuestView extends StatelessWidget {
  const _GuestView({this.hadPin = false});
  final bool hadPin;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kNavy, _kNavyDark],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // Decorative circles
            const Positioned(
              top: -80,
              right: -80,
              child: _Circle(size: 260, opacity: 0.04),
            ),
            const Positioned(
              bottom: -100,
              left: -50,
              child: _Circle(size: 320, opacity: 0.04),
            ),
            const Positioned(
              top: 80,
              left: -100,
              child: _Circle(size: 200, opacity: 0.03),
            ),

            // Back button
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(
                        context, RouterPaths.childPin);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70, size: 20),
              ),
            ),

            // Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Planet / mascot icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Text('🚀', style: TextStyle(fontSize: 48)),
                        ),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        '¡Bienvenido a EduPlay!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        hadPin
                            ? 'Este enlace pertenece a otro dispositivo.\nPide a tu papá o mamá que lo abra en este mismo aparato.'
                            : '¿Listo para aprender jugando? 🎮\nPide a tu papá o mamá que cree un perfil para ti en EduPlay.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Fun game previews
                      const _GamePreviewRow(),

                      const SizedBox(height: 40),

                      // CTA — go to PIN page
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pushReplacementNamed(
                              context, RouterPaths.childPin),
                          icon: const Icon(Icons.lock_open_rounded, size: 18),
                          label: Text(
                            'Tengo un código PIN',
                            style: GoogleFonts.fredoka(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kCoral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // EduPlay footer brand
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'EduPlay · Aprende jugando',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GamePreviewRow extends StatelessWidget {
  const _GamePreviewRow();
  final _previews = const [
    (icon: '🔢', label: 'Matemáticas', color: Color(0xFF3498DB)),
    (icon: '📖', label: 'Palabras', color: Color(0xFF9B59B6)),
    (icon: '🌍', label: 'Ciencias', color: Color(0xFF27AE60)),
    (icon: '🎨', label: 'Arte', color: Color(0xFFE67E22)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _previews.map((p) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: p.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: p.color.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(p.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                p.label,
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Authenticated child profile view ─────────────────────────────────────────

class _ChildProfileView extends StatelessWidget {
  const _ChildProfileView({
    required this.profile,
    required this.sessions,
  });

  final ChildProfile profile;
  final List<PracticeSession> sessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header band ──────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_kNavy, Color(0xFF3A36A0)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: [
                  // Top row
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacementNamed(
                                context, RouterPaths.childPin);
                          }
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white70, size: 20),
                      ),
                      const Spacer(),
                      Text(
                        'EduPlay',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: profile.avatarColor.withValues(alpha: 0.25),
                      border: Border.all(
                        color: profile.avatarColor.withValues(alpha: 0.5),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        profile.name[0].toUpperCase(),
                        style: GoogleFonts.fredoka(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(
                    '¡Hola, ${profile.name}! 👋',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.levelLabel} · ${profile.focusSubject}',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Level progress bar
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Progreso de nivel',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.55),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${(profile.levelProgress * 100).toInt()}%',
                              style: GoogleFonts.fredoka(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: profile.levelProgress,
                            minHeight: 8,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              profile.avatarColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Session list ─────────────────────────────────────────────────────
        Expanded(
          child: sessions.isEmpty
              ? _EmptySessionsView(childName: profile.name)
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Sesiones activas',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toca una sesión para comenzar a jugar',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...sessions.map(
                      (s) => _SessionCard(
                        session: s,
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouterPaths.practiceKiosk,
                          arguments: s,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView({required this.childName});
  final String childName;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(
              '¡Todo al día, $childName!',
              textAlign: TextAlign.center,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tu papá o mamá todavía no ha creado\nuna sesión de práctica para ti.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Session card ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final PracticeSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = session.completedCount;
    final total = session.totalCount;
    final progress = session.progressFraction;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kLavender,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_esports_rounded,
                        color: _kNavy, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesión de práctica',
                        style: GoogleFonts.fredoka(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      Text(
                        '$completed de $total juegos completados',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kCoral,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¡Jugar!',
                    style: GoogleFonts.fredoka(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: _kLavender,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1 ? const Color(0xFF27AE60) : _kCoral,
                ),
              ),
            ),
            if (progress == 1) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF27AE60), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '¡Sesión completada! 🎉',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF27AE60),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

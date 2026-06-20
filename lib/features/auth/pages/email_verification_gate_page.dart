import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/pages/parents_dashboard_page.dart';
import 'package:edu_play/features/teacher_dashboard/pages/teacher_dashboard_layout.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

/// Full-screen gate shown to newly registered users whose email is not yet
/// verified.  The widget:
///   • Displays the user's email address so they know which inbox to check.
///   • Polls [FirebaseAuth.currentUser.reload()] every 10 seconds and
///     automatically navigates to the appropriate dashboard once
///     [User.emailVerified] becomes true.
///   • Offers a "Reenviar" button with a 60-second cooldown.
///   • Provides a "Cerrar sesión" escape hatch that returns to the landing page.
class EmailVerificationGatePage extends StatefulWidget {
  const EmailVerificationGatePage({super.key, required this.role});

  /// The resolved role — either 'parent' or 'teacher'.  Used to navigate to
  /// the correct dashboard once verification succeeds.
  final String role;

  @override
  State<EmailVerificationGatePage> createState() =>
      _EmailVerificationGatePageState();
}

class _EmailVerificationGatePageState extends State<EmailVerificationGatePage> {
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  bool _resendCooldown = false;
  bool _resending = false;
  bool _justSent = false;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    // Poll every 10 s — fast enough to feel responsive without hammering Auth.
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkVerified();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    final auth = FirebaseAuth.instance;
    await auth.currentUser?.reload();
    if (!mounted) return;
    if (auth.currentUser?.emailVerified == true) {
      _advance();
    }
  }

  void _advance() {
    if (!mounted) return;
    final destination = widget.role == 'teacher'
        ? const TeacherDashboardLayout()
        : const ParentsDashboardPage();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => destination),
      (route) => false,
    );
  }

  Future<void> _resend() async {
    if (_resendCooldown || _resending) return;
    setState(() => _resending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (!mounted) return;
      setState(() {
        _resending = false;
        _justSent = true;
        _resendCooldown = true;
        _cooldownSeconds = 60;
      });
      // Hide "¡Enviado!" after 3 s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _justSent = false);
      });
      // Tick the cooldown counter every second
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() => _cooldownSeconds--);
        if (_cooldownSeconds <= 0) {
          t.cancel();
          setState(() => _resendCooldown = false);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _resending = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // AuthGate will react to authStateChanges and return to MainPage.
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo / icon ────────────────────────────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: _kNavy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _kNavy.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // ── Heading ────────────────────────────────────────────────
                Text(
                  'Verifica tu correo',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    height: 1.15,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Body copy ──────────────────────────────────────────────
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: const Color(0xFF555580),
                        height: 1.6),
                    children: [
                      const TextSpan(
                          text: 'Te enviamos un enlace de verificación a\n'),
                      TextSpan(
                        text: email,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      const TextSpan(
                          text:
                              '\n\nHaz clic en el enlace del correo para activar tu cuenta. '
                              'Si no lo ves, revisa tu carpeta de spam o correo no deseado.'),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Card ───────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _kNavy.withValues(alpha: 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Status row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.hourglass_top_rounded,
                                size: 18, color: Color(0xFF856404)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verificación pendiente',
                                  style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF856404)),
                                ),
                                Text(
                                  'Esta página se actualizará automáticamente',
                                  style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: const Color(0xFFAAAAAA)),
                                ),
                              ],
                            ),
                          ),
                          // Pulse indicator
                          _PulsingDot(),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Resend button
                      if (_justSent)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF27AE60), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '¡Correo enviado! Revisa tu bandeja.',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF27AE60),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Text(
                              '¿No recibiste el correo?',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _resendCooldown || _resending
                                    ? null
                                    : _resend,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _kNavy,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      _kNavy.withValues(alpha: 0.4),
                                  disabledForegroundColor: Colors.white70,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: _resending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : Text(
                                        _resendCooldown
                                            ? 'Reenviar en ${_cooldownSeconds}s'
                                            : 'Reenviar correo de verificación',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Check manually button ──────────────────────────────────
                OutlinedButton.icon(
                  onPressed: _checkVerified,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Ya verifiqué — revisar ahora',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kNavy,
                    side: const BorderSide(color: _kNavy, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Sign out ───────────────────────────────────────────────
                TextButton(
                  onPressed: _signOut,
                  child: Text(
                    'Cerrar sesión',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[500],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── EduPlay branding footer ────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: _kCoral,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'EduPlay',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pulsing dot indicator ─────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFFF39C12),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF39C12).withValues(alpha: 0.4),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

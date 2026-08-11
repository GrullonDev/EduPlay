import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Non-blocking email verification banner.
///
/// Shown at the top of the dashboard when the signed-in user has not yet
/// verified their email address. The banner:
///  • Shows the email address so the user knows which inbox to check.
///  • Includes a "Reenviar" (resend) button with a 60-second cooldown.
///  • Polls Firebase every 30 seconds via `user.reload()` and
///    automatically disappears once `emailVerified` becomes true.
///  • Tells the user to check their spam folder to help deliverability.
class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({super.key});

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  bool _verified = false;
  bool _resendCooldown = false;
  bool _resending = false;
  bool _justSent = false;
  final AuthRepository _authRepository = sl<AuthRepository>();
  Timer? _pollTimer;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    _checkVerified();
    // Poll Firestore every 30 s so the banner dismisses without a page reload.
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
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
    if (_authRepository.getCurrentUserUid() == null) return;
    await _authRepository.reloadCurrentUser();
    if (!mounted) return;
    setState(() => _verified = _authRepository.isCurrentUserEmailVerified());
  }

  Future<void> _resend() async {
    if (_resendCooldown || _resending) return;
    setState(() => _resending = true);
    try {
      await _authRepository.sendCurrentUserEmailVerification();
      if (!mounted) return;
      setState(() {
        _resendCooldown = true;
        _resending = false;
        _justSent = true;
      });
      // Hide the "¡Enviado!" confirmation after 3 s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _justSent = false);
      });
      // 60-second cooldown before allowing another send
      _cooldownTimer = Timer(const Duration(seconds: 60), () {
        if (mounted) setState(() => _resendCooldown = false);
      });
    } catch (_) {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _authRepository.getCurrentUserEmail();
    if (_verified ||
        email == null ||
        _authRepository.isCurrentUserEmailVerified()) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF3CD),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.mark_email_unread_rounded,
              size: 20, color: Color(0xFF856404)),
          const SizedBox(width: 12),
          Expanded(
            child: _justSent
                ? Text(
                    '¡Correo enviado! Revisa tu bandeja de entrada (y la carpeta de spam) en $email.',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: const Color(0xFF856404),
                        fontWeight: FontWeight.w600),
                  )
                : RichText(
                    text: TextSpan(
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: const Color(0xFF856404)),
                      children: [
                        const TextSpan(
                            text: 'Verifica tu correo electrónico — '),
                        TextSpan(
                          text: email,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                            text:
                                '. Revisa tu bandeja de entrada y la carpeta de spam.'),
                      ],
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: _resendCooldown || _resending ? null : _resend,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF664D03),
              backgroundColor: const Color(0xFFFFE69C),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: _resending
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF664D03)),
                  )
                : Text(
                    _resendCooldown ? 'Enviado ✓' : 'Reenviar',
                    style: GoogleFonts.nunito(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
          ),
        ],
      ),
    );
  }
}

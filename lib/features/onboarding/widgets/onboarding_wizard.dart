import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);

// ── Onboarding Wizard ─────────────────────────────────────────────────────────
//
// Shown once to new parents after email verification.
// Triggered from ParentsDashboardPage when Firestore parents/{uid}.onboardingComplete != true.
//
// Usage:
//   OnboardingWizard.showIfNeeded(context);

class OnboardingWizard extends StatefulWidget {
  const OnboardingWizard({super.key});

  /// Checks Firestore and shows the wizard if the parent hasn't completed onboarding.
  static Future<void> showIfNeeded(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(uid)
          .get();
      final complete = doc.data()?['onboardingComplete'] as bool? ?? false;
      if (complete) return;
    } catch (_) {
      return;
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const OnboardingWizard(),
    );
  }

  static Future<void> _markComplete() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('parents')
        .doc(uid)
        .update({'onboardingComplete': true});
  }

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  int _step = 0;

  static const _steps = [
    _StepData(
      emoji: '🚀',
      title: '¡Bienvenido a EduPlay!',
      subtitle:
          'La plataforma de aprendizaje gamificado para que tu familia aprenda jugando.',
      bullets: [
        'Juegos educativos para niños de 5 a 14 años',
        'Sesiones de práctica personalizadas',
        'Seguimiento del progreso en tiempo real',
        'Totalmente en español',
      ],
      ctaLabel: 'Empecemos',
      accentColor: _kNavy,
    ),
    _StepData(
      emoji: '👤',
      title: 'Completa tu perfil',
      subtitle:
          'Añade tu nombre para que podamos personalizar tu experiencia y las comunicaciones que te enviemos.',
      bullets: [
        'Tarda menos de 1 minuto',
        'Puedes cambiarlo en cualquier momento desde Configuración',
      ],
      ctaLabel: 'Ir a mi perfil',
      accentColor: Color(0xFF9B59B6),
    ),
    _StepData(
      emoji: '🧒',
      title: 'Crea el primer perfil de tu hijo/a',
      subtitle:
          'Cada niño tendrá su propio perfil con su PIN de acceso, nivel y progreso independiente.',
      bullets: [
        'El plan gratuito incluye 1 perfil de niño',
        'El PIN de 4 dígitos permite un acceso seguro sin contraseña',
        'Puedes crear el perfil ahora o más tarde',
      ],
      ctaLabel: 'Crear perfil de niño',
      accentColor: Color(0xFF27AE60),
    ),
    _StepData(
      emoji: '🎮',
      title: '¡Listo para jugar!',
      subtitle:
          'Crea una sesión de práctica asignando juegos a tu hijo/a. Ellos accederán con su PIN.',
      bullets: [
        'Selecciona los juegos que quieres que practiquen',
        'Comparte el enlace de sesión con tu hijo/a',
        'Sigue su progreso en tiempo real desde el dashboard',
      ],
      ctaLabel: 'Crear primera sesión',
      accentColor: _kCoral,
    ),
  ];

  Future<void> _onCta(BuildContext ctx) async {
    switch (_step) {
      case 0:
        setState(() => _step = 1);
      case 1:
        Navigator.of(ctx).pop();
        await OnboardingWizard._markComplete();
        Navigator.of(ctx).pushNamed(RouterPaths.settings);
      case 2:
        Navigator.of(ctx).pop();
        await OnboardingWizard._markComplete();
        Navigator.of(ctx).pushNamed(RouterPaths.createExplorer);
      case 3:
        await OnboardingWizard._markComplete();
        Navigator.of(ctx).pop();
        Navigator.of(ctx).pushNamed(RouterPaths.createSession);
    }
  }

  Future<void> _skip(BuildContext ctx) async {
    await OnboardingWizard._markComplete();
    if (ctx.mounted) Navigator.of(ctx).pop();
  }

  @override
  Widget build(BuildContext context) {
    final data = _steps[_step];

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _kNavy.withValues(alpha: 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    // Step dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_steps.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: i == _step ? 24 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _step
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(data.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      data.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.subtitle,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.82),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Bullets
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _kLavender,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: data.bullets.map((b) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    size: 16, color: data.accentColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    b,
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      color: _kNavy,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _onCta(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: data.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          data.ctaLabel,
                          style: GoogleFonts.fredoka(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Skip / back row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_step > 0)
                          TextButton(
                            onPressed: () =>
                                setState(() => _step = _step - 1),
                            child: Text(
                              '← Atrás',
                              style: GoogleFonts.nunito(
                                  fontSize: 13, color: Colors.grey[500]),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        TextButton(
                          onPressed: () => _skip(context),
                          child: Text(
                            'Omitir tutorial',
                            style: GoogleFonts.nunito(
                                fontSize: 13, color: Colors.grey[400]),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step data ─────────────────────────────────────────────────────────────────

class _StepData {
  const _StepData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.ctaLabel,
    required this.accentColor,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String ctaLabel;
  final Color accentColor;
}

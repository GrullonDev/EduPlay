import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

const _kNavy = Color(0xFF24235B);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);
const _kIconLavender = Color(0xFFE2E1F4);

/// Home screen profile picker – matches the Stitch design:
/// lavender dotted background, three role cards, help link at the bottom.
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    return Stack(
      children: [
        // ── Dotted background ──────────────────────────────────────────────
        Positioned.fill(child: _DottedBackground()),
        // ── Content ───────────────────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _Header(desktop: desktop),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: desktop ? 80 : 20,
                    vertical: desktop ? 56 : 40,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '¿Quién va a aprender hoy?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fredoka(
                          fontSize: desktop ? 44 : 30,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      SizedBox(height: desktop ? 52 : 36),
                      desktop
                          ? IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: _kidsCard(context)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _parentsCard(context)),
                                  const SizedBox(width: 20),
                                  Expanded(child: _teachersCard(context)),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                _kidsCard(context),
                                const SizedBox(height: 16),
                                _parentsCard(context),
                                const SizedBox(height: 16),
                                _teachersCard(context),
                              ],
                            ),
                      SizedBox(height: desktop ? 44 : 32),
                      const _HelpLink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kidsCard(BuildContext context) => _RoleCard(
        iconWidget: const Icon(
          Icons.sentiment_satisfied_alt_rounded,
          size: 40,
          color: Colors.white,
        ),
        iconBg: Colors.white.withValues(alpha: 0.28),
        iconShape: BoxShape.circle,
        cardBg: _kCoral,
        title: 'Niños',
        titleColor: Colors.white,
        subtitle: '¡Entra a jugar y aprender!',
        subtitleColor: Colors.white.withValues(alpha: 0.88),
        button: _PillButton(
          label: 'Jugar Ahora',
          icon: Icons.arrow_forward_rounded,
          onPressed: () => Navigator.pushNamed(context, RouterPaths.childPin),
          style: _PillButtonStyle.whiteOnCoral,
        ),
      );

  Widget _parentsCard(BuildContext context) => _RoleCard(
        iconWidget: const Icon(
          Icons.family_restroom_rounded,
          size: 28,
          color: Colors.white,
        ),
        iconBg: _kNavy,
        iconShape: BoxShape.rectangle,
        iconRadius: 14,
        cardBg: Colors.white,
        title: 'Padres',
        titleColor: _kNavy,
        subtitle: 'Sigue el progreso de tus hijos',
        subtitleColor: const Color(0xFF888888),
        button: _PillButton(
          label: 'Panel Familiar',
          icon: Icons.login_rounded,
          onPressed: () => Navigator.pushNamed(
            context,
            RouterPaths.login,
            arguments: 'parent',
          ),
          style: _PillButtonStyle.filledNavy,
        ),
      );

  Widget _teachersCard(BuildContext context) => _RoleCard(
        iconWidget: Icon(
          Icons.school_rounded,
          size: 28,
          color: _kNavy.withValues(alpha: 0.7),
        ),
        iconBg: _kIconLavender,
        iconShape: BoxShape.rectangle,
        iconRadius: 14,
        cardBg: Colors.white,
        title: 'Profesores',
        titleColor: _kNavy,
        subtitle: 'Gestiona tus clases y recursos',
        subtitleColor: const Color(0xFF888888),
        button: _PillButton(
          label: 'Herramientas Docentes',
          icon: Icons.login_rounded,
          onPressed: () => Navigator.pushNamed(
            context,
            RouterPaths.login,
            arguments: 'teacher',
          ),
          style: _PillButtonStyle.outlinedNavy,
        ),
      );
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 80 : 20,
        vertical: 20,
      ),
      child: Row(
        children: [
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _kNavy,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dotted background ─────────────────────────────────────────────────────────

class _DottedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotPainter(),
      child: Container(color: _kLavender),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dotColor = Color(0xFFCAC9E8);
    const spacing = 28.0;
    const radius = 1.8;
    final paint = Paint()..color = dotColor;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) => false;
}

// ── Role card ─────────────────────────────────────────────────────────────────

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.iconWidget,
    required this.iconBg,
    required this.iconShape,
    required this.cardBg,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.button,
    this.iconRadius,
  });

  final Widget iconWidget;
  final Color iconBg;
  final BoxShape iconShape;
  final double? iconRadius;
  final Color cardBg;
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = cardBg == _kCoral;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? null
            : Border.all(color: const Color(0xFFDDDDEE), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isHighlighted ? 0.10 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconContainer(),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: subtitleColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          button,
        ],
      ),
    );
  }

  Widget _iconContainer() {
    final decoration = iconShape == BoxShape.circle
        ? BoxDecoration(color: iconBg, shape: BoxShape.circle)
        : BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(iconRadius ?? 14),
          );

    return Container(
      width: 72,
      height: 72,
      decoration: decoration,
      child: Center(child: iconWidget),
    );
  }
}

// ── Pill button ───────────────────────────────────────────────────────────────

enum _PillButtonStyle { whiteOnCoral, filledNavy, outlinedNavy }

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.style,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final _PillButtonStyle style;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    );
    final textStyle = GoogleFonts.nunito(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    switch (style) {
      case _PillButtonStyle.whiteOnCoral:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _kCoral,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: shape,
            textStyle: textStyle,
          ),
        );
      case _PillButtonStyle.filledNavy:
        return ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kNavy,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            shape: shape,
            textStyle: textStyle,
          ),
        );
      case _PillButtonStyle.outlinedNavy:
        return OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(
            foregroundColor: _kNavy,
            side: const BorderSide(color: _kNavy, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: shape,
            textStyle: textStyle,
          ),
        );
    }
  }
}

// ── Help link ─────────────────────────────────────────────────────────────────

class _HelpLink extends StatelessWidget {
  const _HelpLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.help_outline_rounded,
            color: Color(0xFFAAAAAA), size: 18),
        const SizedBox(width: 8),
        Text(
          '¿Necesitas ayuda para empezar?',
          style: GoogleFonts.nunito(
            color: const Color(0xFF888888),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

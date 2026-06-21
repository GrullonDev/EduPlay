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
                      SizedBox(height: desktop ? 60 : 48),

                      // ── Pricing section ───────────────────────────────────
                      const _PricingSection(),

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

// ── Pricing section ───────────────────────────────────────────────────────────

class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);
    return Column(
      children: [
        Text(
          'Planes y Precios',
          style: GoogleFonts.fredoka(
            fontSize: desktop ? 34 : 26,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Empieza gratis. Mejora cuando estés listo.',
          style:
              GoogleFonts.nunito(fontSize: 15, color: const Color(0xFF888888)),
        ),
        const SizedBox(height: 32),

        // Plan cards
        desktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _PlanCard.free(context)),
                  const SizedBox(width: 20),
                  Expanded(child: _PlanCard.pro(context)),
                ],
              )
            : Column(
                children: [
                  _PlanCard.free(context),
                  const SizedBox(height: 16),
                  _PlanCard.pro(context),
                ],
              ),

        const SizedBox(height: 40),

        // Features table
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
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
              Text(
                'Comparativa de características',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 20),
              const _FeatureRow('Perfiles de niño', '2', 'Ilimitados'),
              const _FeatureRow(
                  'Sesiones de práctica / mes', '6', 'Ilimitadas'),
              const _FeatureRow('Juegos educativos', '10', 'Ilimitados'),
              const _FeatureRow('Consulta de puntuaciones', '✓', '✓'),
              const _FeatureRow('Descarga de informes PDF', '—', '✓'),
              const _FeatureRow('Portal de niño', '✓', '✓'),
              const _FeatureRow('Soporte', 'Comunidad', 'Prioritario'),
              const _FeatureRow('Asistencia con IA', '—', '✓'),
            ],
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    required this.cta,
    required this.highlighted,
    required this.onTap,
  });

  factory _PlanCard.free(BuildContext context) => _PlanCard(
        name: 'Gratuito',
        price: '\$0',
        period: 'Para siempre',
        description: 'Perfecto para empezar a explorar EduPlay en familia.',
        features: const [
          '2 perfiles de niño',
          '6 sesiones por mes',
          '10 juegos educativos',
          'Portal de niño',
          'Consulta de puntuaciones (padres e hijos)',
        ],
        cta: 'Registrarse gratis',
        highlighted: false,
        onTap: () => Navigator.pushNamed(context, RouterPaths.registerParents),
      );

  factory _PlanCard.pro(BuildContext context) => _PlanCard(
        name: 'Pro',
        price: '\$8.99',
        period: 'por mes',
        description:
            'Para familias que quieren sacar el máximo provecho de EduPlay.',
        features: const [
          'Niños ilimitados',
          'Sesiones ilimitadas',
          'Juegos educativos ilimitados',
          'Descarga de informes en PDF',
          'Soporte prioritario',
          'Asistencia con inteligencia artificial',
        ],
        cta: '¡Empezar con Pro!',
        highlighted: true,
        onTap: () => Navigator.pushNamed(context, RouterPaths.registerParents),
      );

  final String name;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final String cta;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: highlighted ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: highlighted
            ? null
            : Border.all(color: const Color(0xFFE0DEFF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: highlighted
                ? _kNavy.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: highlighted ? 24 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: highlighted
                  ? _kCoral.withValues(alpha: 0.15)
                  : const Color(0xFFEEEDF8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              highlighted ? '⭐ MÁS POPULAR' : name.toUpperCase(),
              style: GoogleFonts.fredoka(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: highlighted ? _kCoral : _kNavy,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.fredoka(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: highlighted ? Colors.white : _kNavy,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  period,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: highlighted
                        ? Colors.white.withValues(alpha: 0.65)
                        : Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.75)
                  : Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),

          // Features
          for (final f in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: highlighted ? _kCoral : const Color(0xFF27AE60),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: highlighted
                            ? Colors.white.withValues(alpha: 0.85)
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: highlighted ? _kCoral : _kNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                cta,
                style: GoogleFonts.fredoka(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.feature, this.free, this.pro);
  final String feature;
  final String free;
  final String pro;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              feature,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: _kNavy, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                free,
                style:
                    GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                pro,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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

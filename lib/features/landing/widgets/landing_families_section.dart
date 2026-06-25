import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// "Para Familias y Docentes" section: highlights the parents dashboard and
/// the tools available to follow each child's progress.
class LandingFamiliesSection extends StatelessWidget {
  const LandingFamiliesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);
    final showTeacherCopy = ReleaseFlags.teacherExperienceEnabled;

    final textColumn = Column(
      crossAxisAlignment:
          desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            showTeacherCopy ? 'Para Familias y Docentes' : 'Para Familias',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: AppTheme.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Acompaña el progreso de cada niño',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: desktop ? 36 : 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'La Zona de Padres reúne en un solo lugar todo lo que necesitas '
          '${showTeacherCopy ? 'para ayudar a tus hijos o estudiantes a avanzar.' : 'para ayudar a tus hijos a avanzar.'}',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        const _FeatureRow(
          icon: Icons.insights_rounded,
          title: 'Seguimiento de progreso',
          description:
              'Consulta partidas jugadas, puntuaciones y el juego favorito '
              'de cada niño.',
        ),
        const _FeatureRow(
          icon: Icons.star_rounded,
          title: 'Álbum de logros',
          description: 'Cada victoria desbloquea estampas coleccionables que '
              'celebran su esfuerzo.',
        ),
        const _FeatureRow(
          icon: Icons.family_restroom_rounded,
          title: 'Múltiples perfiles',
          description: 'Gestiona el progreso de varios niños desde un mismo '
              'panel.',
        ),
        const SizedBox(height: 12),
        Align(
          alignment: desktop ? Alignment.centerLeft : Alignment.center,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, RouterPaths.login),
            icon: const Icon(Icons.shield_rounded),
            label: const Text('Ir a la Zona de Padres'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              side: const BorderSide(color: AppTheme.primaryColor, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );

    return LandingSection(
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(flex: 5, child: _DashboardMockup()),
                const SizedBox(width: 64),
                Expanded(flex: 6, child: textColumn),
              ],
            )
          : Column(
              children: [
                const _DashboardMockup(),
                const SizedBox(height: 40),
                textColumn,
              ],
            ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative mockup of the "Zona de Padres" dashboard, showing a child's
/// progress per game as a small bar chart.
class _DashboardMockup extends StatelessWidget {
  const _DashboardMockup();

  static const _bars = [
    (label: 'Mate', value: 0.85, color: Color(0xFF4CAF50)),
    (label: 'Inglés', value: 0.6, color: Color(0xFFF44336)),
    (label: 'Lógica', value: 0.9, color: Color(0xFFFFC107)),
    (label: 'Arte', value: 0.45, color: Color(0xFFE91E63)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEDE7F6),
                child: Icon(Icons.face_rounded, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zona de Padres',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Progreso de Sofía · 9 años',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (final bar in _bars)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 28,
                        height: 100 * bar.value,
                        decoration: BoxDecoration(
                          color: bar.color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bar.label,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _MockupStat(
                    icon: Icons.emoji_events_rounded,
                    value: '12',
                    label: 'Estampas'),
              ),
              Expanded(
                child: _MockupStat(
                    icon: Icons.bolt_rounded, value: '34', label: 'Partidas'),
              ),
              Expanded(
                child: _MockupStat(
                    icon: Icons.star_rounded, value: '320', label: 'Puntos'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockupStat extends StatelessWidget {
  const _MockupStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.secondaryColor, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

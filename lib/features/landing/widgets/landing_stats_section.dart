import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/features/landing/models/landing_game_info.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Highlight bar with quick facts about EduPlay's catalog and community.
class LandingStatsSection extends StatelessWidget {
  const LandingStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    final items = [
      _StatItem(
        icon: Icons.videogame_asset_rounded,
        value: '${landingGames.length}',
        label: 'Juegos educativos para edades de 7 a 17 años',
      ),
      const _StatItem(
        icon: Icons.school_rounded,
        value: '100%',
        label: 'Aprendizaje a través de retos, historias y desafíos',
      ),
      const _StatItem(
        icon: Icons.groups_rounded,
        value: 'Comunidad',
        label: 'Familias y docentes acompañando el progreso de cada niño',
      ),
    ];

    return LandingSection(
      color: AppTheme.primaryColor,
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 64 : 20,
        vertical: desktop ? 40 : 32,
      ),
      child: desktop
          ? Row(
              children: items
                  .map((item) => Expanded(child: item))
                  .toList(growable: false),
            )
          : Column(
              children: [
                for (final item in items) ...[
                  item,
                  if (item != items.last) const SizedBox(height: 24),
                ],
              ],
            ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 12),
        Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

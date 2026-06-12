import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Misión del Día" banner. Shows the next active challenge assigned by the
/// teacher (if any), or a generic invitation to keep playing otherwise.
class MissionBanner extends StatelessWidget {
  const MissionBanner({super.key, required this.mission, this.onPlayAnyGame});

  /// A row from `challenges` (local SQLite), or null if there are none.
  final Map<String, dynamic>? mission;

  /// Called when the CTA is tapped and there is no assigned mission.
  final VoidCallback? onPlayAnyGame;

  @override
  Widget build(BuildContext context) {
    final subjectKey = mission?['subject_key'] as String?;
    final subject = subjectKey != null ? subjectByKey(subjectKey) : null;
    final title = mission?['title'] as String? ?? '¡Sigue Jugando!';
    final description = mission != null
        ? 'Tu profesor te asignó este reto. ¡Complétalo para ganar puntos extra!'
        : 'Aún no tienes retos asignados. Elige un juego y sigue sumando puntos.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xFF8E85FF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              subject?.icon ?? Icons.flag_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Misión del Día',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              final route = subjectGameRoutes[subject?.key];
              if (route != null) {
                Navigator.pushNamed(context, route);
              } else {
                onPlayAnyGame?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryColor,
            ),
            child: const Text('¡Vamos!'),
          ),
        ],
      ),
    );
  }
}

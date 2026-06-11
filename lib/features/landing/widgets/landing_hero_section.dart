import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/models/landing_game_info.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Hero / above-the-fold section: headline, value proposition and CTAs.
class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({super.key, required this.onSeeGames});

  final VoidCallback onSeeGames;

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    final textColumn = Column(
      crossAxisAlignment:
          desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        _Badge(),
        const SizedBox(height: 20),
        Text(
          'Aprende jugando.\nEnseña con resultados.',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.fredoka(
            fontSize: desktop ? 52 : 36,
            fontWeight: FontWeight.bold,
            height: 1.15,
            color: AppTheme.textColor,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'EduPlay combina pedagogía y mecánicas de juego para que niños de '
          '7 a 17 años practiquen matemáticas, idiomas, ciencias, arte y más. '
          'Mientras ellos juegan, padres y docentes siguen su progreso en '
          'tiempo real.',
          textAlign: desktop ? TextAlign.start : TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 18,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, RouterPaths.guestEntry),
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('¡Jugar ya!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.brown[800],
              ),
            ),
            OutlinedButton(
              onPressed: onSeeGames,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('Ver juegos'),
            ),
          ],
        ),
      ],
    );

    return LandingSection(
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 6, child: textColumn),
                const SizedBox(width: 64),
                const Expanded(flex: 5, child: _HeroIllustration()),
              ],
            )
          : Column(
              children: [
                textColumn,
                const SizedBox(height: 48),
                const _HeroIllustration(),
              ],
            ),
    );
  }
}

class _Badge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded,
              size: 18, color: AppTheme.secondaryColor),
          const SizedBox(width: 8),
          Text(
            '+${landingGames.length} juegos para aprender jugando',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700,
              color: AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative "tablet" mockup showing a preview of the Aventura Matemática
/// game, used as the hero illustration.
class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration();

  @override
  Widget build(BuildContext context) {
    final preview = landingGames.take(4).toList();

    return Center(
      child: SizedBox(
        height: 320,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Background blob
            Container(
              width: 320,
              height: 280,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
            // Tablet card
            Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 320,
                height: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
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
                        const Icon(Icons.calculate_rounded,
                            color: Color(0xFF4CAF50)),
                        const SizedBox(width: 8),
                        Text(
                          'Aventura Matemática',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 2),
                              Text('120',
                                  style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: preview
                            .map((game) => Container(
                                  decoration: BoxDecoration(
                                    color: game.color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(game.icon,
                                      color: game.color, size: 22),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating sticker
            Positioned(
              top: -10,
              right: 10,
              child: Transform.rotate(
                angle: 0.15,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

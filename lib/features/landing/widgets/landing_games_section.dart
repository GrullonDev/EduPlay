import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/models/landing_game_info.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Showcase grid of the EduPlay game catalog.
class LandingGamesSection extends StatelessWidget {
  const LandingGamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);
    final s = ScreenSize.of(context);
    final crossAxisCount = gridCols(s, mobile: 1, tablet: 2, desktop: 3);

    return LandingSection(
      child: Column(
        children: [
          Text(
            'Un mundo de juegos por explorar',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: desktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${landingGames.length} juegos diseñados para cubrir las áreas '
            'clave del aprendizaje, para edades de 7 a 17 años.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: landingGames.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: desktop ? 1.6 : 1.4,
            ),
            itemBuilder: (context, index) {
              final game = landingGames[index];
              return _GameCard(game: game);
            },
          ),
          const SizedBox(height: 40),
          OutlinedButton.icon(
            onPressed: () =>
                Navigator.pushNamed(context, RouterPaths.guestEntry),
            icon: const Icon(Icons.sports_esports_rounded),
            label: const Text('Ver todos los juegos'),
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
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

  final LandingGameInfo game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: game.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(game.icon, color: game.color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            game.title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              game.description,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

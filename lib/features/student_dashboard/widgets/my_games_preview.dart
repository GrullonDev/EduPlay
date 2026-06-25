import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Mis Juegos" preview card: shows the first couple of games with a
/// shortcut to open the full "Mis Juegos" tab.
class MyGamesPreview extends StatelessWidget {
  const MyGamesPreview({
    super.key,
    required this.games,
    required this.onSeeAll,
  });

  final List<Game> games;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final preview = games.take(2).toList();

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              const Icon(Icons.videogame_asset_rounded,
                  color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mis Juegos',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('Ver todos'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < preview.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _GamePreviewTile(game: preview[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _GamePreviewTile extends StatelessWidget {
  const _GamePreviewTile({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: game.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              game.color.withValues(alpha: 0.12),
              game.color.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: game.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(game.icon, color: game.color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              game.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppTheme.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

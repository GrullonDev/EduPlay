import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';

/// "Mi Álbum de Estampas" preview card with a button to open the full album.
class StickerAlbumCard extends StatelessWidget {
  const StickerAlbumCard({
    super.key,
    required this.unlockedCount,
    required this.totalCount,
    required this.onOpenAlbum,
  });

  final int unlockedCount;
  final int totalCount;
  final VoidCallback onOpenAlbum;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : unlockedCount / totalCount;

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
              const Icon(Icons.star_rounded, color: Color(0xFFFFC107)),
              const SizedBox(width: 10),
              Text(
                'Mi Álbum de Estampas',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Has desbloqueado $unlockedCount de $totalCount estampas',
            style: GoogleFonts.nunito(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFFFC107).withValues(alpha: 0.15),
              color: const Color(0xFFFFC107),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onOpenAlbum,
              icon: const Icon(Icons.collections_bookmark_rounded),
              label: const Text('Abrir Álbum'),
            ),
          ),
        ],
      ),
    );
  }
}

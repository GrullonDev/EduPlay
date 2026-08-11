import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFFFD700);

class StudentHomeGamesSection extends StatelessWidget {
  const StudentHomeGamesSection({
    super.key,
    required this.games,
    required this.s,
    required this.onSubjectSelect,
  });
  final List<Game> games;
  final ScreenSize s;
  final ValueChanged<GameSubject> onSubjectSelect;

  static const _gradients = [
    [Color(0xFF1565C0), Color(0xFF1E88E5)],
    [Color(0xFF00695C), Color(0xFF26A69A)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
  ];

  @override
  Widget build(BuildContext context) {
    final featured = games.isNotEmpty ? games[0] : null;
    final secondary = games.length > 1 ? games[1] : null;

    const smallExtras = [
      (
        icon: Icons.history_edu_rounded,
        label: 'Historia',
        name: 'Crónicas de Egipto',
        sub: 'Explora las pirámides',
        subject: GameSubject.history,
      ),
      (
        icon: Icons.psychology_rounded,
        label: 'Lógica',
        name: 'Lógica & Puzzles',
        sub: 'Entrena tu cerebro',
        subject: GameSubject.logic,
      ),
      (
        icon: Icons.language_rounded,
        label: 'Idiomas',
        name: 'Idiomas Pro',
        sub: 'Nuevas palabras hoy',
        subject: GameSubject.languages,
      ),
    ];

    return Column(
      children: [
        // ── Featured row ──────────────────────────────────────────────
        if (s.isMobile) ...[
          // Mobile: stacked
          if (featured != null) _FeaturedGameCard(game: featured, s: s),
          if (featured != null && secondary != null) const SizedBox(height: 12),
          if (secondary != null) _SecondaryGameCard(game: secondary, s: s),
        ] else ...[
          // Tablet / Desktop: side by side
          SizedBox(
            height: 165,
            child: Row(
              children: [
                if (featured != null)
                  Expanded(
                    flex: 3,
                    child: _FeaturedGameCard(game: featured, s: s),
                  ),
                if (featured != null && secondary != null)
                  const SizedBox(width: 14),
                if (secondary != null)
                  Expanded(
                    flex: 2,
                    child: _SecondaryGameCard(game: secondary, s: s),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // ── Small cards ───────────────────────────────────────────────
        // Mobile: 1 col wrap, Tablet: 3 col row, Desktop: 3 col row
        if (s.isMobile)
          LayoutBuilder(
            builder: (context, wc) => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: smallExtras
                  .asMap()
                  .entries
                  .map((e) => SizedBox(
                        width: (wc.maxWidth - 10) / 2,
                        child: _SmallGameCard(
                          icon: e.value.icon,
                          name: e.value.name,
                          sub: e.value.sub,
                          gradient: _gradients[e.key % _gradients.length],
                          onTap: () => onSubjectSelect(e.value.subject),
                        ),
                      ))
                  .toList(),
            ),
          )
        else
          Row(
            children: smallExtras.asMap().entries.map((e) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      right: e.key < smallExtras.length - 1 ? 12 : 0),
                  child: _SmallGameCard(
                    icon: e.value.icon,
                    name: e.value.name,
                    sub: e.value.sub,
                    gradient: _gradients[e.key % _gradients.length],
                    onTap: () => onSubjectSelect(e.value.subject),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _FeaturedGameCard extends StatelessWidget {
  const _FeaturedGameCard({required this.game, required this.s});
  final Game game;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: game.onTap,
      child: Container(
        height: s.isMobile ? 120 : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Art
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: s.isMobile ? 100 : 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [game.color, game.color.withValues(alpha: 0.6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(game.icon,
                          size: 60,
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    Center(
                      child: Icon(game.icon, size: 36, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: game.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'MATEMÁTICAS',
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: game.color,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      game.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.fredoka(
                        fontSize: s.isMobile ? 14 : 16,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    if (!s.isXs) ...[
                      const SizedBox(height: 4),
                      Text(
                        '¡Derrota a los monstruos con el poder de los números!',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey[500],
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: game.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kNavy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '¡Jugar!',
                        style: GoogleFonts.fredoka(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryGameCard extends StatelessWidget {
  const _SecondaryGameCard({required this.game, required this.s});
  final Game game;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: game.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: game.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'CIENCIA',
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: game.color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                game.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.fredoka(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(game.icon, color: game.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(0xFF4CAF50),
                              child: Text('A',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 2),
                            const CircleAvatar(
                              radius: 8,
                              backgroundColor: Color(0xFF2196F3),
                              child: Text('B',
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 4),
                            Text('+4',
                                style: GoogleFonts.nunito(
                                    fontSize: 10, color: Colors.grey[500])),
                          ],
                        ),
                        Text('Amigos jugando',
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallGameCard extends StatelessWidget {
  const _SmallGameCard({
    required this.icon,
    required this.name,
    required this.sub,
    required this.gradient,
    required this.onTap,
  });
  final IconData icon;
  final String name;
  final String sub;
  final List<Color> gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient[0].withValues(alpha: 0.12),
                    gradient[1].withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: gradient[0], size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sticker album section ─────────────────────────────────────────────────────

class StudentStickerAlbumPreview extends StatelessWidget {
  const StudentStickerAlbumPreview({
    super.key,
    required this.unlockedIds,
    required this.total,
    required this.s,
  });
  final List<String> unlockedIds;
  final int total;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    // Show more stickers on wider screens
    final count = s.when(mobile: 4, tablet: 5, desktop: 6);
    final stickers = allStickers.take(count).toList();
    final unlockedSet = unlockedIds.toSet();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFFFAB00), size: 18),
              const SizedBox(width: 8),
              Text(
                'Mi Álbum de Estampas',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StickerAlbumPage(unlockedIds: unlockedIds),
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Abrir Álbum',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Has coleccionado ${unlockedIds.length} de $total estampas',
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: stickers.map((st) {
              final unlocked = unlockedSet.contains(st.id);
              final isLast = st == stickers.last;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 8),
                  child: _StickerCell(sticker: st, unlocked: unlocked),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StickerCell extends StatelessWidget {
  const _StickerCell({required this.sticker, required this.unlocked});
  final Sticker sticker;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: unlocked
              ? sticker.color.withValues(alpha: 0.1)
              : const Color(0xFFF3F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: unlocked
                ? sticker.color.withValues(alpha: 0.3)
                : const Color(0xFFE0E0E0),
            width: 1.5,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: sticker.color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (unlocked)
              Icon(sticker.icon, color: sticker.color, size: 26)
            else
              Icon(Icons.lock_rounded, color: Colors.grey[300], size: 20),
            if (sticker.id == 'dino' && unlocked)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: _kGold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'LEGENDARIO',
                      style: GoogleFonts.nunito(
                        fontSize: 6,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5A3E00),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Amigos en línea ───────────────────────────────────────────────────────────

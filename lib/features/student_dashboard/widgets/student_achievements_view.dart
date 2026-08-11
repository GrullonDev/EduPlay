import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';

const _kGold = Color(0xFFFFD700);

class StudentAchievementsView extends StatelessWidget {
  const StudentAchievementsView({super.key, required this.s});
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();
    final progress = bloc.totalStickerCount == 0
        ? 0.0
        : bloc.unlockedStickerCount / bloc.totalStickerCount;
    final complete = bloc.unlockedStickerCount >= bloc.totalStickerCount;
    final teaser = complete
        ? '¡Álbum completo! Eres un verdadero Explorador 🎉'
        : '¡Sube a nivel ${bloc.level + 1} para tu próxima estampa!';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    s.isMobile ? 20 : 28, 20, s.isMobile ? 20 : 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '🏆 Mis Logros',
                          style: GoogleFonts.fredoka(
                            fontSize: s.isMobile ? 22 : 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🦊 Nivel ${bloc.level}',
                            style: GoogleFonts.fredoka(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${bloc.unlockedStickerCount} de ${bloc.totalStickerCount} sellos desbloqueados',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _AnimatedMilestoneBar(
                      progress: progress,
                      milestoneCount: bloc.totalStickerCount,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      teaser,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: StickerAlbumGrid(
              unlockedIds: bloc.unlockedStickerIds,
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Progress bar that animates in from 0 on first build, with a small
/// milestone dot overlaid per sticker (filled once that sticker is
/// unlocked).
class _AnimatedMilestoneBar extends StatelessWidget {
  const _AnimatedMilestoneBar({
    required this.progress,
    required this.milestoneCount,
  });

  final double progress;
  final int milestoneCount;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              color: _kGold,
            ),
          ),
          if (milestoneCount > 1)
            Row(
              children: List.generate(milestoneCount, (i) {
                final reached = i / (milestoneCount - 1) <= value + 0.001;
                return Expanded(
                  child: Align(
                    alignment:
                        i == 0 ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: reached
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

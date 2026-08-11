import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/widgets/leaderboard_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/my_challenges_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_home_games_section.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_home_overview_widgets.dart';
import 'package:edu_play/features/student_dashboard/widgets/student_practice_sections.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);

class StudentHomeView extends StatelessWidget {
  const StudentHomeView({
    super.key,
    required this.bloc,
    required this.s,
    required this.onTabChange,
    required this.onSubjectSelect,
  });
  final StudentDashboardBloc bloc;
  final ScreenSize s;
  final ValueChanged<int> onTabChange;
  final ValueChanged<GameSubject> onSubjectSelect;

  double get _hPad => s.when(mobile: 16, tablet: 20, desktop: 28);

  @override
  Widget build(BuildContext context) {
    final games = context.watch<MenuProvider>().games;

    return RefreshIndicator(
      color: _kNavy,
      onRefresh: bloc.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(_hPad, 20, _hPad, 32),
        children: [
          // Mission banner
          StudentMissionBanner(
            mission: bloc.missionOfTheDay,
            onPlay: () => onTabChange(1),
            s: s,
          ),

          SizedBox(height: s.isMobile ? 16 : 20),

          // Stat cards
          StudentStatCardsRow(
            streak: bloc.streak,
            level: bloc.level,
            xpIntoLevel: bloc.xpIntoLevel,
            xpProgress: bloc.xpProgress,
            activeChallenges: bloc.activeChallenges.length,
            s: s,
          ),

          if (bloc.childProfile != null) ...[
            SizedBox(height: s.isMobile ? 24 : 28),
            StudentNeedsPracticeSection(
              recommendations: bloc.recommendations,
              weakestSubject: bloc.weakestSubject,
              s: s,
            ),
            SizedBox(height: s.isMobile ? 24 : 28),
            StudentPracticeSessionsSection(childId: bloc.childProfile!.id),
          ],

          SizedBox(height: s.isMobile ? 24 : 28),

          // Mis Juegos header
          Row(
            children: [
              _SectionTitle(
                'Mis Juegos',
                fontSize: s.isMobile ? 18 : 20,
              ),
              const Spacer(),
              _TextLink(
                label: 'Ver todos',
                onTap: () => onTabChange(1),
              ),
            ],
          ),
          SizedBox(height: s.isMobile ? 12 : 14),
          StudentHomeGamesSection(
            games: games,
            s: s,
            onSubjectSelect: onSubjectSelect,
          ),

          SizedBox(height: s.isMobile ? 24 : 28),

          // Sticker album
          StudentStickerAlbumPreview(
            unlockedIds: bloc.unlockedStickerIds,
            total: bloc.totalStickerCount,
            s: s,
          ),

          SizedBox(height: s.isMobile ? 24 : 28),

          // Bottom row: leaderboard + amigos
          if (s.isDesktop || s.isTablet)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LeaderboardCard(
                      entries: bloc.leaderboard,
                      myStudentId: bloc.myStudentId,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _StudentFriendsCard(
                      challenges: bloc.challenges,
                      onComplete: bloc.completeChallenge,
                    ),
                  ),
                ],
              ),
            )
          else ...[
            LeaderboardCard(
              entries: bloc.leaderboard,
              myStudentId: bloc.myStudentId,
            ),
            const SizedBox(height: 16),
            _StudentFriendsCard(
              challenges: bloc.challenges,
              onComplete: bloc.completeChallenge,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Needs practice (parent-assigned games / weakest subject) ──────────────────

class _StudentFriendsCard extends StatelessWidget {
  const _StudentFriendsCard({
    required this.challenges,
    required this.onComplete,
  });
  final List<Map<String, dynamic>> challenges;
  final ValueChanged<String> onComplete;

  static const _friends = [
    (name: 'Oliver', initial: 'O', color: Color(0xFF43A047)),
    (name: 'Emma', initial: 'E', color: Color(0xFF1E88E5)),
    (name: 'Lucas', initial: 'L', color: Color(0xFFE53935)),
  ];

  @override
  Widget build(BuildContext context) {
    // The friends/social system isn't built yet (same flag that hides the
    // "Amigos"/"Tienda" sidebar tabs) — showing fabricated friends and a
    // fake "Luna te envió un reto" message here would be misleading, so
    // this falls back to an honest "próximamente" placeholder. Real
    // teacher-assigned challenges are unaffected and still show below.
    if (!ReleaseFlags.studentExtraTabsEnabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🎮', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      'Amigos en Línea',
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded,
                        size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Muy pronto podrás jugar y retar a tus amigos aquí.',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (challenges.isNotEmpty) ...[
            const SizedBox(height: 12),
            MyChallengesCard(
              challenges: challenges.take(2).toList(),
              onComplete: onComplete,
            ),
          ],
        ],
      );
    }

    final pending = challenges.isNotEmpty
        ? challenges.firstWhere(
            (c) => c['status'] == 'active',
            orElse: () => {},
          )
        : <String, dynamic>{};

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎮', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                'Amigos en Línea',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Avatars — use Wrap so they reflow on small screens
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ..._friends.map((f) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: f.color,
                        child: Text(
                          f.initial,
                          style: GoogleFonts.fredoka(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        f.name,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  )),
              // Add button
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agregar amigos próximamente.'),
                    duration: Duration(seconds: 2),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                      ),
                      child: Icon(Icons.add, color: Colors.grey[400], size: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Añadir',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Challenge notification
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEEDF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pending.isNotEmpty
                        ? '¡Luna te ha enviado un reto de ${pending['title'] ?? 'Matemáticas'}!'
                        : '¡Luna te ha enviado un reto de Matemáticas!',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (challenges.isNotEmpty) ...[
            const SizedBox(height: 12),
            MyChallengesCard(
              challenges: challenges.take(2).toList(),
              onComplete: onComplete,
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GAMES HUB TAB — embeds the full filterable catalog (see
// lib/features/games_catalog/widgets/catalog_filter_content.dart), ported
// from the former standalone GamesCatalogPage/_GamesCatalogPageState.
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.fontSize = 20});
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: _kNavy,
        ),
      );
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.grey[500],
            decoration: TextDecoration.underline,
            decorationColor: Colors.grey[500],
          ),
        ),
      );
}

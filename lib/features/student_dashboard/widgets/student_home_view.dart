// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/friends/models/friend_request.dart';
import 'package:edu_play/features/friends/services/friends_service.dart';
import 'package:edu_play/features/friends/widgets/add_friend_dialog.dart';
import 'package:edu_play/features/friends/widgets/friend_avatar.dart';
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
const _kCoral = Color(0xFFE53935);

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
            streakAtRisk: bloc.isStreakAtRisk,
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
                      bloc: bloc,
                      onComplete: bloc.completeChallenge,
                      onViewAll: () => onTabChange(3),
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
              bloc: bloc,
              onComplete: bloc.completeChallenge,
              onViewAll: () => onTabChange(3),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentFriendsCard extends StatelessWidget {
  const _StudentFriendsCard({
    required this.bloc,
    required this.onComplete,
    required this.onViewAll,
  });
  final StudentDashboardBloc bloc;
  final ValueChanged<String> onComplete;
  final VoidCallback onViewAll;

  List<Map<String, dynamic>> get challenges => bloc.challenges;

  @override
  Widget build(BuildContext context) {
    if (!ReleaseFlags.friendsEnabled) return const SizedBox.shrink();

    final identity = bloc.friendIdentity;

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
              Expanded(
                child: Text(
                  'Amigos en Línea',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onViewAll,
                child: Text(
                  'Ver todos',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kCoral,
                  ),
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
              if (identity != null)
                StreamBuilder<List<FriendRequestModel>>(
                  stream: FriendsService.watchFriends(identity),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final friends =
                        snapshot.data ?? const <FriendRequestModel>[];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: friends.take(4).map((r) {
                        final other = r.other(identity.key);
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FriendAvatar(name: other.name, radius: 20),
                              const SizedBox(height: 4),
                              Text(
                                other.name,
                                style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              // Add button
              GestureDetector(
                onTap: () async {
                  if (identity == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Entra con tu PIN para agregar amigos.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  await showDialog<bool>(
                    context: context,
                    builder: (_) => AddFriendDialog(identity: identity),
                  );
                },
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

          // Pending-challenge notification — only shown when there's a real
          // active challenge to report (no fabricated "friend sent you a
          // challenge" copy when there isn't one).
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 14),
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
                      '¡Tienes un reto pendiente: ${pending['title'] ?? 'nuevo reto'}!',
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
          ],

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

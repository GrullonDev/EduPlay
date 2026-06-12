import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/menu/widgets/menu_buttons.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/widgets/leaderboard_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/mission_banner.dart';
import 'package:edu_play/features/student_dashboard/widgets/my_challenges_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/my_games_preview.dart';
import 'package:edu_play/features/student_dashboard/widgets/stat_cards.dart';
import 'package:edu_play/features/student_dashboard/widgets/sticker_album_card.dart';
import 'package:edu_play/shared/widgets/dashboard_shell.dart';
import 'package:edu_play/shared/widgets/placeholder_section.dart';
import 'package:edu_play/utils/app_theme.dart';

const _navItems = [
  DashboardNavItem(icon: Icons.dashboard_rounded, label: 'Panel de Control'),
  DashboardNavItem(
      icon: Icons.videogame_asset_rounded, label: 'Mis Juegos'),
  DashboardNavItem(icon: Icons.emoji_events_rounded, label: 'Logros'),
  DashboardNavItem(icon: Icons.people_alt_rounded, label: 'Amigos'),
  DashboardNavItem(icon: Icons.storefront_rounded, label: 'Tienda'),
];

class StudentDashboardLayout extends StatefulWidget {
  const StudentDashboardLayout({super.key});

  @override
  State<StudentDashboardLayout> createState() =>
      _StudentDashboardLayoutState();
}

class _StudentDashboardLayoutState extends State<StudentDashboardLayout> {
  int _selectedIndex = 0;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();

    Widget body;
    if (bloc.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedIndex) {
        case 1:
          body = _MyGamesView(fontSize: context.read<MenuProvider>().getFontSize(context));
          break;
        case 2:
          body = const Padding(
            padding: EdgeInsets.all(16),
            child: StickerAlbumGrid(padding: EdgeInsets.zero),
          );
          break;
        case 3:
          body = const PlaceholderSection(
            icon: Icons.people_alt_rounded,
            title: 'Amigos',
            message:
                'Pronto podrás ver a tus amigos en línea y jugar juntos.',
          );
          break;
        case 4:
          body = const PlaceholderSection(
            icon: Icons.storefront_rounded,
            title: 'Tienda',
            message:
                'Pronto podrás canjear tus puntos por premios increíbles.',
          );
          break;
        default:
          body = _OverviewView(bloc: bloc, onSelectTab: _selectTab);
      }
    }

    return DashboardShell(
      title: 'EduPlay',
      headerSubtitle: '¡Hola, ${bloc.displayName}!',
      items: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: _selectTab,
      body: body,
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.bloc, required this.onSelectTab});

  final StudentDashboardBloc bloc;
  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final games = context.watch<MenuProvider>().games;
    final desktop = MediaQuery.of(context).size.width >= 900;

    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '¡Hola, ${bloc.displayName}!',
            style: GoogleFonts.fredoka(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aquí está tu progreso de hoy',
            style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 15),
          ),
          const SizedBox(height: 20),
          MissionBanner(
            mission: bloc.missionOfTheDay,
            onPlayAnyGame: () => onSelectTab(1),
          ),
          const SizedBox(height: 20),
          StatCardsRow(
            streak: bloc.streak,
            level: bloc.level,
            xpIntoLevel: bloc.xpIntoLevel,
            xpProgress: bloc.xpProgress,
            activeChallenges: bloc.activeChallenges.length,
          ),
          const SizedBox(height: 20),
          if (desktop)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        MyGamesPreview(
                          games: games,
                          onSeeAll: () => onSelectTab(1),
                        ),
                        const SizedBox(height: 20),
                        StickerAlbumCard(
                          unlockedCount: bloc.unlockedStickerCount,
                          totalCount: bloc.totalStickerCount,
                          onOpenAlbum: () => onSelectTab(2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        LeaderboardCard(
                          entries: bloc.leaderboard,
                          myStudentId: bloc.myStudentId,
                        ),
                        const SizedBox(height: 20),
                        MyChallengesCard(
                          challenges: bloc.challenges,
                          onComplete: bloc.completeChallenge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else ...[
            MyGamesPreview(
              games: games,
              onSeeAll: () => onSelectTab(1),
            ),
            const SizedBox(height: 20),
            LeaderboardCard(
              entries: bloc.leaderboard,
              myStudentId: bloc.myStudentId,
            ),
            const SizedBox(height: 20),
            StickerAlbumCard(
              unlockedCount: bloc.unlockedStickerCount,
              totalCount: bloc.totalStickerCount,
              onOpenAlbum: () => onSelectTab(2),
            ),
            const SizedBox(height: 20),
            MyChallengesCard(
              challenges: bloc.challenges,
              onComplete: bloc.completeChallenge,
            ),
          ],
        ],
      ),
    );
  }
}

class _MyGamesView extends StatelessWidget {
  const _MyGamesView({required this.fontSize});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mis Juegos',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Elige tu próxima aventura:',
            style: GoogleFonts.nunito(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Expanded(child: MenuButtons(fontSize: fontSize)),
        ],
      ),
    );
  }
}

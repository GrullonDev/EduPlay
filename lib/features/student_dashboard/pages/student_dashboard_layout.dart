import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/games_catalog/pages/games_catalog_page.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
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
          body = const _MyGamesView();
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
      headerSubtitle: '¡Bienvenido!',
      items: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: _selectTab,
      body: body,
      footer: _StudentFooter(
        name: bloc.displayName,
        level: bloc.level,
        xpProgress: bloc.xpProgress,
        xpIntoLevel: bloc.xpIntoLevel,
      ),
    );
  }
}

class _StudentFooter extends StatelessWidget {
  const _StudentFooter({
    required this.name,
    required this.level,
    required this.xpProgress,
    required this.xpIntoLevel,
  });

  final String name;
  final int level;
  final double xpProgress;
  final int xpIntoLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.15),
            AppTheme.secondaryColor.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'E',
                  style: GoogleFonts.fredoka(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.textColor,
                      ),
                    ),
                    Text(
                      'Nivel $level Explorador',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$xpIntoLevel XP hacia el siguiente nivel',
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
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
  const _MyGamesView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final cols = isDesktop ? 3 : 2;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header row
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Juegos',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
                Text(
                  'Elige tu próxima aventura',
                  style: GoogleFonts.nunito(
                      color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GamesCatalogPage()),
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: Text(
                'Ver catálogo',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: BorderSide(
                    color: AppTheme.primaryColor.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Quick-access grid of recent games from catalog
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.78,
          ),
          itemCount: allCatalogGames.length > 6 ? 6 : allCatalogGames.length,
          itemBuilder: (_, i) => _MiniGameCard(game: allCatalogGames[i]),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const GamesCatalogPage()),
            ),
            icon: const Icon(Icons.explore_rounded, size: 18),
            label: Text(
              'Explorar todos los juegos',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  const _MiniGameCard({required this.game});

  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: game.gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        game.icon,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: game.subjectColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      game.subjectLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1B6A),
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: game.xpProgress,
                    minHeight: 4,
                    backgroundColor: const Color(0xFFF3F4F6),
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, game.route),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E1B6A),
                      side: BorderSide(color: Colors.grey.shade200),
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding:
                          const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Jugar',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

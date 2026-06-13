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

// ── Gaming hub ("Mis Juegos" tab) ─────────────────────────────────────────────

class _MyGamesView extends StatelessWidget {
  const _MyGamesView();

  // Simulated "recently played" — first 3 games
  static final _recent = allCatalogGames.take(3).toList();
  // "Recommended" — next 3
  static final _recommended = allCatalogGames.skip(3).take(3).toList();
  // "New" — rest
  static final _newGames = allCatalogGames.skip(6).toList();

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    void openCatalog() => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamesCatalogPage()),
        );

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── Personalised banner ────────────────────────────────────────
        _GamesBanner(name: bloc.displayName, level: bloc.level, onOpenCatalog: openCatalog),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Continue playing ───────────────────────────────────
              _HubSectionHeader(
                title: 'Continuar jugando',
                subtitle: 'Retoma donde lo dejaste',
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 116,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _RecentGameChip(game: _recent[i]),
                ),
              ),

              const SizedBox(height: 28),

              // ── Recommended ────────────────────────────────────────
              _HubSectionHeader(
                title: 'Recomendado para ti',
                subtitle: 'Basado en tu nivel ${bloc.level} · Explorador',
                action: _HubAction(label: 'Ver catálogo', onTap: openCatalog),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 3 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
                itemCount: _recommended.length,
                itemBuilder: (_, i) => _HubGameCard(game: _recommended[i]),
              ),

              const SizedBox(height: 28),

              // ── New arrivals ───────────────────────────────────────
              _HubSectionHeader(
                title: 'Nuevas aventuras',
                subtitle: '¡Acaban de llegar al universo EduPlay!',
              ),
              const SizedBox(height: 14),
              ..._newGames.map((g) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HubListTile(game: g),
                  )),

              const SizedBox(height: 28),

              // ── Full catalog CTA ───────────────────────────────────
              _CatalogCTABanner(onTap: openCatalog),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Personalised banner at top of Mis Juegos ──────────────────────────────────

class _GamesBanner extends StatelessWidget {
  const _GamesBanner({
    required this.name,
    required this.level,
    required this.onOpenCatalog,
  });

  final String name;
  final int level;
  final VoidCallback onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B6A), Color(0xFF2D2A82), Color(0xFF3D3AA0)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: _DecorCircle(size: 160, opacity: 0.06),
          ),
          Positioned(
            right: 60,
            bottom: -20,
            child: _DecorCircle(size: 100, opacity: 0.08),
          ),
          Positioned(
            left: -20,
            bottom: -10,
            child: _DecorCircle(size: 80, opacity: 0.05),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, ${name.split(' ').first}! 🎮',
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nivel $level Explorador · Tu aventura continúa',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.72),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: onOpenCatalog,
                        icon: const Icon(Icons.explore_rounded, size: 16),
                        label: Text(
                          'Ver catálogo completo',
                          style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0392B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.rocket_launch_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorCircle extends StatelessWidget {
  const _DecorCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: opacity),
        ),
      );
}

// ── Section header ─────────────────────────────────────────────────────────────

class _HubAction {
  const _HubAction({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
}

class _HubSectionHeader extends StatelessWidget {
  const _HubSectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final _HubAction? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E1B6A),
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.nunito(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        if (action != null)
          GestureDetector(
            onTap: action!.onTap,
            child: Row(
              children: [
                Text(
                  action!.label,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1B6A),
                    decoration: TextDecoration.underline,
                    decorationColor: const Color(0xFF1E1B6A),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: Color(0xFF1E1B6A)),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Recent game horizontal chip ───────────────────────────────────────────────

class _RecentGameChip extends StatelessWidget {
  const _RecentGameChip({required this.game});
  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, game.route),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: game.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: game.gradientColors.last.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative icon (background)
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(game.icon,
                  size: 64, color: Colors.white.withValues(alpha: 0.15)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    game.subjectLabel,
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  game.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: game.xpProgress,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
                    color: const Color(0xFFFFD700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hub game card (grid) ──────────────────────────────────────────────────────

class _HubGameCard extends StatelessWidget {
  const _HubGameCard({required this.game});
  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Art area
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient bg
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: game.gradientColors,
                      ),
                    ),
                  ),
                  // Geometric art
                  CustomPaint(painter: _GameArtPainter(game.gradientColors)),
                  // Central icon
                  Center(
                    child: Icon(game.icon,
                        size: 52,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  // Subject badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: game.subjectColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        game.subjectLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Level pill bottom-left
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Nivel ${game.level}',
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Info area
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E1B6A),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined,
                        size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(
                      game.ageLabel,
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // XP bar + %
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: game.xpProgress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(game.xpProgress * 100).toInt()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, game.route),
                    icon: const Icon(Icons.play_arrow_rounded, size: 16),
                    label: Text(
                      'Jugar',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1B6A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

// ── Hub list tile (new arrivals) ───────────────────────────────────────────────

class _HubListTile extends StatelessWidget {
  const _HubListTile({required this.game});
  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: game.gradientColors,
                      ),
                    ),
                  ),
                  CustomPaint(
                      painter: _GameArtPainter(game.gradientColors)),
                  Center(
                    child: Icon(game.icon,
                        size: 28,
                        color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        game.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E1B6A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lv ${game.level}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1E1B6A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  game.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                      fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            game.subjectColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.subjectLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: game.subjectColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people_alt_outlined,
                        size: 11, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Text(
                      game.ageLabel,
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, game.route),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1B6A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Jugar',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full catalog CTA banner ───────────────────────────────────────────────────

class _CatalogCTABanner extends StatelessWidget {
  const _CatalogCTABanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFC0392B), Color(0xFFE74C3C)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(Icons.grid_view_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.08)),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Descubre más aventuras!',
                        style: GoogleFonts.fredoka(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Explora +${allCatalogGames.length} juegos educativos en el catálogo completo',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ver todo →',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFC0392B),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Game art CustomPainter (decorative geometric shapes) ──────────────────────

class _GameArtPainter extends CustomPainter {
  const _GameArtPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final light = Colors.white.withValues(alpha: 0.06);
    final paint = Paint()..color = light;

    // Large circle top-right
    canvas.drawCircle(
      Offset(size.width * 1.1, size.height * -0.1),
      size.width * 0.7,
      paint,
    );
    // Medium circle bottom-left
    canvas.drawCircle(
      Offset(size.width * -0.15, size.height * 1.1),
      size.width * 0.55,
      paint,
    );
    // Small accent circle
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.72),
      size.width * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.05),
    );
    // Diagonal stripe
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = size.width * 0.3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 1.2),
      Offset(size.width * 1.2, 0),
      stripePaint,
    );
  }

  @override
  bool shouldRepaint(_GameArtPainter old) => false;
}

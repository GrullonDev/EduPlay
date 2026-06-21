import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/games_catalog/pages/games_catalog_page.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/widgets/leaderboard_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/my_challenges_card.dart';
import 'package:edu_play/shared/widgets/placeholder_section.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────

const _kNavy    = Color(0xFF1E1B6A);
const _kNavyMid = Color(0xFF2D2A82);
const _kCoral   = Color(0xFFE53935);
const _kGold    = Color(0xFFFFD700);
const _kBg      = Color(0xFFF3F5F9);

// ─────────────────────────────────────────────────────────────────────────────
// Root layout
// ─────────────────────────────────────────────────────────────────────────────

class StudentDashboardLayout extends StatefulWidget {
  const StudentDashboardLayout({super.key});

  @override
  State<StudentDashboardLayout> createState() => _StudentDashboardLayoutState();
}

class _StudentDashboardLayoutState extends State<StudentDashboardLayout> {
  int _tab = 0;

  Widget _buildContent(StudentDashboardBloc bloc, ScreenSize s) {
    switch (_tab) {
      case 1:
        return _GamesHubView(bloc: bloc, s: s);
      case 2:
        return _AchievementsView(s: s);
      case 3:
        return const PlaceholderSection(
          icon: Icons.people_alt_rounded,
          title: 'Amigos',
          message: 'Pronto podrás ver a tus amigos en línea y jugar juntos.',
        );
      case 4:
        return const PlaceholderSection(
          icon: Icons.storefront_rounded,
          title: 'Tienda',
          message: 'Pronto podrás canjear tus XP por premios increíbles.',
        );
      default:
        return _HomeView(
          bloc: bloc,
          s: s,
          onTabChange: (t) => setState(() => _tab = t),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final s = ScreenSize.fromConstraints(constraints);

        if (bloc.isLoading) {
          return const Scaffold(
            backgroundColor: _kBg,
            body: Center(
              child: CircularProgressIndicator(color: _kNavy, strokeWidth: 2.5),
            ),
          );
        }

        final content = _buildContent(bloc, s);

        // ── Desktop: top nav + persistent sidebar ──────────────────────
        if (s.isDesktop) {
          return Scaffold(
            backgroundColor: _kBg,
            body: Column(
              children: [
                _TopNavBar(bloc: bloc, s: s),
                Expanded(
                  child: Row(
                    children: [
                      _Sidebar(
                        selected: _tab,
                        onSelect: (i) => setState(() => _tab = i),
                        bloc: bloc,
                        wide: s.isWide,
                      ),
                      Expanded(
                        child: MaxWidthBox(
                          maxWidth: AppBreakpoints.maxContentWidth,
                          child: content,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // ── Tablet: drawer + AppBar with nav items visible ─────────────
        if (s.isTablet) {
          return Scaffold(
            backgroundColor: _kBg,
            appBar: _buildAppBar(bloc, showLinks: false),
            drawer: Drawer(
              child: _Sidebar(
                selected: _tab,
                onSelect: (i) {
                  Navigator.pop(context);
                  setState(() => _tab = i);
                },
                bloc: bloc,
                wide: false,
              ),
            ),
            body: SafeArea(child: content),
          );
        }

        // ── Mobile: drawer + compact AppBar ───────────────────────────
        return Scaffold(
          backgroundColor: _kBg,
          appBar: _buildAppBar(bloc, showLinks: false),
          drawer: Drawer(
            child: _Sidebar(
              selected: _tab,
              onSelect: (i) {
                Navigator.pop(context);
                setState(() => _tab = i);
              },
              bloc: bloc,
              wide: false,
            ),
          ),
          body: SafeArea(child: content),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(StudentDashboardBloc bloc,
      {required bool showLinks}) {
    return AppBar(
      backgroundColor: _kNavy,
      foregroundColor: Colors.white,
      elevation: 0,
      title: Text(
        'EduPlay',
        style: GoogleFonts.fredoka(
          fontWeight: FontWeight.w700, fontSize: 20, color: Colors.white),
      ),
      actions: [
        _PointsBadge(points: bloc.points),
        const SizedBox(width: 12),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top navigation bar (desktop only)
// ─────────────────────────────────────────────────────────────────────────────

class _TopNavBar extends StatelessWidget {
  const _TopNavBar({required this.bloc, required this.s});
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  static const _links = ['Learn', 'Games', 'Classroom', 'Reports'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: s.isWide ? 40 : 24,
      ),
      child: Row(
        children: [
          // Logo
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
              fontSize: 22, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(width: 32),

          // Nav links (hide on narrower desktops if needed)
          if (s.isDesktop)
            Row(
              children: _links.map((l) {
                final active = l == 'Learn';
                return Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight:
                              active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? _kNavy : Colors.grey[500],
                        ),
                      ),
                      if (active)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          height: 2,
                          width: 24,
                          decoration: BoxDecoration(
                            color: _kNavy,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const Spacer(),

          _PointsBadge(points: bloc.points),
          const SizedBox(width: 16),

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined,
                  color: Colors.grey[600], size: 22),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: _kCoral, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Avatar + name
          CircleAvatar(
            radius: 16,
            backgroundColor: _kNavy,
            child: Text(
              bloc.displayName.isNotEmpty
                  ? bloc.displayName[0].toUpperCase()
                  : 'E',
              style: GoogleFonts.fredoka(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            bloc.displayName.split(' ').first,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w700, fontSize: 14, color: _kNavy),
          ),
        ],
      ),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points});
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFF8F00), size: 16),
          const SizedBox(width: 4),
          Text(
            '$points pts',
            style: GoogleFonts.fredoka(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A3E00),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sidebar
// ─────────────────────────────────────────────────────────────────────────────

const _sideNavItems = [
  _SideItem(icon: Icons.dashboard_rounded,       label: 'Panel de Control'),
  _SideItem(icon: Icons.videogame_asset_rounded, label: 'Mis Juegos'),
  _SideItem(icon: Icons.emoji_events_rounded,    label: 'Logros'),
  _SideItem(icon: Icons.people_alt_rounded,      label: 'Amigos'),
  _SideItem(icon: Icons.storefront_rounded,      label: 'Tienda'),
];

class _SideItem {
  const _SideItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.onSelect,
    required this.bloc,
    required this.wide,
  });

  final int selected;
  final ValueChanged<int> onSelect;
  final StudentDashboardBloc bloc;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    // Wide desktop: slightly wider sidebar
    final width = wide ? 220.0 : 200.0;

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_kNavy, _kNavyMid, Color(0xFF3D3AA0)],
        ),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Bienvenido!',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Nivel ${bloc.level} Explorador',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),

            _divider(),
            const SizedBox(height: 12),

            // Nav items
            for (var i = 0; i < _sideNavItems.length; i++)
              _SideNavTile(
                item: _sideNavItems[i],
                selected: i == selected,
                onTap: () => onSelect(i),
              ),

            const Spacer(),

            // Quest button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    '¡Comenzar Quest!',
                    style: GoogleFonts.fredoka(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            _divider(),

            _SideFooterTile(
              icon: Icons.help_outline_rounded,
              label: 'Ayuda',
              onTap: () {},
            ),
            _SideFooterTile(
              icon: Icons.logout_rounded,
              label: 'Salir',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, RouterPaths.login),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withValues(alpha: 0.1),
      );
}

class _SideNavTile extends StatelessWidget {
  const _SideNavTile(
      {required this.item, required this.selected, required this.onTap});
  final _SideItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(item.icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.55)),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                item.label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight:
                      selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideFooterTile extends StatelessWidget {
  const _SideFooterTile(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16,
                color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HOME / PANEL DE CONTROL
// ─────────────────────────────────────────────────────────────────────────────

class _HomeView extends StatelessWidget {
  const _HomeView({
    required this.bloc,
    required this.s,
    required this.onTabChange,
  });
  final StudentDashboardBloc bloc;
  final ScreenSize s;
  final ValueChanged<int> onTabChange;

  double get _hPad =>
      s.when(mobile: 16, tablet: 20, desktop: 28);

  @override
  Widget build(BuildContext context) {
    final games = context.watch<MenuProvider>().games;

    return RefreshIndicator(
      color: _kNavy,
      onRefresh: bloc.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
            _hPad, 20, _hPad, 32),
        children: [
          // Mission banner
          _MissionBanner(
            mission: bloc.missionOfTheDay,
            onPlay: () => onTabChange(1),
            s: s,
          ),

          SizedBox(height: s.isMobile ? 16 : 20),

          // Stat cards
          _StatCardsRow(
            streak: bloc.streak,
            level: bloc.level,
            xpIntoLevel: bloc.xpIntoLevel,
            xpProgress: bloc.xpProgress,
            activeChallenges: bloc.activeChallenges.length,
            s: s,
          ),

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
          _MisJuegosSection(games: games, s: s),

          SizedBox(height: s.isMobile ? 24 : 28),

          // Sticker album
          _StickerAlbumSection(
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
                    child: _AmigosEnLineaCard(
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
            _AmigosEnLineaCard(
              challenges: bloc.challenges,
              onComplete: bloc.completeChallenge,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Mission banner ────────────────────────────────────────────────────────────

class _MissionBanner extends StatelessWidget {
  const _MissionBanner({
    required this.mission,
    required this.onPlay,
    required this.s,
  });
  final Map<String, dynamic>? mission;
  final VoidCallback onPlay;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final title = mission?['title'] as String? ??
        '¡La Aventura de las Fracciones te espera!';
    final hasReal = mission != null;

    // Mobile: no mascot, slightly shorter
    // Tablet / Desktop: mascot on the right
    final showMascot = !s.isMobile;

    return Container(
      height: s.when(mobile: 160, tablet: 175, desktop: 185),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1060), Color(0xFF2D2A82), Color(0xFF3D3AA0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -40, right: -40,
            child: _Circle(size: s.isMobile ? 130 : 180, opacity: 0.06),
          ),
          Positioned(
            bottom: -20, left: 80,
            child: _Circle(size: 100, opacity: 0.05),
          ),

          // Gold sparkles
          const Positioned(
              top: 24, left: 160, child: _Star(size: 8, opacity: 0.6)),
          const Positioned(
              top: 44, left: 200, child: _Star(size: 5, opacity: 0.4)),
          const Positioned(
              top: 80, left: 140, child: _Star(size: 6, opacity: 0.5)),

          // Mascot (tablet / desktop only)
          if (showMascot)
            Positioned(
              right: 0,
              bottom: 0,
              top: 0,
              width: s.isDesktop ? 160 : 130,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF2D2A82).withValues(alpha: 0.0),
                      const Color(0xFF3D6090).withValues(alpha: 0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    '🦊',
                    style: TextStyle(
                      fontSize: s.isDesktop ? 72 : 56,
                    ),
                  ),
                ),
              ),
            ),

          // Content
          Padding(
            padding: EdgeInsets.all(s.isMobile ? 18 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MISIÓN DEL DÍA',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF5A3E00),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Title
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: showMascot
                        ? (s.isDesktop ? 240 : 200)
                        : double.infinity,
                  ),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: s.when(mobile: 18, tablet: 20, desktop: 22),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                if (!s.isXs)
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: showMascot ? 210 : double.infinity,
                    ),
                    child: Text(
                      hasReal
                          ? 'Tu profesor te asignó este reto. ¡Gana una estampa legendaria!'
                          : 'Completa 3 retos hoy y gana una estampa legendaria.',
                      maxLines: 2,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 14),

                ElevatedButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: Text(
                    '¡Jugar Ahora!',
                    style: GoogleFonts.fredoka(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
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

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.opacity});
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

class _Star extends StatelessWidget {
  const _Star({required this.size, required this.opacity});
  final double size;
  final double opacity;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kGold.withValues(alpha: opacity),
          boxShadow: [
            BoxShadow(
              color: _kGold.withValues(alpha: opacity * 0.5),
              blurRadius: size,
              spreadRadius: 1,
            ),
          ],
        ),
      );
}

// ── Stat cards ────────────────────────────────────────────────────────────────

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.streak,
    required this.level,
    required this.xpIntoLevel,
    required this.xpProgress,
    required this.activeChallenges,
    required this.s,
  });
  final int streak;
  final int level;
  final int xpIntoLevel;
  final double xpProgress;
  final int activeChallenges;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFFF7043),
        bgColor: const Color(0xFFFFF3F0),
        title: 'Racha Actual',
        value:
            '$streak ${streak == 1 ? 'día' : 'días'} seguidos',
        child: null,
      ),
      _StatCard(
        icon: Icons.military_tech_rounded,
        iconColor: const Color(0xFFFF8F00),
        bgColor: const Color(0xFFFFFBE6),
        title: 'Próximo Nivel',
        value: '$xpIntoLevel / 100 XP',
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: xpProgress,
              minHeight: 6,
              backgroundColor:
                  const Color(0xFFFF8F00).withValues(alpha: 0.12),
              color: const Color(0xFFFF8F00),
            ),
          ),
        ),
      ),
      _StatCard(
        icon: Icons.groups_rounded,
        iconColor: const Color(0xFF5C6BC0),
        bgColor: const Color(0xFFECEFF8),
        title: 'Desafío Grupal',
        value:
            '$activeChallenges ${activeChallenges == 1 ? 'Amigo' : 'Amigos'} jugando',
        child: null,
      ),
    ];

    // Always 3-column on tablet and desktop; single column on small mobile
    if (s.isMobile && s.isXs) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            cards[i],
          ],
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.value,
    required this.child,
  });
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration:
                BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                if (child != null) child!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mis Juegos section ────────────────────────────────────────────────────────

class _MisJuegosSection extends StatelessWidget {
  const _MisJuegosSection({required this.games, required this.s});
  final List<Game> games;
  final ScreenSize s;

  static const _gradients = [
    [Color(0xFF1565C0), Color(0xFF1E88E5)],
    [Color(0xFF00695C), Color(0xFF26A69A)],
    [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
  ];

  @override
  Widget build(BuildContext context) {
    final featured  = games.isNotEmpty ? games[0] : null;
    final secondary = games.length > 1 ? games[1] : null;

    final smallExtras = const [
      (icon: Icons.history_edu_rounded, label: 'Historia',
          name: 'Crónicas de Egipto', sub: 'Explora las pirámides'),
      (icon: Icons.psychology_rounded, label: 'Lógica',
          name: 'Lógica & Puzzles', sub: 'Entrena tu cerebro'),
      (icon: Icons.language_rounded, label: 'Idiomas',
          name: 'Idiomas Pro', sub: 'Nuevas palabras hoy'),
    ];

    return Column(
      children: [
        // ── Featured row ──────────────────────────────────────────────
        if (s.isMobile) ...[
          // Mobile: stacked
          if (featured != null)
            _FeaturedGameCard(game: featured, s: s),
          if (featured != null && secondary != null)
            const SizedBox(height: 12),
          if (secondary != null)
            _SecondaryGameCard(game: secondary, s: s),
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
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
              child: Container(
                width: s.isMobile ? 100 : 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      game.color,
                      game.color.withValues(alpha: 0.6)
                    ],
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
                      child: Icon(game.icon,
                          size: 36, color: Colors.white),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: game.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        Icon(game.icon, color: game.color, size: 20),
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
                                    fontSize: 10,
                                    color: Colors.grey[500])),
                          ],
                        ),
                        Text('Amigos jugando',
                            style: GoogleFonts.nunito(
                                fontSize: 10,
                                color: Colors.grey[400])),
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
  });
  final IconData icon;
  final String name;
  final String sub;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

// ── Sticker album section ─────────────────────────────────────────────────────

class _StickerAlbumSection extends StatelessWidget {
  const _StickerAlbumSection({
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
                      builder: (_) => const StickerAlbumPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
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
              style: GoogleFonts.nunito(
                  fontSize: 12, color: Colors.grey[500]),
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
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (unlocked)
              Icon(sticker.icon, color: sticker.color, size: 26)
            else
              Icon(Icons.lock_rounded,
                  color: Colors.grey[300], size: 20),
            if (sticker.id == 'dino' && unlocked)
              Positioned(
                bottom: 3,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 1),
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

class _AmigosEnLineaCard extends StatelessWidget {
  const _AmigosEnLineaCard({
    required this.challenges,
    required this.onComplete,
  });
  final List<Map<String, dynamic>> challenges;
  final ValueChanged<int> onComplete;

  static const _friends = [
    (name: 'Oliver', initial: 'O', color: Color(0xFF43A047)),
    (name: 'Emma', initial: 'E', color: Color(0xFF1E88E5)),
    (name: 'Lucas', initial: 'L', color: Color(0xFFE53935)),
  ];

  @override
  Widget build(BuildContext context) {
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.grey[300]!, width: 2),
                    ),
                    child: Icon(Icons.add,
                        color: Colors.grey[400], size: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Añadir',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Challenge notification
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
// GAMES HUB TAB
// ─────────────────────────────────────────────────────────────────────────────

class _GamesHubView extends StatelessWidget {
  const _GamesHubView({required this.bloc, required this.s});
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  static final _recent      = allCatalogGames.take(3).toList();
  static final _recommended = allCatalogGames.skip(3).take(6).toList();

  @override
  Widget build(BuildContext context) {
    final hPad = s.when(mobile: 16.0, tablet: 20.0, desktop: 28.0);
    final cols  = gridCols(s, mobile: 2, tablet: 2, desktop: 3);

    return CustomScrollView(
      slivers: [
        // Games hero header
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_kNavy, Color(0xFF3D3AA0)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, ${bloc.displayName.split(' ').first}! 🎮',
                            style: GoogleFonts.fredoka(
                              fontSize:
                                  s.when(mobile: 20, tablet: 22, desktop: 24),
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Nivel ${bloc.level} Explorador · ¡A jugar!',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color:
                                  Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.rocket_launch_rounded,
                      size: s.isMobile ? 48 : 60,
                      color: const Color(0x18FFFFFF),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionTitle('▶ Continuar Jugando'),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _RecentChip(game: _recent[i], s: s),
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  _SectionTitle('✨ Recomendados para Ti'),
                  const Spacer(),
                  _TextLink(
                    label: 'Ver catálogo →',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GamesCatalogPage()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.74,
                ),
                itemCount: _recommended.length,
                itemBuilder: (_, i) => _CatalogGameCard(game: _recommended[i]),
              ),

              const SizedBox(height: 28),

              _CatalogCTABanner(
                count: allCatalogGames.length,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GamesCatalogPage()),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({required this.game, required this.s});
  final CatalogGame game;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, game.route),
      child: Container(
        width: s.isMobile ? 160 : 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: game.gradientColors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: game.gradientColors.last.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8, bottom: -8,
              child: Icon(game.icon, size: 52,
                  color: Colors.white.withValues(alpha: 0.13)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(game.subjectLabel,
                      style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const Spacer(),
                Text(game.title,
                    maxLines: 2,
                    style: GoogleFonts.fredoka(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: game.xpProgress,
                    minHeight: 4,
                    backgroundColor:
                        Colors.white.withValues(alpha: 0.25),
                    color: _kGold,
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

class _CatalogGameCard extends StatelessWidget {
  const _CatalogGameCard({required this.game});
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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: game.gradientColors,
                      ),
                    ),
                  ),
                  CustomPaint(
                      painter: _ArtPainter(game.gradientColors)),
                  Center(
                    child: Icon(game.icon, size: 46,
                        color: Colors.white.withValues(alpha: 0.6)),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: game.subjectColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(game.subjectLabel,
                          style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color:
                              Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text('Nivel ${game.level}',
                          style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kNavy)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: game.xpProgress,
                          minHeight: 5,
                          backgroundColor: const Color(0xFFF3F4F6),
                          color: _kGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('${(game.xpProgress * 100).toInt()}%',
                        style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, game.route),
                    icon: const Icon(Icons.play_arrow_rounded, size: 15),
                    label: Text('Jugar',
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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

class _CatalogCTABanner extends StatelessWidget {
  const _CatalogCTABanner({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFFF7043)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Descubre más aventuras!',
                      style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Explora +$count juegos educativos',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color:
                              Colors.white.withValues(alpha: 0.8))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
              child: Text('Ver todo →',
                  style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE53935))),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACHIEVEMENTS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AchievementsView extends StatelessWidget {
  const _AchievementsView({required this.s});
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<StudentDashboardBloc>();
    final progress = bloc.totalStickerCount == 0
        ? 0.0
        : bloc.unlockedStickerCount / bloc.totalStickerCount;

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
                    Text(
                      '🏆 Mis Logros',
                      style: GoogleFonts.fredoka(
                        fontSize: s.isMobile ? 22 : 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
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
            child: StickerAlbumGrid(padding: EdgeInsets.zero),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
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

// ── Art painter ───────────────────────────────────────────────────────────────

class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(
        Offset(size.width * 1.1, size.height * -0.1),
        size.width * 0.7,
        p);
    canvas.drawCircle(
        Offset(size.width * -0.15, size.height * 1.1),
        size.width * 0.55,
        p);
    canvas.drawLine(
      Offset(0, size.height * 1.2),
      Offset(size.width * 1.2, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.04)
        ..strokeWidth = size.width * 0.3
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_ArtPainter old) => false;
}

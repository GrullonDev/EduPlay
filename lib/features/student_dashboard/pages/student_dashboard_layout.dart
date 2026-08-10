import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/core/audio/sound_manager.dart';
import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/games_catalog/widgets/catalog_filter_content.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/menu/models/game.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/sticker_album/models/sticker.dart';
import 'package:edu_play/features/sticker_album/pages/sticker_album_page.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/widgets/leaderboard_card.dart';
import 'package:edu_play/features/student_dashboard/widgets/my_challenges_card.dart';
import 'package:edu_play/utils/dialogs/confetti_burst.dart';
import 'package:edu_play/utils/dialogs/custom_dialog.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyMid = Color(0xFF2D2A82);
const _kCoral = Color(0xFFE53935);
const _kGold = Color(0xFFFFD700);
const _kBg = Color(0xFFF3F5F9);

// ─────────────────────────────────────────────────────────────────────────────
// Root layout
// ─────────────────────────────────────────────────────────────────────────────

class StudentDashboardLayout extends StatefulWidget {
  const StudentDashboardLayout({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<StudentDashboardLayout> createState() => _StudentDashboardLayoutState();
}

class _StudentDashboardLayoutState extends State<StudentDashboardLayout> {
  late int _tab = widget.initialTab;

  /// Set when the user taps a subject shortcut (e.g. the "Lógica & Puzzles"
  /// card on the home tab) so "Mis Juegos" opens pre-filtered. Cleared on any
  /// plain tab switch so it never applies to an unrelated visit.
  GameSubject? _pendingSubject;

  /// Kindergarten-age children (<= 5) never see Panel de Control/Logros —
  /// they always land on (and stay on) the games tab. Computed rather than
  /// stored so it can't drift out of sync with `bloc.isYoungChild`.
  int _effectiveTab(StudentDashboardBloc bloc) => bloc.isYoungChild ? 1 : _tab;

  /// Guards the level-up celebration to a true one-shot per pending level-up:
  /// set synchronously (not inside the post-frame callback) so a rebuild
  /// triggered by `acknowledgeLevelUp()`'s `notifyListeners()` can't race
  /// into scheduling the dialog a second time.
  bool _celebrationShown = false;

  void _maybeShowLevelUpCelebration(StudentDashboardBloc bloc) {
    if (bloc.levelUpToShow == null || _celebrationShown) return;
    _celebrationShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showLevelUpCelebration(context, bloc);
    });
  }

  void _showLevelUpCelebration(
      BuildContext context, StudentDashboardBloc bloc) {
    SoundManager().playWin();
    final newStickers = bloc.newlyUnlockedStickers;
    final content = newStickers.isEmpty
        ? '¡Sigue jugando para desbloquear más sorpresas!'
        : newStickers.length == 1
            ? '¡Ganaste la estampa "${newStickers.first.name}"!'
            : '¡Ganaste ${newStickers.length} estampas nuevas!';

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) => Stack(
        children: [
          const Positioned.fill(child: ConfettiBurst()),
          CustomDialog(
            type: DialogType.levelUp,
            title: '¡Subiste a Nivel ${bloc.levelUpToShow}!',
            content: content,
            buttonText: '¡Genial!',
            onButtonPressed: () {
              bloc.acknowledgeLevelUp();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _selectTab(int i) => setState(() {
        _tab = i;
        _pendingSubject = null;
      });

  void _openGamesForSubject(GameSubject subject) => setState(() {
        _tab = 1;
        _pendingSubject = subject;
      });

  Widget _buildContent(StudentDashboardBloc bloc, ScreenSize s, int tab) {
    switch (tab) {
      case 1:
        return _GamesHubView(bloc: bloc, s: s, initialSubject: _pendingSubject);
      case 2:
        return _AchievementsView(s: s);
      default:
        return _HomeView(
          bloc: bloc,
          s: s,
          onTabChange: _selectTab,
          onSubjectSelect: _openGamesForSubject,
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

        _maybeShowLevelUpCelebration(bloc);

        final tab = _effectiveTab(bloc);
        final content = _buildContent(bloc, s, tab);

        // ── Desktop: top nav + persistent sidebar ──────────────────────
        if (s.isDesktop) {
          return Scaffold(
            backgroundColor: _kBg,
            body: Column(
              children: [
                _TopNavBar(
                  bloc: bloc,
                  s: s,
                  selectedTab: tab,
                  onSelect: _selectTab,
                ),
                Expanded(
                  child: Row(
                    children: [
                      _Sidebar(
                        selected: tab,
                        onSelect: _selectTab,
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
                selected: tab,
                onSelect: (i) {
                  Navigator.pop(context);
                  _selectTab(i);
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
              selected: tab,
              onSelect: (i) {
                Navigator.pop(context);
                _selectTab(i);
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
  const _TopNavBar({
    required this.bloc,
    required this.s,
    required this.selectedTab,
    required this.onSelect,
  });
  final StudentDashboardBloc bloc;
  final ScreenSize s;
  final int selectedTab;
  final ValueChanged<int> onSelect;

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

          const Spacer(),

          _PointsBadge(points: bloc.points),
          const SizedBox(width: 16),

          // Notification bell
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notificaciones próximamente.'),
                duration: Duration(seconds: 2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Stack(
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
            ),
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
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
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
  _SideItem(icon: Icons.dashboard_rounded, label: 'Panel de Control', tab: 0),
  _SideItem(icon: Icons.videogame_asset_rounded, label: 'Mis Juegos', tab: 1),
  _SideItem(icon: Icons.emoji_events_rounded, label: 'Logros', tab: 2),
  if (ReleaseFlags.studentExtraTabsEnabled)
    _SideItem(icon: Icons.people_alt_rounded, label: 'Amigos', tab: 3),
  if (ReleaseFlags.studentExtraTabsEnabled)
    _SideItem(icon: Icons.storefront_rounded, label: 'Tienda', tab: 4),
];

/// Kindergarten-age children (<= 5) only ever see "Mis Juegos" — Panel de
/// Control and Logros are hidden entirely, not just unreachable.
List<_SideItem> _visibleNavItems(bool isYoungChild) => isYoungChild
    ? _sideNavItems.where((i) => i.tab == 1).toList()
    : _sideNavItems;

class _SideItem {
  const _SideItem({required this.icon, required this.label, required this.tab});
  final IconData icon;
  final String label;
  final int tab;
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
            for (final item in _visibleNavItems(bloc.isYoungChild))
              _SideNavTile(
                item: item,
                selected: item.tab == selected,
                onTap: () => onSelect(item.tab),
              ),

            const Spacer(),

            // Quest button → opens the Mis Juegos tab
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onSelect(1),
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
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Centro de ayuda próximamente.'),
                  duration: Duration(seconds: 2),
                ),
              ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                  fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
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

          if (bloc.childProfile != null) ...[
            SizedBox(height: s.isMobile ? 24 : 28),
            _NeedsPracticeSection(
              recommendations: bloc.recommendations,
              weakestSubject: bloc.weakestSubject,
              s: s,
            ),
            SizedBox(height: s.isMobile ? 24 : 28),
            _PracticeSessionsSection(childId: bloc.childProfile!.id),
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
          _MisJuegosSection(
            games: games,
            s: s,
            onSubjectSelect: onSubjectSelect,
          ),

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

// ── Needs practice (parent-assigned games / weakest subject) ──────────────────

const _kSubjectLabels = {
  GameSubject.math: 'Matemáticas',
  GameSubject.science: 'Ciencias',
  GameSubject.history: 'Historia',
  GameSubject.languages: 'Idiomas',
  GameSubject.logic: 'Lógica',
  GameSubject.art: 'Arte',
  GameSubject.music: 'Música',
  GameSubject.sports: 'Deportes',
};

class _NeedsPracticeSection extends StatelessWidget {
  const _NeedsPracticeSection({
    required this.recommendations,
    required this.weakestSubject,
    required this.s,
  });
  final List<GameRecommendation> recommendations;
  final GameSubject? weakestSubject;
  final ScreenSize s;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty && weakestSubject == null) {
      return const SizedBox.shrink();
    }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: _kCoral, size: 18),
              const SizedBox(width: 8),
              Text(
                'Necesita practicar',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recommendations.isNotEmpty)
            for (final rec in recommendations) _RecommendationTile(rec: rec)
          else if (weakestSubject != null)
            Text(
              'Te recomendamos practicar más: '
              '${_kSubjectLabels[weakestSubject] ?? 'esta materia'}.',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  const _RecommendationTile({required this.rec});
  final GameRecommendation rec;

  @override
  Widget build(BuildContext context) {
    final game = allCatalogGames
        .cast<CatalogGame?>()
        .firstWhere((g) => g?.id == rec.gameId, orElse: () => null);
    if (game == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, game.route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: game.subjectColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(game.icon, color: game.subjectColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kNavy),
                  ),
                  Text(
                    rec.reason,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

// ── Active practice sessions (parent-assigned) ─────────────────────────────────

class _PracticeSessionsSection extends StatefulWidget {
  const _PracticeSessionsSection({required this.childId});
  final String childId;

  @override
  State<_PracticeSessionsSection> createState() =>
      _PracticeSessionsSectionState();
}

class _PracticeSessionsSectionState extends State<_PracticeSessionsSection> {
  List<PracticeSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final sessions = await PracticeSessionsService.getActiveSessionsByChildId(
          widget.childId);
      if (mounted) setState(() => _sessions = sessions);
    } catch (_) {
      // No active sessions / offline — section simply stays hidden.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sessions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sesiones activas',
          style: GoogleFonts.fredoka(
              fontSize: 16, fontWeight: FontWeight.w700, color: _kNavy),
        ),
        const SizedBox(height: 12),
        for (final session in _sessions)
          _SessionCard(
            session: session,
            onTap: () => Navigator.pushNamed(
              context,
              RouterPaths.practiceKiosk,
              arguments: session,
            ),
          ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});
  final PracticeSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = session.completedCount;
    final total = session.totalCount;
    final progress = session.progressFraction;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEDF8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.sports_esports_rounded,
                        color: _kNavy, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sesión de práctica',
                        style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      Text(
                        '$completed de $total juegos completados',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _kCoral,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '¡Jugar!',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: const Color(0xFFEEEDF8),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1 ? const Color(0xFF27AE60) : _kCoral,
                ),
              ),
            ),
          ],
        ),
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
      constraints: BoxConstraints(
        minHeight: s.when(mobile: 200, tablet: 185, desktop: 195),
      ),
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
            top: -40,
            right: -40,
            child: _Circle(size: s.isMobile ? 130 : 180, opacity: 0.06),
          ),
          const Positioned(
            bottom: -20,
            left: 80,
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

                if (!s.isMobile)
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
        value: '$streak ${streak == 1 ? 'día' : 'días'} seguidos',
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
              backgroundColor: const Color(0xFFFF8F00).withValues(alpha: 0.12),
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
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
  const _MisJuegosSection({
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

class _AmigosEnLineaCard extends StatelessWidget {
  const _AmigosEnLineaCard({
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

class _GamesHubView extends StatefulWidget {
  const _GamesHubView(
      {required this.bloc, required this.s, this.initialSubject});
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  /// Set when the child tapped a subject shortcut on the home tab (e.g.
  /// "Lógica & Puzzles") — pre-filters the catalog to that subject instead
  /// of the default "all subjects" / weakest-subject auto-filter.
  final GameSubject? initialSubject;

  @override
  State<_GamesHubView> createState() => _GamesHubViewState();
}

class _GamesHubViewState extends State<_GamesHubView> {
  GameSubject _selectedSubject = GameSubject.all;
  // All age ranges active by default so no games are hidden on first open.
  final Set<AgeRange> _selectedAges = {
    AgeRange.age6to8,
    AgeRange.age9to11,
    AgeRange.age12plus,
  };
  final Set<Difficulty> _selectedDifficulties = {
    Difficulty.beginner,
    Difficulty.intermediate,
    Difficulty.advanced,
  };
  bool _gridView = true;
  String _sortBy = 'Popular'; // 'Popular' | 'Newest' | 'Level'
  int _visibleCount = 9; // games shown before "load more"
  static const _pageSize = 6; // how many each "load more" reveals

  // "Continuar Jugando" quick-access strip — unchanged data source.
  static final _recent = allCatalogGames.take(3).toList();

  @override
  void initState() {
    super.initState();
    if (widget.initialSubject != null) {
      _selectedSubject = widget.initialSubject!;
    }
    final profile = widget.bloc.childProfile;
    if (profile != null) {
      _selectedAges
        ..clear()
        ..add(ageRangeForAge(profile.age));
      // Don't let the async weakest-subject auto-filter clobber an explicit
      // subject the child just tapped on the home tab.
      if (widget.initialSubject == null) {
        _loadWeakestSubject(profile.id);
      }
    }
  }

  Future<void> _loadWeakestSubject(String childProfileId) async {
    final subject =
        await ProgressRecommendationsService.weakestSubject(childProfileId);
    if (mounted && subject != null) {
      setState(() => _selectedSubject = subject);
    }
  }

  /// Count of non-default filter selections (shown as badge on mobile).
  int get _activeFilterCount {
    int count = 0;
    if (_selectedSubject != GameSubject.all) count++;
    if (_selectedAges.length < AgeRange.values.length) count++;
    if (_selectedDifficulties.length < Difficulty.values.length) count++;
    return count;
  }

  List<CatalogGame> get _filtered {
    final list = allCatalogGames.where((g) {
      if (_selectedSubject != GameSubject.all &&
          g.subject != _selectedSubject) {
        return false;
      }
      if (_selectedAges.isNotEmpty && !_selectedAges.contains(g.ageRange)) {
        return false;
      }
      if (_selectedDifficulties.isNotEmpty &&
          !_selectedDifficulties.contains(g.difficulty)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'Newest':
        list.sort((a, b) => b.level.compareTo(a.level));
      case 'Level':
        list.sort((a, b) => a.level.compareTo(b.level));
      default: // 'Popular' — sort by xpProgress desc as popularity proxy
        list.sort((a, b) => b.xpProgress.compareTo(a.xpProgress));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = widget.bloc;
    final s = widget.s;
    final hPad = s.when(mobile: 16.0, tablet: 20.0, desktop: 28.0);
    final isDesktop = s.isDesktop;

    // Mobile/tablet route filters through a modal sheet (filterDrawer);
    // desktop renders the filter panel as a persistent sidebar instead (below).
    final mainContent = CatalogMainContent(
      filtered: _filtered,
      gridView: _gridView,
      onToggleView: () => setState(() => _gridView = !_gridView),
      activeFilterCount: _activeFilterCount,
      sortBy: _sortBy,
      onSortChanged: (v) => setState(() {
        _sortBy = v;
        _visibleCount = 9;
      }),
      visibleCount: _visibleCount,
      onLoadMore: () => setState(() => _visibleCount += _pageSize),
      filterDrawer: isDesktop
          ? null
          : _filterPanel(onDismiss: () => Navigator.of(context).pop()),
    );

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
                              color: Colors.white.withValues(alpha: 0.7),
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

        // "Continuar Jugando" — quick-access strip above the full catalog
        SliverPadding(
          padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('▶ Continuar Jugando'),
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
              ],
            ),
          ),
        ),

        // Full filterable catalog — same content/behavior as the former
        // standalone GamesCatalogPage, embedded here as ordinary (non-sliver)
        // widgets. CatalogMainContent's internal ListView is shrinkWrap +
        // NeverScrollableScrollPhysics so it composes cleanly inside this
        // outer CustomScrollView instead of fighting it for scroll gestures.
        SliverPadding(
          padding: const EdgeInsets.only(top: 8),
          sliver: SliverToBoxAdapter(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _filterPanel(),
                      Expanded(child: mainContent),
                    ],
                  )
                : mainContent,
          ),
        ),
      ],
    );
  }

  Widget _filterPanel({VoidCallback? onDismiss}) => CatalogFilterPanel(
        onDismiss: onDismiss,
        selectedSubject: _selectedSubject,
        selectedAges: _selectedAges,
        selectedDifficulties: _selectedDifficulties,
        onSubjectChanged: (v) => setState(() {
          _selectedSubject = v;
          _visibleCount = 9;
        }),
        onAgeToggled: (a) => setState(() {
          _selectedAges.contains(a)
              ? _selectedAges.remove(a)
              : _selectedAges.add(a);
          _visibleCount = 9;
        }),
        onDifficultyToggled: (d) => setState(() {
          _selectedDifficulties.contains(d)
              ? _selectedDifficulties.remove(d)
              : _selectedDifficulties.add(d);
          _visibleCount = 9;
        }),
      );
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
              right: -8,
              bottom: -8,
              child: Icon(game.icon,
                  size: 52, color: Colors.white.withValues(alpha: 0.13)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.25),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/games_catalog/models/catalog_game_registry_adapter.dart';
import 'package:edu_play/features/games_catalog/widgets/catalog_filter_content.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGold = Color(0xFFFFD700);

class StudentGamesHubView extends StatefulWidget {
  const StudentGamesHubView({
    super.key,
    required this.bloc,
    required this.s,
    this.initialSubject,
  });
  final StudentDashboardBloc bloc;
  final ScreenSize s;

  /// Set when the child tapped a subject shortcut on the home tab (e.g.
  /// "Lógica & Puzzles") — pre-filters the catalog to that subject instead
  /// of the default "all subjects" / weakest-subject auto-filter.
  final GameSubject? initialSubject;

  @override
  State<StudentGamesHubView> createState() => StudentGamesHubViewState();
}

class StudentGamesHubViewState extends State<StudentGamesHubView> {
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
  static final _recent = effectiveCatalogGames.take(3).toList();

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
    final list = effectiveCatalogGames.where((g) {
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
                const _GamesSectionTitle('▶ Continuar Jugando'),
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
class _GamesSectionTitle extends StatelessWidget {
  const _GamesSectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.fredoka(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _kNavy,
        ),
      );
}

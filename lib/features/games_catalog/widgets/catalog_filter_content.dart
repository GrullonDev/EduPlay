// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';

// ── Tokens ────────────────────────────────────────────────────────────────────
// Mirrors the private tokens previously declared in games_catalog_page.dart —
// kept in sync manually since these widgets were extracted from there.

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kCoral = Color(0xFFFF6E6C);

/// Pushes a game's route and, on return, refreshes [StudentDashboardBloc] so
/// points/streak/level earned during play (guest or registered) show up
/// immediately in the Panel de Control / Tienda instead of staying stale
/// until the app restarts. This hub view always lives inside the dashboard's
/// provider tree (see StudentDashboardLayout), so the bloc is always found.
Future<void> _openGame(BuildContext context, String route) async {
  final dashboardBloc = context.read<StudentDashboardBloc>();
  await Navigator.pushNamed(context, route);
  await dashboardBloc.refresh();
}

// ── Filter panel ──────────────────────────────────────────────────────────────

class CatalogFilterPanel extends StatelessWidget {
  const CatalogFilterPanel({
    super.key,
    required this.selectedSubject,
    required this.selectedAges,
    required this.selectedDifficulties,
    required this.onSubjectChanged,
    required this.onAgeToggled,
    required this.onDifficultyToggled,
    this.onDismiss,
  });

  final GameSubject selectedSubject;
  final Set<AgeRange> selectedAges;
  final Set<Difficulty> selectedDifficulties;
  final ValueChanged<GameSubject> onSubjectChanged;
  final ValueChanged<AgeRange> onAgeToggled;
  final ValueChanged<Difficulty> onDifficultyToggled;

  /// Called by the "¡Explorar!" button — pass `Navigator.of(context).pop`
  /// when this panel is shown inside a modal sheet (mobile/tablet). Leave
  /// null when it's rendered as a persistent sidebar (desktop): there's no
  /// sheet to dismiss, and popping there would pop the whole dashboard
  /// screen off the navigation stack instead.
  final VoidCallback? onDismiss;

  static const _subjects = [
    (GameSubject.all, 'Todos los juegos', Icons.grid_view_rounded),
    (GameSubject.math, 'Matemáticas', Icons.calculate_rounded),
    (GameSubject.science, 'Ciencias', Icons.biotech_rounded),
    (GameSubject.history, 'Historia', Icons.account_balance_rounded),
    (GameSubject.languages, 'Idiomas', Icons.translate_rounded),
    (GameSubject.logic, 'Lógica', Icons.extension_rounded),
    (GameSubject.art, 'Arte', Icons.palette_rounded),
    (GameSubject.music, 'Música', Icons.music_note_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Catálogo',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 20),
              const _FilterSection(label: 'MATERIAS'),
              const SizedBox(height: 10),
              for (final (subject, label, icon) in _subjects)
                _SubjectTile(
                  label: label,
                  icon: icon,
                  selected: selectedSubject == subject,
                  onTap: () => onSubjectChanged(subject),
                ),
              const SizedBox(height: 20),
              const _FilterSection(label: 'EDAD'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _AgeChip(
                    label: '6-8',
                    selected: selectedAges.contains(AgeRange.age6to8),
                    onTap: () => onAgeToggled(AgeRange.age6to8),
                  ),
                  _AgeChip(
                    label: '9-11',
                    selected: selectedAges.contains(AgeRange.age9to11),
                    onTap: () => onAgeToggled(AgeRange.age9to11),
                  ),
                  _AgeChip(
                    label: '12+',
                    selected: selectedAges.contains(AgeRange.age12plus),
                    onTap: () => onAgeToggled(AgeRange.age12plus),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _FilterSection(label: 'DIFICULTAD'),
              const SizedBox(height: 10),
              for (final (d, label) in [
                (Difficulty.beginner, 'Principiante'),
                (Difficulty.intermediate, 'Intermedio'),
                (Difficulty.advanced, 'Avanzado'),
              ])
                _DifficultyCheck(
                  label: label,
                  checked: selectedDifficulties.contains(d),
                  onChanged: (_) => onDifficultyToggled(d),
                ),
              // Only shown in the modal-sheet (mobile/tablet) presentation —
              // the persistent desktop sidebar applies filters live as the
              // child taps them, so there's nothing for this button to do
              // there and it's omitted instead of being a dead tap target.
              if (onDismiss != null) ...[
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                    label: Text(
                      '¡Explorar!',
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.nunito(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: Colors.grey[500],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _kNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeChip extends StatelessWidget {
  const _AgeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kNavy : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

class _DifficultyCheck extends StatelessWidget {
  const _DifficultyCheck({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: Checkbox(
              value: checked,
              onChanged: onChanged,
              activeColor: _kNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main content ──────────────────────────────────────────────────────────────

class CatalogMainContent extends StatelessWidget {
  const CatalogMainContent({
    super.key,
    required this.filtered,
    required this.gridView,
    required this.onToggleView,
    required this.sortBy,
    required this.onSortChanged,
    required this.visibleCount,
    required this.onLoadMore,
    this.filterDrawer,
    this.activeFilterCount = 0,
  });

  final List<CatalogGame> filtered;
  final bool gridView;
  final VoidCallback onToggleView;
  final String sortBy;
  final ValueChanged<String> onSortChanged;
  final int visibleCount;
  final VoidCallback onLoadMore;
  final Widget? filterDrawer;
  final int activeFilterCount;

  void _openFilters(BuildContext context) {
    if (filterDrawer == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              filterDrawer!,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = featuredGames;
    final isMobile = filterDrawer != null; // mobile passes filterDrawer

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      children: [
        // Featured section
        _FeaturedSection(featured: featured),
        const SizedBox(height: 32),
        // Grid header
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Juegos Populares',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                Text(
                  'Seleccionados para ti',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Mobile filter button
            if (isMobile) ...[
              _FilterButton(
                activeCount: activeFilterCount,
                onTap: () => _openFilters(context),
              ),
              const SizedBox(width: 8),
            ],
            if (!isMobile) ...[
              Text(
                'Ordenar por:',
                style:
                    GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(width: 6),
              _SortDropdown(value: sortBy, onChanged: onSortChanged),
              const SizedBox(width: 12),
            ],
            _ViewToggle(gridView: gridView, onToggle: onToggleView),
          ],
        ),
        const SizedBox(height: 20),
        // Game grid — sliced to visibleCount
        () {
          final visible = filtered.take(visibleCount).toList();
          if (filtered.isEmpty) return _EmptyState();
          return gridView
              ? _GameGrid(games: visible)
              : _GameList(games: visible);
        }(),
        const SizedBox(height: 24),
        // Load more — hidden when everything is already visible
        if (visibleCount < filtered.length)
          Center(
            child: OutlinedButton.icon(
              onPressed: onLoadMore,
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(
                'Cargar más juegos  (${filtered.length - visibleCount} restantes)',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _kNavy,
                side: BorderSide(color: Colors.grey.shade300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ── Mobile filter button ──────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onTap});
  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: activeCount > 0 ? _kNavy : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activeCount > 0 ? _kNavy : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 15,
              color: activeCount > 0 ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 5),
            Text(
              'Filtrar',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: activeCount > 0 ? Colors.white : Colors.grey[600],
              ),
            ),
            if (activeCount > 0) ...[
              const SizedBox(width: 5),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: _kCoral,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$activeCount',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Featured section ──────────────────────────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.featured});

  final List<CatalogGame> featured;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    if (featured.isEmpty) return const SizedBox.shrink();

    final hero = featured.first;
    final sides = featured.skip(1).take(2).toList();

    if (!isDesktop) {
      return Column(
        children: [
          // Hero card needs a fixed height so Stack(fit: StackFit.expand)
          // and the inner Spacer() have a bounded constraint on mobile.
          SizedBox(height: 270, child: _HeroCard(game: hero)),
          const SizedBox(height: 12),
          for (final g in sides) ...[
            // Side cards: bounded height so Spacer() doesn't overflow.
            SizedBox(height: 150, child: _SideFeaturedCard(game: g)),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // 320px: each side card gets (320−12)/2 = 154px → inner Column = 118px.
    // Content is ~110px so Spacer absorbs the remaining 8px — no overflow.
    // (At 300px the inner Column was only 108px, causing a 2px overflow.)
    return SizedBox(
      height: 320,
      child: Row(
        children: [
          Expanded(flex: 6, child: _HeroCard(game: hero)),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(child: _SideFeaturedCard(game: sides[0])),
                if (sides.length > 1) ...[
                  const SizedBox(height: 12),
                  Expanded(child: _SideFeaturedCard(game: sides[1])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.game});

  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: game.gradientColors,
              ),
            ),
          ),
          // Geometric art overlay
          CustomPaint(painter: _CatalogArtPainter(game.gradientColors)),
          // Central icon (large, styled)
          Positioned(
            right: 28,
            bottom: 28,
            child: Icon(
              game.icon,
              size: 130,
              color: Colors.white.withValues(alpha: 0.13),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _FeaturedBadge(tag: game.featuredTag ?? '', yellow: true),
                    const SizedBox(width: 10),
                    // Difficulty pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        game.difficultyLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  game.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.78),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats row
                Row(
                  children: [
                    _HeroStat(
                        icon: Icons.star_rounded, label: 'Nivel ${game.level}'),
                    const SizedBox(width: 16),
                    _HeroStat(
                        icon: Icons.people_alt_rounded, label: game.ageLabel),
                    const SizedBox(width: 16),
                    _HeroStat(
                      icon: Icons.local_fire_department_rounded,
                      label: '${(game.xpProgress * 100).toInt()}% XP',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openGame(context, game.route),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: Text(
                        'Jugar ahora',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _SideFeaturedCard extends StatelessWidget {
  const _SideFeaturedCard({required this.game});

  final CatalogGame game;

  bool get _isYellow => game.featuredTag == 'TRENDING';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient bg (subtle)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isYellow
                    ? [const Color(0xFFFFF8DC), const Color(0xFFFFF0A0)]
                    : [const Color(0xFFEEEDF8), const Color(0xFFE0DEF5)],
              ),
            ),
          ),
          // Geometric circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_isYellow ? const Color(0xFFFFD700) : _kNavy)
                    .withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: -16,
            bottom: -16,
            child: Icon(
              game.icon,
              size: 80,
              color: (_isYellow ? const Color(0xFF8B6914) : _kNavy)
                  .withValues(alpha: 0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FeaturedBadge(tag: game.featuredTag ?? '', yellow: _isYellow),
                const Spacer(),
                Text(
                  game.title,
                  style: GoogleFonts.fredoka(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: _isYellow ? const Color(0xFF3D2B00) : _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: (_isYellow ? const Color(0xFF3D2B00) : _kNavy)
                        .withValues(alpha: 0.6),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (_isYellow ? const Color(0xFF8B6914) : _kNavy)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.ageLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _isYellow ? const Color(0xFF8B6914) : _kNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge({required this.tag, this.yellow = false});

  final String tag;
  final bool yellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: yellow ? const Color(0xFFFFD700) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: yellow ? const Color(0xFF3D2B00) : _kNavy,
        ),
      ),
    );
  }
}

// ── Game grid / list ──────────────────────────────────────────────────────────

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox.shrink(),
      style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w700, color: _kNavy),
      items: const [
        DropdownMenuItem(value: 'Popular', child: Text('Popular')),
        DropdownMenuItem(value: 'Newest', child: Text('Más nuevos')),
        DropdownMenuItem(value: 'Level', child: Text('Nivel')),
      ],
      onChanged: (v) => onChanged(v!),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.gridView, required this.onToggle});

  final bool gridView;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleBtn(
          icon: Icons.grid_view_rounded,
          active: gridView,
          onTap: gridView ? null : onToggle,
        ),
        const SizedBox(width: 4),
        _ToggleBtn(
          icon: Icons.view_list_rounded,
          active: !gridView,
          onTap: !gridView ? null : onToggle,
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? _kNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 18,
          color: active ? Colors.white : Colors.grey[400],
        ),
      ),
    );
  }
}

class _GameGrid extends StatelessWidget {
  const _GameGrid({required this.games});

  final List<CatalogGame> games;

  @override
  Widget build(BuildContext context) {
    final s = ScreenSize.of(context);
    final cols = s.isWide ? 3 : (s.isTablet || s.isDesktop ? 2 : 1);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: games.length,
      itemBuilder: (_, i) => _GameCard(game: games[i]),
    );
  }
}

class _GameList extends StatelessWidget {
  const _GameList({required this.games});

  final List<CatalogGame> games;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final g in games) ...[
          _GameListTile(game: g),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

// ── Game card (grid) ──────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game});

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
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area with gradient + geometric art
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
                  CustomPaint(painter: _CatalogArtPainter(game.gradientColors)),
                  Center(
                    child: Icon(
                      game.icon,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
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
                          letterSpacing: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Level chip bottom left
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        game.title,
                        style: GoogleFonts.fredoka(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDF8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Level ${game.level}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_alt_outlined,
                        size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      game.ageLabel,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // XP progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: game.xpProgress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF3F4F6),
                    color: const Color(0xFFFFD700),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openGame(context, game.route),
                    icon:
                        const Icon(Icons.play_circle_outline_rounded, size: 16),
                    label: Text(
                      'Jugar',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kNavy,
                      side: BorderSide(color: Colors.grey.shade200),
                      backgroundColor: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

// ── Game list tile ────────────────────────────────────────────────────────────

class _GameListTile extends StatelessWidget {
  const _GameListTile({required this.game});

  final CatalogGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: game.gradientColors,
                ),
              ),
              child: Icon(game.icon,
                  size: 32, color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      game.title,
                      style: GoogleFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEEDF8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lv ${game.level}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _kNavy,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  game.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: game.subjectColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        game.subjectLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: game.subjectColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.people_alt_outlined,
                        size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
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
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => _openGame(context, game.route),
            icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
            label: Text(
              'Jugar',
              style:
                  GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kNavy,
              side: BorderSide(color: Colors.grey.shade200),
              backgroundColor: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No se encontraron juegos',
              style: GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 8),
            Text(
              'Prueba con otros filtros',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Geometric art CustomPainter ───────────────────────────────────────────────

class _CatalogArtPainter extends CustomPainter {
  const _CatalogArtPainter(this.colors);
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;

    // Large circle top-right
    p.color = Colors.white.withValues(alpha: 0.07);
    canvas.drawCircle(
        Offset(size.width * 1.05, size.height * -0.05), size.width * 0.65, p);

    // Medium circle bottom-left
    p.color = Colors.white.withValues(alpha: 0.05);
    canvas.drawCircle(
        Offset(size.width * -0.1, size.height * 1.05), size.width * 0.5, p);

    // Small bright accent circle
    p.color = Colors.white.withValues(alpha: 0.09);
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.15), size.width * 0.15, p);

    // Diagonal stripe
    final stripe = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = size.width * 0.28
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(0, size.height * 1.15),
      Offset(size.width * 1.15, 0),
      stripe,
    );
  }

  @override
  bool shouldRepaint(_CatalogArtPainter old) => false;
}

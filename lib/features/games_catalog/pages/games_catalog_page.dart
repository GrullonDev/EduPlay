import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);
const _kBg = Color(0xFFF8F7FF);

class GamesCatalogPage extends StatefulWidget {
  const GamesCatalogPage({super.key});

  @override
  State<GamesCatalogPage> createState() => _GamesCatalogPageState();
}

class _GamesCatalogPageState extends State<GamesCatalogPage> {
  GameSubject _selectedSubject = GameSubject.all;
  final Set<AgeRange> _selectedAges = {AgeRange.age9to11};
  final Set<Difficulty> _selectedDifficulties = {Difficulty.intermediate};
  bool _gridView = true;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CatalogGame> get _filtered {
    return allCatalogGames.where((g) {
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
      if (_searchQuery.isNotEmpty &&
          !g.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !g.subjectLabel.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _TopBar(
            searchController: _searchController,
            onSearch: (q) => setState(() => _searchQuery = q),
          ),
          Expanded(
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FilterPanel(
                        selectedSubject: _selectedSubject,
                        selectedAges: _selectedAges,
                        selectedDifficulties: _selectedDifficulties,
                        onSubjectChanged: (s) =>
                            setState(() => _selectedSubject = s),
                        onAgeToggled: (a) => setState(() {
                          _selectedAges.contains(a)
                              ? _selectedAges.remove(a)
                              : _selectedAges.add(a);
                        }),
                        onDifficultyToggled: (d) => setState(() {
                          _selectedDifficulties.contains(d)
                              ? _selectedDifficulties.remove(d)
                              : _selectedDifficulties.add(d);
                        }),
                      ),
                      Expanded(
                        child: _MainContent(
                          filtered: _filtered,
                          gridView: _gridView,
                          onToggleView: () =>
                              setState(() => _gridView = !_gridView),
                        ),
                      ),
                    ],
                  )
                : _MainContent(
                    filtered: _filtered,
                    gridView: _gridView,
                    onToggleView: () => setState(() => _gridView = !_gridView),
                    filterDrawer: _FilterPanel(
                      selectedSubject: _selectedSubject,
                      selectedAges: _selectedAges,
                      selectedDifficulties: _selectedDifficulties,
                      onSubjectChanged: (s) =>
                          setState(() => _selectedSubject = s),
                      onAgeToggled: (a) => setState(() {
                        _selectedAges.contains(a)
                            ? _selectedAges.remove(a)
                            : _selectedAges.add(a);
                      }),
                      onDifficultyToggled: (d) => setState(() {
                        _selectedDifficulties.contains(d)
                            ? _selectedDifficulties.remove(d)
                            : _selectedDifficulties.add(d);
                      }),
                    ),
                  ),
          ),
          _CatalogFooter(),
        ],
      ),
    );
  }
}

// ── Top navigation bar ────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.searchController,
    required this.onSearch,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : 16,
            vertical: 12,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'EduPlay',
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _kNavy,
                  ),
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 32),
                ...[
                  ('Games', true),
                  ('Learn', false),
                  ('Classroom', false),
                  ('Reports', false),
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _NavTab(label: item.$1, selected: item.$2),
                  ),
                ),
              ],
              const SizedBox(width: 16),
              if (isDesktop)
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: _SearchField(
                      controller: searchController,
                      onChanged: onSearch,
                    ),
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: 12),
              Icon(Icons.notifications_outlined,
                  color: Colors.grey[500], size: 22),
              const SizedBox(width: 14),
              Icon(Icons.settings_outlined, color: Colors.grey[500], size: 22),
              const SizedBox(width: 14),
              CircleAvatar(
                radius: 17,
                backgroundColor: _kNavy,
                child: Text(
                  'M',
                  style: GoogleFonts.fredoka(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? _kNavy : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 2,
          width: selected ? 28 : 0,
          decoration: BoxDecoration(
            color: _kNavy,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: GoogleFonts.nunito(fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Search games...',
        hintStyle: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 18),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

// ── Filter panel ──────────────────────────────────────────────────────────────

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.selectedSubject,
    required this.selectedAges,
    required this.selectedDifficulties,
    required this.onSubjectChanged,
    required this.onAgeToggled,
    required this.onDifficultyToggled,
  });

  final GameSubject selectedSubject;
  final Set<AgeRange> selectedAges;
  final Set<Difficulty> selectedDifficulties;
  final ValueChanged<GameSubject> onSubjectChanged;
  final ValueChanged<AgeRange> onAgeToggled;
  final ValueChanged<Difficulty> onDifficultyToggled;

  static const _subjects = [
    (GameSubject.all, 'All Games', Icons.grid_view_rounded),
    (GameSubject.math, 'Math', Icons.calculate_rounded),
    (GameSubject.science, 'Science', Icons.biotech_rounded),
    (GameSubject.history, 'History', Icons.account_balance_rounded),
    (GameSubject.languages, 'Languages', Icons.translate_rounded),
    (GameSubject.logic, 'Logic', Icons.extension_rounded),
    (GameSubject.art, 'Art', Icons.palette_rounded),
    (GameSubject.music, 'Music', Icons.music_note_rounded),
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
                'Catalog',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 20),
              const _FilterSection(label: 'SUBJECT'),
              const SizedBox(height: 10),
              for (final (subject, label, icon) in _subjects)
                _SubjectTile(
                  label: label,
                  icon: icon,
                  selected: selectedSubject == subject,
                  onTap: () => onSubjectChanged(subject),
                ),
              const SizedBox(height: 20),
              const _FilterSection(label: 'AGE RANGE'),
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
              const _FilterSection(label: 'DIFFICULTY'),
              const SizedBox(height: 10),
              for (final (d, label) in [
                (Difficulty.beginner, 'Beginner'),
                (Difficulty.intermediate, 'Intermediate'),
                (Difficulty.advanced, 'Advanced'),
              ])
                _DifficultyCheck(
                  label: label,
                  checked: selectedDifficulties.contains(d),
                  onChanged: (_) => onDifficultyToggled(d),
                ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                  label: Text(
                    'Start Quest',
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

class _MainContent extends StatelessWidget {
  const _MainContent({
    required this.filtered,
    required this.gridView,
    required this.onToggleView,
    this.filterDrawer,
  });

  final List<CatalogGame> filtered;
  final bool gridView;
  final VoidCallback onToggleView;
  final Widget? filterDrawer;

  @override
  Widget build(BuildContext context) {
    final featured = featuredGames;

    return ListView(
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
                  'Popular Learning Games',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                Text(
                  'Curated for Level 12 Explorers',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Sort by:',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
            ),
            const SizedBox(width: 6),
            _SortDropdown(),
            const SizedBox(width: 12),
            _ViewToggle(gridView: gridView, onToggle: onToggleView),
          ],
        ),
        const SizedBox(height: 20),
        // Game grid
        filtered.isEmpty
            ? _EmptyState()
            : gridView
                ? _GameGrid(games: filtered)
                : _GameList(games: filtered),
        const SizedBox(height: 24),
        // Load more
        Center(
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.expand_more_rounded),
            label: Text(
              'Load More Games',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kNavy,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
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

// ── Featured section ──────────────────────────────────────────────────────────

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.featured});

  final List<CatalogGame> featured;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (featured.isEmpty) return const SizedBox.shrink();

    final hero = featured.first;
    final sides = featured.skip(1).take(2).toList();

    if (!isDesktop) {
      return Column(
        children: [
          _HeroCard(game: hero),
          const SizedBox(height: 12),
          for (final g in sides) ...[
            _SideFeaturedCard(game: g),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return SizedBox(
      height: 300,
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
                      onPressed: () => Navigator.pushNamed(context, game.route),
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
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side:
                            const BorderSide(color: Colors.white54, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Detalles',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
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

class _SortDropdown extends StatefulWidget {
  @override
  State<_SortDropdown> createState() => _SortDropdownState();
}

class _SortDropdownState extends State<_SortDropdown> {
  String _value = 'Popular';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _value,
      underline: const SizedBox.shrink(),
      style: GoogleFonts.nunito(
          fontSize: 13, fontWeight: FontWeight.w700, color: _kNavy),
      items: const [
        DropdownMenuItem(value: 'Popular', child: Text('Popular')),
        DropdownMenuItem(value: 'Newest', child: Text('Newest')),
        DropdownMenuItem(value: 'Level', child: Text('Level')),
      ],
      onChanged: (v) => setState(() => _value = v!),
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
    final cols = MediaQuery.of(context).size.width >= 1100
        ? 3
        : MediaQuery.of(context).size.width >= 700
            ? 2
            : 1;

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
                    onPressed: () => Navigator.pushNamed(context, game.route),
                    icon:
                        const Icon(Icons.play_circle_outline_rounded, size: 16),
                    label: Text(
                      'Play',
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
            onPressed: () => Navigator.pushNamed(context, game.route),
            icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
            label: Text(
              'Play',
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

// ── Footer ────────────────────────────────────────────────────────────────────

class _CatalogFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      color: const Color(0xFFEEEDF8),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 24,
        vertical: 28,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _FooterBrand()),
                const Expanded(
                    child: _FooterLinks('Quick Links', [
                  'Teacher Resources',
                  'Parent Guide',
                  'Support Center',
                ])),
                const Expanded(
                    child: _FooterLinks('Legal', [
                  'Privacy Policy',
                  'Terms of Service',
                ])),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '© 2024 EduPlay Learning. All rights reserved.',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[500]),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterBrand(),
                const SizedBox(height: 20),
                const _FooterLinks('Quick Links',
                    ['Teacher Resources', 'Parent Guide', 'Support Center']),
                const SizedBox(height: 16),
                const _FooterLinks(
                    'Legal', ['Privacy Policy', 'Terms of Service']),
              ],
            ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EduPlay',
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Empowering the next generation of explorers\nthrough play-based scholarly excellence.',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.language, size: 16, color: Colors.grey[500]),
            const SizedBox(width: 8),
            Icon(Icons.alternate_email, size: 16, color: Colors.grey[500]),
          ],
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks(this.title, this.links);

  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 10),
        for (final link in links) ...[
          Text(
            link,
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 6),
        ],
      ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF8F7FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class ParentGuidePage extends StatefulWidget {
  const ParentGuidePage({super.key});

  @override
  State<ParentGuidePage> createState() => _ParentGuidePageState();
}

class _ParentGuidePageState extends State<ParentGuidePage> {
  int _filterIndex = 0; // 0=All, 1=Articles, 2=Video Guides, 3=Worksheets
  static const _filters = [
    'All Resources',
    'Articles',
    'Video Guides',
    'Worksheets'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const EduPlayNavBar.parent(activeParentTab: ParentTab.recursos),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero banner
                  const _HeroBanner(),

                  // Library categories
                  _LibrarySection(
                    filterIndex: _filterIndex,
                    filters: _filters,
                    onFilterTap: (i) => setState(() => _filterIndex = i),
                  ),

                  // Screen Time + Teacher Recommendations
                  const _TwoColSection(),

                  // Printable Worksheets
                  const _WorksheetsSection(),

                  // Newsletter
                  const _NewsletterSection(),

                  // Footer
                  const _GuideFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      margin: const EdgeInsets.all(0),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B6A), Color(0xFF2D2A8A)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative blobs
          Positioned(
            top: -30,
            right: isDesktop ? 120 : -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            right: isDesktop ? 60 : -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 56 : 24,
              vertical: isDesktop ? 52 : 36,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text side
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                const Color(0xFFFFD700).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'PARENT RESOURCE CENTER',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Empowering Your Child\'s\nLearning Journey',
                        style: GoogleFonts.fredoka(
                          fontSize: isDesktop ? 36 : 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Access our curated library of expert insights, video tutorials, and\neducational worksheets designed to bridge the gap between\nclassroom and home.',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.auto_stories_rounded,
                                size: 16),
                            label: Text(
                              'Explore Library',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _kRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Latest Updates',
                              style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Art side
                if (isDesktop) ...[
                  const SizedBox(width: 40),
                  const Expanded(
                    flex: 3,
                    child: _HeroArtWidget(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroArtWidget extends StatelessWidget {
  const _HeroArtWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB347), Color(0xFFFF6B9D), Color(0xFF9B59B6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.menu_book_rounded,
              size: 72,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Library section ───────────────────────────────────────────────────────────

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({
    required this.filterIndex,
    required this.filters,
    required this.onFilterTap,
  });

  final int filterIndex;
  final List<String> filters;
  final ValueChanged<int> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final hPad = isDesktop ? 56.0 : 24.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Library Categories',
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      'Browse our expertly curated content streams.',
                      style: GoogleFonts.nunito(
                          fontSize: 13, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              // Filter chips
              Wrap(
                spacing: 8,
                children: List.generate(
                  filters.length,
                  (i) => _FilterChip(
                    label: filters[i],
                    selected: filterIndex == i,
                    onTap: () => onFilterTap(i),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Understanding Progress subsection
          const _SubsectionHeader(
            icon: Icons.insights_rounded,
            title: 'Understanding Progress',
          ),
          const SizedBox(height: 16),

          isDesktop
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _FeaturedArticleCard()),
                    SizedBox(width: 16),
                    Expanded(flex: 4, child: _VideoGuideCard()),
                  ],
                )
              : const Column(
                  children: [
                    _FeaturedArticleCard(),
                    SizedBox(height: 16),
                    _VideoGuideCard(),
                  ],
                ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? _kNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _kNavy : Colors.grey.shade200),
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

class _SubsectionHeader extends StatelessWidget {
  const _SubsectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _kRed),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
      ],
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text side
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ContentTypeBadge(
                        label: 'FEATURED ARTICLE', color: _kNavy),
                    const SizedBox(height: 12),
                    Text(
                      'Decoding the EduPlay Progress Reports',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A comprehensive guide for parents on interpreting skill mastery, adaptive learning curves, and emotional intelligence metrics.',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {},
                      icon: Text(
                        'Read Article',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        ),
                      ),
                      label: const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: _kNavy),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Image placeholder
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Container(
                width: 160,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.laptop_mac_rounded,
                    size: 52,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), // IntrinsicHeight
    );
  }
}

class _VideoGuideCard extends StatelessWidget {
  const _VideoGuideCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video thumbnail
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D3561), Color(0xFF4A4E8C)],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                left: 10,
                child: _ContentTypeBadge(
                    label: 'VIDEO GUIDE', color: Color(0xFF8E44AD)),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: _kNavy, size: 26),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Setting Goals with Your Child',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '5-minute guide on collaborative goal setting.',
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentTypeBadge extends StatelessWidget {
  const _ContentTypeBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: color,
        ),
      ),
    );
  }
}

// ── Two-column section: Screen Time + Teacher Recs ────────────────────────────

class _TwoColSection extends StatelessWidget {
  const _TwoColSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final hPad = isDesktop ? 56.0 : 24.0;

    final screenTimeItems = [
      (
        type: 'ARTICLE',
        tag: '8 min read',
        title: 'The "One-for-One" Activity Rule',
        subtitle:
            'How to balance digital play with physical exercise effectively.',
        icon: Icons.device_unknown_rounded,
        isPdf: false,
      ),
      (
        type: 'PDF',
        tag: '1.2 MB',
        title: 'Family Digital Wellness Contract',
        subtitle:
            'A downloadable template for setting healthy household rules.',
        icon: Icons.nights_stay_rounded,
        isPdf: true,
      ),
    ];

    final teacherItems = [
      (
        type: 'ARTICLE',
        tag: 'Recommended by Ms. Sarah',
        title: 'Top 10 Science Apps for Curiosity',
        subtitle:
            'Curated list of safe, exploratory apps for young scientists.',
        icon: Icons.science_rounded,
        isPdf: false,
      ),
      (
        type: 'VIDEO',
        tag: '12:40 mins',
        title: 'Math Literacy: Home Strategies',
        subtitle:
            'Simple ways to incorporate math into daily household routines.',
        icon: Icons.calculate_rounded,
        isPdf: false,
      ),
    ];

    Widget col1 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubsectionHeader(
            icon: Icons.timer_outlined, title: 'Screen Time Tips'),
        const SizedBox(height: 14),
        for (final item in screenTimeItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ResourceTile(
              type: item.type,
              tag: item.tag,
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              isPdf: item.isPdf,
            ),
          ),
      ],
    );

    Widget col2 = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SubsectionHeader(
            icon: Icons.school_rounded, title: 'Teacher Recommendations'),
        const SizedBox(height: 14),
        for (final item in teacherItems)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ResourceTile(
              type: item.type,
              tag: item.tag,
              title: item.title,
              subtitle: item.subtitle,
              icon: item.icon,
              isPdf: item.isPdf,
            ),
          ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 36),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: col1),
                const SizedBox(width: 24),
                Expanded(child: col2),
              ],
            )
          : Column(
              children: [col1, const SizedBox(height: 32), col2],
            ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({
    required this.type,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPdf = false,
  });

  final String type;
  final String tag;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPdf;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isPdf
                      ? [const Color(0xFF2C3E50), const Color(0xFF3D566E)]
                      : [const Color(0xFF1a1a2e), const Color(0xFF3D3AA0)],
                ),
              ),
              child: Center(
                child: Icon(icon,
                    size: 28, color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _kNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type,
                        style: GoogleFonts.nunito(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _kNavy,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      tag,
                      style: GoogleFonts.nunito(
                          fontSize: 10, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 11, color: Colors.grey[500], height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Printable Worksheets ──────────────────────────────────────────────────────

class _WorksheetsSection extends StatelessWidget {
  const _WorksheetsSection();

  static const _worksheets = [
    (
      subject: 'MATHEMATICS',
      title: 'Addition Garden Maze',
      color: Color(0xFF2ECC71),
      icon: Icons.calculate_rounded
    ),
    (
      subject: 'CREATIVE ARTS',
      title: 'Animal Habitats Coloring',
      color: Color(0xFFE91E63),
      icon: Icons.palette_rounded
    ),
    (
      subject: 'LITERACY',
      title: 'Phonics Flashcard Set',
      color: Color(0xFF3498DB),
      icon: Icons.auto_stories_rounded
    ),
    (
      subject: 'SCIENCE',
      title: 'Weather Observation Log',
      color: Color(0xFFFF9800),
      icon: Icons.wb_sunny_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final hPad = isDesktop ? 56.0 : 24.0;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SubsectionHeader(
                  icon: Icons.print_rounded, title: 'Printable Worksheets'),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All Worksheets',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _kNavy.withValues(alpha: 0.5),
                    decoration: TextDecoration.underline,
                    decorationColor: _kNavy.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 4 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: _worksheets.length,
            itemBuilder: (_, i) {
              final w = _worksheets[i];
              return _WorksheetCard(
                subject: w.subject,
                title: w.title,
                color: w.color,
                icon: w.icon,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({
    required this.subject,
    required this.title,
    required this.color,
    required this.icon,
  });
  final String subject;
  final String title;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview area
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: color.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(icon,
                        size: 44, color: color.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.download_rounded,
                      size: 14, color: Color(0xFF666666)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: GoogleFonts.nunito(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
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

// ── Newsletter ─────────────────────────────────────────────────────────────────

class _NewsletterSection extends StatelessWidget {
  const _NewsletterSection();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      color: _kLavender,
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 56 : 24, vertical: 52),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _kNavy,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.mail_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(height: 20),
              Text(
                'Stay Updated with Weekly Insights',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Join 15,000+ parents who receive our best educational activities\nand parenting tips directly in their inbox every Tuesday.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    fontSize: 13, color: Colors.grey[500], height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Center(
                        child: Text(
                          'Enter your email address',
                          style: GoogleFonts.nunito(
                              fontSize: 13, color: Colors.grey[400]),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kNavy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Subscribe',
                      style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'No spam, only joy. Unsubscribe at any time.',
                style:
                    GoogleFonts.nunito(fontSize: 11, color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _GuideFooter extends StatelessWidget {
  const _GuideFooter();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final hPad = isDesktop ? 56.0 : 24.0;

    return Container(
      color: const Color(0xFF111827),
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EduPlay',
                        style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Building the future of learning through playful exploration and scientific insights.',
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.45),
                            height: 1.5),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: _FooterCol('Resources', [
                    'Teacher Resources',
                    'Parent Guide',
                    'Support',
                  ]),
                ),
                const Expanded(
                  flex: 2,
                  child: _FooterCol('Legal', [
                    'Privacy Policy',
                    'Terms of Service',
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download App',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.apple_rounded,
                                color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Download on the',
                                  style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      color:
                                          Colors.white.withValues(alpha: 0.6)),
                                ),
                                Text(
                                  'App Store',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EduPlay',
                  style: GoogleFonts.fredoka(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                const _FooterCol('Resources',
                    ['Teacher Resources', 'Parent Guide', 'Support']),
                const SizedBox(height: 16),
                const _FooterCol(
                    'Legal', ['Privacy Policy', 'Terms of Service']),
              ],
            ),
          const SizedBox(height: 32),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          Text(
            '© 2024 EduPlay Learning. All rights reserved.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCol extends StatelessWidget {
  const _FooterCol(this.title, this.links);
  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 12),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              link,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
      ],
    );
  }
}

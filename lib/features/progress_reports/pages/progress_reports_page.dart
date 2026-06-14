import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kRed = Color(0xFFC0392B);
const _kLavender = Color(0xFFEEEDF8);
const _kBg = Color(0xFFF8F7FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class ProgressReportsPage extends StatefulWidget {
  const ProgressReportsPage({super.key});

  @override
  State<ProgressReportsPage> createState() => _ProgressReportsPageState();
}

class _ProgressReportsPageState extends State<ProgressReportsPage> {
  List<ChildProfile> _profiles = [];
  int _selectedChild = 0;
  bool _loading = true;

  // Mock weekly minutes per day (Mon–Sun)
  final List<List<int>> _weeklyData = [
    [28, 45, 72, 38, 55, 20, 18], // child 0
    [18, 30, 25, 40, 55, 60, 22], // child 1
    [50, 65, 48, 70, 42, 30, 25], // child 2
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await ChildProfilesService.getProfiles();
    // Pad with demo data if empty
    if (!mounted) return;
    setState(() {
      _profiles = profiles.isNotEmpty
          ? profiles
          : [
              ChildProfile(
                id: 'demo1',
                name: 'Leo',
                age: 8,
                level: 5,
                pin: '0000',
                focusSubject: 'Matemáticas',
                levelProgress: 0.65,
                avatarColorHex: '3498DB',
                lastSeen: 'hace 2h',
              ),
              ChildProfile(
                id: 'demo2',
                name: 'Maya',
                age: 6,
                level: 2,
                pin: '0001',
                focusSubject: 'Idiomas',
                levelProgress: 0.30,
                avatarColorHex: 'E91E63',
                lastSeen: 'Ayer',
              ),
            ];
      _loading = false;
    });
  }

  List<int> get _currentWeek =>
      _selectedChild < _weeklyData.length
          ? _weeklyData[_selectedChild]
          : _weeklyData[0];

  ChildProfile? get _currentProfile =>
      _profiles.isNotEmpty ? _profiles[_selectedChild] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          EduPlayNavBar.parent(activeParentTab: ParentTab.progreso),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          'Progress Reports',
                          style: GoogleFonts.fredoka(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Child selector
                        _ChildSelector(
                          profiles: _profiles,
                          selectedIndex: _selectedChild,
                          onSelect: (i) =>
                              setState(() => _selectedChild = i),
                        ),
                        const SizedBox(height: 28),

                        // Main grid
                        if (_currentProfile != null)
                          _ReportsGrid(
                            profile: _currentProfile!,
                            weeklyMinutes: _currentWeek,
                          ),

                        const SizedBox(height: 40),

                        // Footer
                        _ReportsFooter(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Child selector ────────────────────────────────────────────────────────────

class _ChildSelector extends StatelessWidget {
  const _ChildSelector({
    required this.profiles,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<ChildProfile> profiles;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < profiles.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == i
                        ? _kNavy
                        : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selectedIndex == i
                          ? _kNavy
                          : Colors.grey.shade200,
                    ),
                    boxShadow: selectedIndex == i
                        ? [
                            BoxShadow(
                              color: _kNavy.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: profiles[i]
                            .avatarColor
                            .withValues(alpha: 0.2),
                        child: Text(
                          profiles[i].name[0].toUpperCase(),
                          style: GoogleFonts.fredoka(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: profiles[i].avatarColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profiles[i].name,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selectedIndex == i
                                  ? Colors.white
                                  : _kNavy,
                            ),
                          ),
                          Text(
                            profiles[i].focusSubject.toUpperCase(),
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: selectedIndex == i
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Add child button
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.grey.shade200, style: BorderStyle.solid),
                color: Colors.white,
              ),
              child: Icon(Icons.add_rounded,
                  size: 20, color: Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reports grid ──────────────────────────────────────────────────────────────

class _ReportsGrid extends StatelessWidget {
  const _ReportsGrid({
    required this.profile,
    required this.weeklyMinutes,
  });

  final ChildProfile profile;
  final List<int> weeklyMinutes;

  int get _totalMinutes => weeklyMinutes.fold(0, (a, b) => a + b);

  String get _totalTimeLabel {
    final h = _totalMinutes ~/ 60;
    final m = _totalMinutes % 60;
    return '${h}.${(m / 60 * 10).round()}h';
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    if (isDesktop) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: _LearningTimeCard(
                    weeklyMinutes: weeklyMinutes,
                    totalLabel: _totalTimeLabel),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: _SoftSkillsCard(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: _SubjectMasteryCard(profile: profile),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: _RecentActivityCard(),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        _LearningTimeCard(
            weeklyMinutes: weeklyMinutes, totalLabel: _totalTimeLabel),
        const SizedBox(height: 20),
        _SoftSkillsCard(),
        const SizedBox(height: 20),
        _SubjectMasteryCard(profile: profile),
        const SizedBox(height: 20),
        _RecentActivityCard(),
      ],
    );
  }
}

// ── Learning Time card ────────────────────────────────────────────────────────

class _LearningTimeCard extends StatelessWidget {
  const _LearningTimeCard({
    required this.weeklyMinutes,
    required this.totalLabel,
  });
  final List<int> weeklyMinutes;
  final String totalLabel;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final maxMinutes =
        weeklyMinutes.reduce((a, b) => a > b ? a : b).toDouble();
    final maxIdx = weeklyMinutes.indexOf(
        weeklyMinutes.reduce((a, b) => a > b ? a : b));
    final totalMins =
        weeklyMinutes.fold(0, (a, b) => a + b);
    final dailyAvg = (totalMins / 7).round();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Time',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      'Daily minutes spent on EduPlay this week',
                      style: GoogleFonts.nunito(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _kLavender,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Weekly',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bar chart
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final frac =
                    maxMinutes > 0 ? weeklyMinutes[i] / maxMinutes : 0.0;
                final isMax = i == maxIdx;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              width: double.infinity,
                              height: max(8, frac * 120),
                              decoration: BoxDecoration(
                                color: isMax
                                    ? _kNavy
                                    : _kNavy.withValues(alpha: 0.18),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _days[i],
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: isMax
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isMax ? _kNavy : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _StatPill(
                      label: 'Total this week',
                      value: totalLabel,
                      valueColor: _kNavy)),
              Expanded(
                  child: _StatPill(
                      label: 'vs last week',
                      value: '+15%',
                      valueColor: const Color(0xFF2ECC71))),
              Expanded(
                  child: _StatPill(
                      label: 'Daily avg',
                      value: '${dailyAvg}m',
                      valueColor: _kNavy)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill(
      {required this.label,
      required this.value,
      required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

// ── Soft Skills card ──────────────────────────────────────────────────────────

class _SoftSkillsCard extends StatelessWidget {
  const _SoftSkillsCard();

  static const _skills = [
    (label: 'Problem Solving', pct: 0.88, color: Color(0xFFD4A017)),
    (label: 'Creativity', pct: 0.72, color: Color(0xFFC0392B)),
    (label: 'Collaboration', pct: 0.65, color: Color(0xFF1E1B6A)),
    (label: 'Focus', pct: 0.94, color: Color(0xFF9B8DC4)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soft Skills',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          Text(
            'Development in behavioral milestones',
            style: GoogleFonts.nunito(
                fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          for (final s in _skills) ...[
            _SkillRow(
                label: s.label, pct: s.pct, color: s.color),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow(
      {required this.label, required this.pct, required this.color});
  final String label;
  final double pct;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
            ),
            Text(
              '${(pct * 100).toInt()}%',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ── Subject Mastery card ──────────────────────────────────────────────────────

class _SubjectMasteryCard extends StatelessWidget {
  const _SubjectMasteryCard({required this.profile});
  final ChildProfile profile;

  static const _subjects = [
    (icon: Icons.calculate_rounded, name: 'Mathematics', focus: 'Focus: Multi-digit subtraction', grade: 'Grade A (92%)', color: Color(0xFFE74C3C)),
    (icon: Icons.menu_book_rounded, name: 'Language Arts', focus: 'Focus: Adjectives & Adverbs', grade: 'Grade B+ (84%)', color: Color(0xFF2ECC71)),
    (icon: Icons.science_rounded, name: 'Logic & Science', focus: 'Focus: Water Cycle Basics', grade: 'Grade A- (89%)', color: Color(0xFF9B59B6)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Mastery',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            ),
          ),
          Text(
            'Curriculum progress and accuracy',
            style: GoogleFonts.nunito(
                fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          for (final s in _subjects)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(s.icon, size: 20, color: s.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _kNavy,
                            ),
                          ),
                          Text(
                            s.focus,
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      s.grade,
                      style: GoogleFonts.fredoka(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Recent Activity card ──────────────────────────────────────────────────────

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  static const _activities = [
    (game: 'Space Math Explorers', score: '1,450', tag: 'Level 4 Completed', tagColor: Color(0xFF2ECC71), time: '2h ago', isNew: true),
    (game: 'Word Wizardry', score: '890', tag: 'Spelling Quest', tagColor: Color(0xFF9B59B6), time: 'Yesterday', isNew: false),
    (game: 'Logic Labyrinth', score: '2,100', tag: 'Daily Challenge', tagColor: Color(0xFF3498DB), time: 'Oct 12', isNew: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Recent Activity',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View History',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                    decoration: TextDecoration.underline,
                    decorationColor: _kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final a in _activities)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Game icon
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _kNavy,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sports_esports_rounded,
                            color: Colors.white54, size: 26),
                      ),
                      if (a.isNew)
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: const BoxDecoration(
                              color: _kRed,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              'New!',
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.game,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kNavy,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Score: ${a.score}',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: a.tagColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                a.tag,
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: a.tagColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    a.time,
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _ReportsFooter extends StatelessWidget {
  const _ReportsFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _kLavender,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Empowering students through play-based learning and providing parents with the insights they need to support growth.',
                      style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _FooterCol('Platform', [
                  'Teacher Resources',
                  'Parent Guide',
                  'Support',
                ]),
              ),
              Expanded(
                flex: 2,
                child: _FooterCol('Legal', [
                  'Privacy Policy',
                  'Terms of Service',
                ]),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.share_rounded,
                        size: 18, color: Colors.grey[500]),
                    const SizedBox(width: 16),
                    Icon(Icons.mail_outline_rounded,
                        size: 18, color: Colors.grey[500]),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '© 2024 EduPlay Learning. All rights reserved.',
            style: GoogleFonts.nunito(
                fontSize: 11, color: Colors.grey[400]),
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
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 10),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              link,
              style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: _kNavy.withValues(alpha: 0.7)),
            ),
          ),
      ],
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration() => BoxDecoration(
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
    );

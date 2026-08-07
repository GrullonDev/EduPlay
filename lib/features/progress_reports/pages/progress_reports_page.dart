import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kGreen = Color(0xFF27AE60);
const _kBg = Color(0xFFF8F7FF);

// ── Entry point ───────────────────────────────────────────────────────────────

class ProgressReportsPage extends StatefulWidget {
  const ProgressReportsPage({super.key});

  @override
  State<ProgressReportsPage> createState() => _ProgressReportsPageState();
}

class _ProgressReportsPageState extends State<ProgressReportsPage> {
  List<ChildProfile> _profiles = [];
  List<PracticeSession> _sessions = [];
  Map<String, ChildGameplayStats> _stats = {};
  String _parentName = 'Mamá';
  int _selectedChild = 0; // index into _profiles; -1 = all children
  bool _loadingProfiles = true;
  bool _loadingSessions = true;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadProfilesThenStats();
    _loadSessions();
    _loadParentName();
  }

  Future<void> _loadParentName() async {
    final name = await ChildProfilesService.getParentName();
    if (!mounted) return;
    setState(() => _parentName = name);
  }

  Future<void> _loadProfilesThenStats() async {
    final profiles = await ChildProfilesService.getProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _loadingProfiles = false;
    });
    final stats = await ParentChildStatsService.loadStatsForProfiles(profiles);
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _loadingStats = false;
    });
  }

  Future<void> _loadSessions() async {
    final sessions = await PracticeSessionsService.getAllSessions();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loadingSessions = false;
    });
  }

  // ── Derived data ──────────────────────────────────────────────────────────

  String get _selectedName =>
      _profiles.isEmpty ? 'Todos' : _profiles[_selectedChild].name;

  String get _selectedProfileId =>
      _profiles.isEmpty ? '' : _profiles[_selectedChild].id;

  /// Kiosk (PIN) sessions filtered by the selected child profile.
  List<PracticeSession> get _filtered {
    if (_profiles.isEmpty) return _sessions;
    return _sessions
        .where((s) => s.childProfileId == _selectedProfileId)
        .toList();
  }

  /// Real gameplay stats for the selected child (or aggregated across all
  /// children when none is selected), sourced from `students/{id}`.
  List<ChildGameplayStats> get _selectedStats {
    if (_profiles.isEmpty) return const [];
    return [_stats[_selectedProfileId] ?? ChildGameplayStats.empty];
  }

  List<ChildScoreEntry> get _recentScores =>
      _selectedStats.expand((s) => s.recentScores).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  int get _totalGamesPlayed => _recentScores.length;

  int get _totalScore =>
      _recentScores.fold(0, (sum, e) => sum + e.score);

  int get _streak =>
      _selectedStats.isEmpty ? 0 : _selectedStats.first.streak;

  /// Map of gameTitle → total score across recent scores.
  Map<String, int> get _gameScores {
    final map = <String, int>{};
    for (final entry in _recentScores) {
      map[entry.gameTitle] = (map[entry.gameTitle] ?? 0) + entry.score;
    }
    return map;
  }

  /// Average score per completed game.
  double get _avgScore {
    if (_recentScores.isEmpty) return 0;
    return _totalScore / _recentScores.length;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingProfiles || _loadingSessions || _loadingStats;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          EduPlayNavBar.parent(
              activeParentTab: ParentTab.progreso, parentName: _parentName),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final s = ScreenSize.fromConstraints(constraints);
                      final hPad =
                          s.when(mobile: 16.0, tablet: 24.0, desktop: 40.0);
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: hPad, vertical: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Header ─────────────────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Informes de Progreso',
                                        style: GoogleFonts.fredoka(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: _kNavy,
                                        ),
                                      ),
                                      Text(
                                        'Actividad real de juego de tus hijos.',
                                        style: GoogleFonts.nunito(
                                            fontSize: 13,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _loadProfilesThenStats();
                                    _loadSessions();
                                  },
                                  icon: const Icon(Icons.refresh_rounded,
                                      size: 16),
                                  label: Text('Actualizar',
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _kNavy,
                                    side:
                                        BorderSide(color: Colors.grey.shade300),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // ── Child selector ─────────────────────────────────
                            if (_profiles.isNotEmpty) ...[
                              _ChildSelector(
                                profiles: _profiles,
                                selectedIndex: _selectedChild,
                                onSelect: (i) =>
                                    setState(() => _selectedChild = i),
                              ),
                              const SizedBox(height: 28),
                            ],

                            // ── Summary stats ──────────────────────────────────
                            _StatRow(
                              gamesPlayed: _totalGamesPlayed,
                              streak: _streak,
                              totalScore: _totalScore,
                              avgScore: _avgScore,
                            ),
                            const SizedBox(height: 28),

                            // ── Top games breakdown ────────────────────────────
                            if (_gameScores.isNotEmpty) ...[
                              const _SectionLabel('Juegos con más puntos'),
                              const SizedBox(height: 16),
                              _GameScoreChart(scores: _gameScores),
                              const SizedBox(height: 28),
                            ],

                            // ── Recent activity ────────────────────────────────
                            _SectionLabel(
                                'Actividad reciente — $_selectedName'),
                            const SizedBox(height: 16),
                            _recentScores.isEmpty
                                ? const _EmptyActivityState()
                                : _RecentActivityList(entries: _recentScores),
                            const SizedBox(height: 28),

                            // ── Kiosk (PIN) session history ────────────────────
                            _SectionLabel(
                                'Historial de sesiones con PIN — $_selectedName'),
                            const SizedBox(height: 16),
                            _filtered.isEmpty
                                ? _EmptyState()
                                : _SessionHistoryList(sessions: _filtered),

                            const SizedBox(height: 40),
                          ],
                        ),
                      );
                    },
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selectedIndex == i ? _kNavy : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selectedIndex == i ? _kNavy : Colors.grey.shade200,
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
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          profiles[i].avatarColor.withValues(alpha: 0.2),
                      child: Text(
                        profiles[i].name[0].toUpperCase(),
                        style: GoogleFonts.fredoka(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: profiles[i].avatarColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      profiles[i].name,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selectedIndex == i ? Colors.white : _kNavy,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Summary stat row ──────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.gamesPlayed,
    required this.streak,
    required this.totalScore,
    required this.avgScore,
  });

  final int gamesPlayed;
  final int streak;
  final int totalScore;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          icon: Icons.videogame_asset_rounded,
          label: 'Juegos jugados',
          value: '$gamesPlayed',
          sub: 'últimos 28 días',
          color: const Color(0xFF9B59B6),
        ),
        _StatCard(
          icon: Icons.local_fire_department_rounded,
          label: 'Racha',
          value: streak == 1 ? '1 día' : '$streak días',
          sub: streak > 0 ? 'seguidos jugando' : 'Sin racha activa',
          color: const Color(0xFFF39C12),
        ),
        _StatCard(
          icon: Icons.stars_rounded,
          label: 'Puntuación total',
          value: '$totalScore pts',
          sub: avgScore > 0
              ? '~${avgScore.toStringAsFixed(0)} por juego'
              : 'Sin datos aún',
          color: _kCoral,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
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
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 12),
          Text(value,
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700])),
          Text(sub,
              style: GoogleFonts.nunito(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

// ── Game score chart (horizontal bars) ───────────────────────────────────────

class _GameScoreChart extends StatelessWidget {
  const _GameScoreChart({required this.scores});
  final Map<String, int> scores;

  static const _colors = [
    Color(0xFF1E1B6A),
    Color(0xFFFF6E6C),
    Color(0xFF9B59B6),
    Color(0xFF27AE60),
    Color(0xFFF39C12),
    Color(0xFF2980B9),
    Color(0xFFE74C3C),
    Color(0xFF16A085),
    Color(0xFF8E44AD),
    Color(0xFF2C3E50),
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxScore = sorted.first.value.toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
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
        children: sorted.asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          final fraction = maxScore > 0 ? entry.value / maxScore : 0.0;
          final label = entry.key;
          final color = _colors[i % _colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              SizedBox(
                width: 160,
                child: Text(label,
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _kNavy),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 12,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                child: Text('${entry.value} pts',
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600]),
                    textAlign: TextAlign.right),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

// ── Session history list ──────────────────────────────────────────────────────

class _SessionHistoryList extends StatelessWidget {
  const _SessionHistoryList({required this.sessions});
  final List<PracticeSession> sessions;

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
        children: sessions.asMap().entries.map((e) {
          final i = e.key;
          final s = e.value;
          return _SessionHistoryTile(
            session: s,
            isLast: i == sessions.length - 1,
          );
        }).toList(),
      ),
    );
  }
}

class _SessionHistoryTile extends StatelessWidget {
  const _SessionHistoryTile({
    required this.session,
    required this.isLast,
  });

  final PracticeSession session;
  final bool isLast;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat('d MMM yyyy', 'es').format(dt);
  }

  int get _sessionTotal => session.scoreMap.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              // Status dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: session.isActive ? _kGreen : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              // Child + date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(session.childName,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          )),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: session.isActive
                              ? _kGreen.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          session.isActive ? 'Activa' : 'Finalizada',
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                session.isActive ? _kGreen : Colors.grey[500],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDate(session.createdAt)}  ·  PIN ${session.pin}',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              // Progress + score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${session.completedCount}/${session.totalCount} juegos',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _kNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_sessionTotal pts',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: Color(0xFFF3F4F6)),
      ],
    );
  }
}

// ── Recent activity (real gameplay) ─────────────────────────────────────────

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.entries});
  final List<ChildScoreEntry> entries;

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Hoy';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return DateFormat('d MMM yyyy', 'es').format(dt);
  }

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
        children: entries.take(10).toList().asMap().entries.map((e) {
          final i = e.key;
          final entry = e.value;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _kNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.videogame_asset_rounded,
                          size: 16, color: _kNavy),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.gameTitle,
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _kNavy,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            '${entry.subjectLabel} · ${_formatDate(entry.date)}',
                            style: GoogleFonts.nunito(
                                fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    Text('${entry.score} pts',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kNavy,
                        )),
                  ],
                ),
              ),
              if (i < entries.take(10).length - 1)
                const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyActivityState extends StatelessWidget {
  const _EmptyActivityState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.videogame_asset_outlined,
              size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Sin actividad de juego aún',
              style:
                  GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(
            'Cuando tu hijo juegue y gane puntos,\nsu actividad aparecerá aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Empty state (kiosk sessions) ────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Sin sesiones con PIN registradas aún',
              style:
                  GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(
            'Cuando tu hijo complete una sesión con PIN,\nsu historial aparecerá aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.fredoka(
            fontSize: 18, fontWeight: FontWeight.w700, color: _kNavy));
  }
}

import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/practice_session/services/practice_sessions_service.dart';
import 'package:edu_play/shared/widgets/edu_play_nav_bar.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDk = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kGreen = Color(0xFF27AE60);
const _kBg = Color(0xFFF8F7FF);
const _kLavender = Color(0xFFEEEDF8);

// ── Entry point ───────────────────────────────────────────────────────────────

class ProgressReportsPage extends StatefulWidget {
  const ProgressReportsPage({super.key});

  @override
  State<ProgressReportsPage> createState() => _ProgressReportsPageState();
}

class _ProgressReportsPageState extends State<ProgressReportsPage> {
  List<ChildProfile> _profiles = [];
  List<PracticeSession> _sessions = [];
  int _selectedChild = 0; // index into _profiles; -1 = all children
  bool _loadingProfiles = true;
  bool _loadingSessions = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _loadSessions();
  }

  Future<void> _loadProfiles() async {
    final profiles = await ChildProfilesService.getProfiles();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _loadingProfiles = false;
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

  /// Sessions filtered by the selected child profile.
  List<PracticeSession> get _filtered {
    if (_profiles.isEmpty) return _sessions;
    return _sessions
        .where((s) => s.childProfileId == _selectedProfileId)
        .toList();
  }

  int get _totalSessions => _filtered.length;

  int get _completedSessions => _filtered.where((s) => s.isCompleted).length;

  int get _totalGamesPlayed =>
      _filtered.fold(0, (sum, s) => sum + s.completedCount);

  int get _totalScore => _filtered.fold(
      0, (sum, s) => s.scoreMap.values.fold(sum, (a, b) => a + b));

  /// Map of gameId → total score across all sessions.
  Map<String, int> get _gameScores {
    final map = <String, int>{};
    for (final s in _filtered) {
      for (final entry in s.scoreMap.entries) {
        map[entry.key] = (map[entry.key] ?? 0) + entry.value;
      }
    }
    return map;
  }

  /// Average score per session (only sessions with at least one game).
  double get _avgScore {
    final played = _filtered.where((s) => s.scoreMap.isNotEmpty).toList();
    if (played.isEmpty) return 0;
    final total = played.fold(
        0, (sum, s) => sum + s.scoreMap.values.fold(0, (a, b) => a + b));
    return total / played.length;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _loadingProfiles || _loadingSessions;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const EduPlayNavBar.parent(activeParentTab: ParentTab.progreso),
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
                                        'Actividad real registrada en sesiones de práctica.',
                                        style: GoogleFonts.nunito(
                                            fontSize: 13,
                                            color: Colors.grey[500]),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    _loadProfiles();
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
                              sessions: _totalSessions,
                              completed: _completedSessions,
                              gamesPlayed: _totalGamesPlayed,
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

                            // ── Session history ────────────────────────────────
                            _SectionLabel(
                                'Historial de sesiones — $_selectedName'),
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
    required this.sessions,
    required this.completed,
    required this.gamesPlayed,
    required this.totalScore,
    required this.avgScore,
  });

  final int sessions;
  final int completed;
  final int gamesPlayed;
  final int totalScore;
  final double avgScore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _StatCard(
          icon: Icons.play_circle_outline_rounded,
          label: 'Sesiones',
          value: '$sessions',
          sub: '$completed completadas',
          color: _kNavy,
        ),
        _StatCard(
          icon: Icons.videogame_asset_rounded,
          label: 'Juegos jugados',
          value: '$gamesPlayed',
          sub: 'en todas las sesiones',
          color: const Color(0xFF9B59B6),
        ),
        _StatCard(
          icon: Icons.stars_rounded,
          label: 'Puntuación total',
          value: '$totalScore pts',
          sub: avgScore > 0
              ? '~${avgScore.toStringAsFixed(0)} por sesión'
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

  static const _labels = {
    'math-adventure': 'Aventura Matemática',
    'magic-words': 'Palabras Mágicas',
    'fun-english': 'Inglés Divertido',
    'nature-explorers': 'Exploradores Naturales',
    'time-travel': 'Viaje en el Tiempo',
    'treasure-map': 'Mapa del Tesoro',
    'artists-in-action': 'Artistas en Acción',
    'color-concert': 'Concierto de Colores',
    'sports-challenge': 'Reto Deportivo',
    'sticker-album': 'Álbum de Pegatinas',
  };

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
          final label = _labels[entry.key] ?? entry.key;
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

// ── Empty state ───────────────────────────────────────────────────────────────

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
          Text('Sin sesiones registradas aún',
              style:
                  GoogleFonts.fredoka(fontSize: 18, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(
            'Cuando tu hijo complete una sesión de práctica,\nel progreso aparecerá aquí.',
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

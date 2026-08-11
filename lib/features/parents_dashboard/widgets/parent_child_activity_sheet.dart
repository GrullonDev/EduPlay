import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kAmber = Color(0xFFD97706);

class ParentChildActivitySheet extends StatelessWidget {
  ParentChildActivitySheet({
    super.key,
    required this.profile,
    required this.stats,
    PracticeSessionsRepository? practiceSessionsRepository,
  }) : _practiceSessionsRepository =
            practiceSessionsRepository ?? sl<PracticeSessionsRepository>();

  final ChildProfile profile;
  final ChildGameplayStats? stats;
  final PracticeSessionsRepository _practiceSessionsRepository;

  int get _level => stats?.level ?? profile.level;

  double get _levelProgress => stats?.levelProgress ?? profile.levelProgress;

  String get _levelLabel => 'Nivel ${_level.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StreamBuilder<List<PracticeSession>>(
            stream: _practiceSessionsRepository.watchAllSessionsByChild(
              profile.id,
            ),
            builder: (context, snap) {
              final sessions = snap.data ?? [];
              final activeSessions = sessions.where((s) => s.isActive).toList();

              return ListView(
                controller: scrollCtrl,
                padding: EdgeInsets.zero,
                children: [
                  _ActivityHeader(
                    profile: profile,
                    levelLabel: _levelLabel,
                    levelProgress: _levelProgress,
                  ),
                  const SizedBox(height: 20),
                  _StatsSummary(
                    stats: stats,
                    activeSessionsCount: activeSessions.length,
                  ),
                  const SizedBox(height: 24),
                  _RecentActivity(stats: stats),
                  const SizedBox(height: 12),
                  if (activeSessions.isNotEmpty) ...[
                    const _SectionTitle('SESIONES ACTIVAS'),
                    ...activeSessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _SessionDetailRow(session: s),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _SectionTitle(
                    sessions.isEmpty
                        ? 'HISTORIAL'
                        : 'HISTORIAL (${sessions.length})',
                  ),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: _kNavy),
                      ),
                    )
                  else if (sessions.isEmpty)
                    const _EmptySessionsState()
                  else
                    ...sessions.map(
                      (s) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                        child: _SessionDetailRow(session: s),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader({
    required this.profile,
    required this.levelLabel,
    required this.levelProgress,
  });

  final ChildProfile profile;
  final String levelLabel;
  final double levelProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kNavy, Color(0xFF3A36A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: profile.avatarColor.withValues(alpha: 0.25),
                child: Text(
                  profile.name[0].toUpperCase(),
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.fredoka(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${profile.focusSubject} - $levelLabel',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white70,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso de Nivel',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(levelProgress * 100).toInt()}%',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSummary extends StatelessWidget {
  const _StatsSummary({
    required this.stats,
    required this.activeSessionsCount,
  });

  final ChildGameplayStats? stats;
  final int activeSessionsCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('RESUMEN', horizontalPadding: 0),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActivityStat(
                icon: Icons.local_fire_department_rounded,
                value: '${stats?.streak ?? 0}',
                label: 'Racha\n(dias)',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 12),
              _ActivityStat(
                icon: Icons.sports_esports_rounded,
                value: '${stats?.gamesPlayedCount ?? 0}',
                label: 'Juegos\njugados',
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 12),
              _ActivityStat(
                icon: Icons.star_rounded,
                value: (stats?.gamesPlayedCount ?? 0) == 0
                    ? '-'
                    : '${stats!.recentAverage.round()}',
                label: 'Puntuacion\npromedio',
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 12),
              _ActivityStat(
                icon: Icons.play_circle_rounded,
                value: '$activeSessionsCount',
                label: 'Sesiones\nactivas',
                color: _kCoral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.stats});

  final ChildGameplayStats? stats;

  @override
  Widget build(BuildContext context) {
    final recentScores = stats?.recentScores ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('ACTIVIDAD RECIENTE'),
        if (recentScores.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Aun no ha jugado ningun juego.',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
            ),
          )
        else
          ...recentScores.take(5).map(
                (e) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.gameTitle,
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy,
                          ),
                        ),
                      ),
                      Text(
                        '${e.score} pts',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.horizontalPadding = 20});

  final String text;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 12),
      child: Text(
        text,
        style: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: _kAmber,
        ),
      ),
    );
  }
}

class _EmptySessionsState extends StatelessWidget {
  const _EmptySessionsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Aun no hay sesiones asignadas',
            style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

class _ActivityStat extends StatelessWidget {
  const _ActivityStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: _kNavy,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.grey[500],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionDetailRow extends StatelessWidget {
  const _SessionDetailRow({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final scores = session.scoreMap.values.toList();
    final avg = scores.isEmpty
        ? null
        : (scores.reduce((a, b) => a + b) / scores.length).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
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
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: session.isActive
                  ? const Color(0xFF2ECC71)
                  : (session.isCompleted
                      ? const Color(0xFF6366F1)
                      : Colors.grey[300]!),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.isActive
                      ? 'Sesion activa'
                      : (session.isCompleted ? 'Completada' : 'En progreso'),
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.completedCount} / ${session.totalCount} juegos completados',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (avg != null)
                Text(
                  '$avg pts',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              const SizedBox(height: 4),
              SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: session.progressFraction,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFF3F4F6),
                    color:
                        session.isCompleted ? const Color(0xFF6366F1) : _kCoral,
                  ),
                ),
              ),
              Text(
                '${(session.progressFraction * 100).toInt()}%',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

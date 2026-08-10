import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/games_catalog/models/catalog_game.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';
import 'package:edu_play/features/progress_recommendations/services/progress_recommendations_service.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFE53935);
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

class StudentNeedsPracticeSection extends StatelessWidget {
  const StudentNeedsPracticeSection({
    super.key,
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

class StudentPracticeSessionsSection extends StatefulWidget {
  const StudentPracticeSessionsSection(
      {super.key,
      required this.childId,
      PracticeSessionsRepository? repository})
      : _repository = repository;
  final String childId;
  final PracticeSessionsRepository? _repository;

  @override
  State<StudentPracticeSessionsSection> createState() =>
      StudentPracticeSessionsSectionState();
}

class StudentPracticeSessionsSectionState
    extends State<StudentPracticeSessionsSection> {
  List<PracticeSession> _sessions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      init();
      final repository = widget._repository ?? sl<PracticeSessionsRepository>();
      final sessions = await repository.getActiveSessionsByChildId(
        widget.childId,
      );
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

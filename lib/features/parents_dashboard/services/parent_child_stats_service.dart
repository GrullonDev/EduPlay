import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/utils/injection_container.dart';

/// A single completed-game entry from `students/{studentId}/scores`.
class ChildScoreEntry {
  const ChildScoreEntry({
    required this.studentId,
    required this.gameTitle,
    required this.subjectKey,
    required this.subjectLabel,
    required this.score,
    required this.date,
  });

  final String studentId;
  final String gameTitle;
  final String subjectKey;
  final String subjectLabel;
  final int score;
  final DateTime date;
}

/// Real gamification stats for one child, sourced from `students/{id}`
/// (points/streak, kept in sync by every mini-game via
/// `StudentRepository.recordScore`) rather than the parent-initiated
/// `practice_sessions` kiosk flow, which most children never go through.
class ChildGameplayStats {
  const ChildGameplayStats({
    required this.studentId,
    required this.points,
    required this.streak,
    required this.recentScores,
  });

  static const empty = ChildGameplayStats(
    studentId: '',
    points: 0,
    streak: 0,
    recentScores: [],
  );

  final String studentId;
  final int points;
  final int streak;

  /// Sorted newest-first.
  final List<ChildScoreEntry> recentScores;

  int get level => StudentRepository.levelForPoints(points);

  double get levelProgress => StudentRepository.xpProgress(points);

  int get gamesPlayedCount => recentScores.length;

  double get recentAverage {
    if (recentScores.isEmpty) return 0;
    final total = recentScores.fold<int>(0, (sum, e) => sum + e.score);
    return total / recentScores.length;
  }

  String? get lastGameTitle =>
      recentScores.isEmpty ? null : recentScores.first.gameTitle;

  DateTime? get lastPlayedAt =>
      recentScores.isEmpty ? null : recentScores.first.date;
}

/// Loads real gameplay stats (points, streak, recent per-game scores) for a
/// parent's whole roster of children in one round-trip, keyed by
/// [ChildProfile.id] — which is guaranteed equal to the `students/{id}`
/// document id (see `StudentDashboardBloc._load()`, which calls
/// `setActiveStudentId(childProfile.id)`/`ensureProfileForId(studentId:
/// childProfile.id, ...)`).
class ParentChildStatsService {
  static Future<Map<String, ChildGameplayStats>> loadStatsForProfiles(
    List<ChildProfile> profiles, {
    int days = 28,
  }) async {
    final ids = profiles.map((p) => p.id).toList();
    if (ids.isEmpty) return {};

    final repo = sl<StudentRepository>();
    final results = await Future.wait([
      repo.getStudentsByIds(ids),
      repo.getRecentScoresForStudents(ids, days: days),
    ]);

    final studentDocs = results[0];
    final scoreDocs = results[1];

    final scoresByStudent = <String, List<ChildScoreEntry>>{};
    for (final doc in scoreDocs) {
      final studentId = doc['studentId'] as String?;
      final date = doc['date'];
      if (studentId == null || date == null) continue;
      final resolvedDate = date is DateTime ? date : date.toDate();
      (scoresByStudent[studentId] ??= []).add(
        ChildScoreEntry(
          studentId: studentId,
          gameTitle: doc['gameTitle'] as String? ?? '',
          subjectKey: doc['subjectKey'] as String? ?? '',
          subjectLabel: doc['subjectLabel'] as String? ?? '',
          score: (doc['score'] as num?)?.toInt() ?? 0,
          date: resolvedDate,
        ),
      );
    }
    for (final entries in scoresByStudent.values) {
      entries.sort((a, b) => b.date.compareTo(a.date));
    }

    final pointsById = {
      for (final doc in studentDocs) doc['id'] as String: doc,
    };

    return {
      for (final id in ids)
        id: ChildGameplayStats(
          studentId: id,
          points: (pointsById[id]?['points'] as num?)?.toInt() ?? 0,
          streak: (pointsById[id]?['streak'] as num?)?.toInt() ?? 0,
          recentScores: scoresByStudent[id] ?? const [],
        ),
    };
  }
}

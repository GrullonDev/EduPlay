import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/shared/data/subject_catalog.dart';

/// Average performance for a subject over the last 7 days, plus the
/// previous 7 days for trend comparison.
class SubjectPerformance {
  const SubjectPerformance({
    required this.subject,
    required this.averageScore,
    required this.previousAverageScore,
    required this.hasData,
  });

  final Subject subject;
  final double averageScore;
  final double previousAverageScore;
  final bool hasData;

  /// Average score expressed as a 0-100 percentage. Each correct answer
  /// typically awards ~10 points, so the raw average is a reasonable
  /// proxy for a percentage once clamped.
  double get percentage => averageScore.clamp(0, 100);

  double get trendDelta => percentage - previousAverageScore.clamp(0, 100);
}

class StudentRepository {
  StudentRepository({required StudentDatasource datasource})
      : _datasource = datasource;

  final StudentDatasource _datasource;

  static int levelForPoints(int points) => (points ~/ 100) + 1;

  static int xpIntoLevel(int points) => points % 100;

  static double xpProgress(int points) => xpIntoLevel(points) / 100.0;

  Future<void> setActiveStudentId(String studentId) =>
      _datasource.setStudentId(studentId);

  Future<void> ensureProfile({
    required String name,
    required int age,
    String? avatar,
  }) async {
    final id = await _datasource.getOrCreateStudentId();
    await _datasource.ensureProfile(
      studentId: id,
      name: name,
      age: age,
      avatar: avatar,
    );
  }

  Future<void> ensureProfileForId({
    required String studentId,
    required String name,
    required int age,
    String? avatar,
  }) {
    return _datasource.ensureProfile(
      studentId: studentId,
      name: name,
      age: age,
      avatar: avatar,
    );
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final id = await _datasource.getOrCreateStudentId();
    return _datasource.getProfile(id);
  }

  Future<String> getMyStudentId() => _datasource.getOrCreateStudentId();

  Future<Map<String, dynamic>?> getStudentProfile(String studentId) =>
      _datasource.getProfile(studentId);

  Future<void> recordScore({
    required String subjectKey,
    required String gameTitle,
    required int score,
  }) async {
    final id = await _datasource.getOrCreateStudentId();
    final subject = subjectByKey(subjectKey);
    await _datasource.recordScore(
      studentId: id,
      subjectKey: subjectKey,
      subjectLabel: subject.label,
      gameTitle: gameTitle,
      score: score,
    );
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) =>
      _datasource.getLeaderboard(limit: limit);

  Future<List<Map<String, dynamic>>> getAllStudents() =>
      _datasource.getAllStudents();

  Future<List<Map<String, dynamic>>> getStudentsByIds(List<String> ids) =>
      _datasource.getStudentsByIds(ids);

  Future<List<Map<String, dynamic>>> getRecentScoresForStudents(
    List<String> studentIds, {
    int days = 28,
  }) =>
      _datasource.getRecentScoresForStudents(studentIds, days: days);

  /// Total score per week for the last [weeks] weeks, oldest first.
  Future<List<double>> getWeeklyScoreTotals({int weeks = 4}) async {
    final scores = await _datasource.getRecentScores(days: weeks * 7);
    final totals = List<double>.filled(weeks, 0);
    final now = DateTime.now();

    for (final entry in scores) {
      final date = _toDate(entry['date']);
      if (date == null) continue;

      final diffDays = now.difference(date).inDays;
      final weekIndex = weeks - 1 - (diffDays ~/ 7);
      if (weekIndex >= 0 && weekIndex < weeks) {
        totals[weekIndex] += (entry['score'] as num?)?.toDouble() ?? 0;
      }
    }

    return totals;
  }

  Future<List<SubjectPerformance>> getSubjectPerformance() async {
    final scores = await _datasource.getRecentScores(days: 14);
    return _subjectPerformanceFromScores(scores);
  }

  Future<List<double>> getWeeklyScoreTotalsForStudents(
    List<String> studentIds, {
    int weeks = 4,
  }) async {
    final scores = await _datasource.getRecentScoresForStudents(studentIds,
        days: weeks * 7);
    return _weeklyTotalsFromScores(scores, weeks: weeks);
  }

  Future<List<SubjectPerformance>> getSubjectPerformanceForStudents(
    List<String> studentIds,
  ) async {
    final scores =
        await _datasource.getRecentScoresForStudents(studentIds, days: 14);
    return _subjectPerformanceFromScores(scores);
  }

  List<double> _weeklyTotalsFromScores(
    List<Map<String, dynamic>> scores, {
    int weeks = 4,
  }) {
    final totals = List<double>.filled(weeks, 0);
    final now = DateTime.now();

    for (final entry in scores) {
      final date = _toDate(entry['date']);
      if (date == null) continue;

      final diffDays = now.difference(date).inDays;
      final weekIndex = weeks - 1 - (diffDays ~/ 7);
      if (weekIndex >= 0 && weekIndex < weeks) {
        totals[weekIndex] += (entry['score'] as num?)?.toDouble() ?? 0;
      }
    }

    return totals;
  }

  List<SubjectPerformance> _subjectPerformanceFromScores(
    List<Map<String, dynamic>> scores,
  ) {
    final now = DateTime.now();
    final current = <String, List<double>>{};
    final previous = <String, List<double>>{};

    for (final entry in scores) {
      final date = _toDate(entry['date']);
      if (date == null) continue;

      final subjectKey =
          entry['subjectKey'] as String? ?? subjectCatalog.first.key;
      final score = (entry['score'] as num?)?.toDouble() ?? 0;
      final diffDays = now.difference(date).inDays;

      if (diffDays < 7) {
        (current[subjectKey] ??= []).add(score);
      } else {
        (previous[subjectKey] ??= []).add(score);
      }
    }

    return subjectCatalog.map((subject) {
      final curr = current[subject.key];
      final prev = previous[subject.key];
      return SubjectPerformance(
        subject: subject,
        averageScore: _average(curr),
        previousAverageScore: _average(prev),
        hasData: curr != null && curr.isNotEmpty,
      );
    }).toList();
  }

  double _average(List<double>? values) {
    if (values == null || values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

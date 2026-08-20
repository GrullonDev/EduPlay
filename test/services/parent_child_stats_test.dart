// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/services/parent_child_stats_service.dart';

void main() {
  group('StudentRepository level/xp math', () {
    test('levelForPoints starts at level 1 with zero points', () {
      expect(StudentRepository.levelForPoints(0), 1);
    });

    test('levelForPoints advances every 100 points', () {
      expect(StudentRepository.levelForPoints(99), 1);
      expect(StudentRepository.levelForPoints(100), 2);
      expect(StudentRepository.levelForPoints(250), 3);
    });

    test('xpIntoLevel wraps at 100', () {
      expect(StudentRepository.xpIntoLevel(0), 0);
      expect(StudentRepository.xpIntoLevel(99), 99);
      expect(StudentRepository.xpIntoLevel(100), 0);
      expect(StudentRepository.xpIntoLevel(250), 50);
    });

    test('xpProgress is xpIntoLevel scaled to [0, 1)', () {
      expect(StudentRepository.xpProgress(0), 0.0);
      expect(StudentRepository.xpProgress(250), closeTo(0.5, 1e-9));
      expect(StudentRepository.xpProgress(99), closeTo(0.99, 1e-9));
    });
  });

  group('ChildGameplayStats.empty', () {
    test('has zeroed-out stats and no scores', () {
      const stats = ChildGameplayStats.empty;
      expect(stats.points, 0);
      expect(stats.streak, 0);
      expect(stats.level, 1);
      expect(stats.levelProgress, 0.0);
      expect(stats.gamesPlayedCount, 0);
      expect(stats.recentAverage, 0.0);
      expect(stats.lastGameTitle, isNull);
      expect(stats.lastPlayedAt, isNull);
    });
  });

  group('ChildGameplayStats derived getters', () {
    final newest = DateTime(2026, 8, 7);
    final older = DateTime(2026, 8, 5);

    ChildScoreEntry entry({
      required String gameTitle,
      required int score,
      required DateTime date,
    }) =>
        ChildScoreEntry(
          studentId: 'student-1',
          gameTitle: gameTitle,
          subjectKey: 'math',
          subjectLabel: 'Matemáticas',
          score: score,
          date: date,
        );

    test('level/levelProgress mirror StudentRepository for real points', () {
      const stats = ChildGameplayStats(
        studentId: 'student-1',
        points: 250,
        streak: 3,
        recentScores: [],
      );
      expect(stats.level, StudentRepository.levelForPoints(250));
      expect(stats.levelProgress, StudentRepository.xpProgress(250));
    });

    test('gamesPlayedCount matches the number of recent scores', () {
      final stats = ChildGameplayStats(
        studentId: 'student-1',
        points: 40,
        streak: 1,
        recentScores: [
          entry(gameTitle: 'Aventura Matemática', score: 20, date: newest),
          entry(gameTitle: 'Palabras Mágicas', score: 20, date: older),
        ],
      );
      expect(stats.gamesPlayedCount, 2);
    });

    test('recentAverage averages scores, 0 when there are none', () {
      final stats = ChildGameplayStats(
        studentId: 'student-1',
        points: 30,
        streak: 1,
        recentScores: [
          entry(gameTitle: 'A', score: 10, date: newest),
          entry(gameTitle: 'B', score: 20, date: older),
        ],
      );
      expect(stats.recentAverage, 15.0);
      expect(ChildGameplayStats.empty.recentAverage, 0.0);
    });

    test('lastGameTitle/lastPlayedAt read the first (newest) entry', () {
      final stats = ChildGameplayStats(
        studentId: 'student-1',
        points: 30,
        streak: 1,
        // Caller (ParentChildStatsService) is responsible for sorting
        // newest-first before constructing this — mirror that ordering here.
        recentScores: [
          entry(gameTitle: 'Aventura Matemática', score: 10, date: newest),
          entry(gameTitle: 'Palabras Mágicas', score: 20, date: older),
        ],
      );
      expect(stats.lastGameTitle, 'Aventura Matemática');
      expect(stats.lastPlayedAt, newest);
    });
  });
}

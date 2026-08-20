// Tests for the pure gamification math in StudentRepository. These static
// helpers convert a student's total points into a level, and are used by
// every dashboard/leaderboard widget — previously had zero coverage.

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/data/repositories/student_repository.dart';

void main() {
  group('StudentRepository.levelForPoints', () {
    test('0 points is level 1', () {
      expect(StudentRepository.levelForPoints(0), 1);
    });

    test('99 points is still level 1', () {
      expect(StudentRepository.levelForPoints(99), 1);
    });

    test('100 points reaches level 2', () {
      expect(StudentRepository.levelForPoints(100), 2);
    });

    test('250 points is level 3', () {
      expect(StudentRepository.levelForPoints(250), 3);
    });

    test('negative points do not throw', () {
      expect(() => StudentRepository.levelForPoints(-10), returnsNormally);
    });
  });

  group('StudentRepository.xpIntoLevel', () {
    test('is 0 right at a level boundary', () {
      expect(StudentRepository.xpIntoLevel(200), 0);
    });

    test('tracks progress within the current level', () {
      expect(StudentRepository.xpIntoLevel(150), 50);
    });

    test('wraps correctly just before the next level', () {
      expect(StudentRepository.xpIntoLevel(199), 99);
    });
  });

  group('StudentRepository.xpProgress', () {
    test('is 0.0 at the start of a level', () {
      expect(StudentRepository.xpProgress(300), 0.0);
    });

    test('is 0.5 halfway through a level', () {
      expect(StudentRepository.xpProgress(350), closeTo(0.5, 1e-9));
    });

    test('is always between 0 and 1', () {
      for (final points in [0, 1, 99, 100, 101, 999, 12345]) {
        final progress = StudentRepository.xpProgress(points);
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThan(1.0));
      }
    });

    test('is consistent with xpIntoLevel', () {
      const points = 742;
      expect(
        StudentRepository.xpProgress(points),
        closeTo(StudentRepository.xpIntoLevel(points) / 100.0, 1e-9),
      );
    });
  });
}

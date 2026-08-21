// Tests for SkillTally/SkillTracker — the per-skill correct/total bookkeeping
// every game controller uses to report concrete mastery (not just points) to
// StudentRepository.recordScore. Pure logic, no Firestore involved.

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/features/games/core/models/skill_result.dart';

void main() {
  group('SkillTally', () {
    test('accuracy is 0 when total is 0', () {
      const tally = SkillTally(correct: 0, total: 0);
      expect(tally.accuracy, 0);
    });

    test('accuracy divides correct by total', () {
      const tally = SkillTally(correct: 3, total: 4);
      expect(tally.accuracy, closeTo(0.75, 1e-9));
    });

    test('toMap round-trips through fromMap', () {
      const tally = SkillTally(correct: 5, total: 8);
      final restored = SkillTally.fromMap(tally.toMap());
      expect(restored.correct, 5);
      expect(restored.total, 8);
    });

    test('fromMap defaults missing fields to 0', () {
      final tally = SkillTally.fromMap(const {});
      expect(tally.correct, 0);
      expect(tally.total, 0);
    });

    test('fromMap tolerates non-int numeric types (Firestore returns num)',
        () {
      final tally = SkillTally.fromMap(const {'correct': 2.0, 'total': 5.0});
      expect(tally.correct, 2);
      expect(tally.total, 5);
    });
  });

  group('SkillTracker', () {
    test('starts empty', () {
      final tracker = SkillTracker();
      expect(tracker.isEmpty, isTrue);
      expect(tracker.tallies, isEmpty);
    });

    test('record accumulates correct/total for a single skill', () {
      final tracker = SkillTracker()
        ..record('suma', correct: true)
        ..record('suma', correct: false)
        ..record('suma', correct: true);

      final tally = tracker.tallies['suma']!;
      expect(tally.correct, 2);
      expect(tally.total, 3);
      expect(tracker.isEmpty, isFalse);
    });

    test('tracks multiple skills independently', () {
      final tracker = SkillTracker()
        ..record('suma', correct: true)
        ..record('resta', correct: false)
        ..record('resta', correct: false);

      final suma = tracker.tallies['suma']!;
      expect(suma.correct, 1);
      expect(suma.total, 1);

      final resta = tracker.tallies['resta']!;
      expect(resta.correct, 0);
      expect(resta.total, 2);
    });

    test('reset clears all accumulated tallies', () {
      final tracker = SkillTracker()..record('suma', correct: true);
      expect(tracker.isEmpty, isFalse);

      tracker.reset();

      expect(tracker.isEmpty, isTrue);
      expect(tracker.tallies, isEmpty);
    });

    test('toFirestoreMap serializes every tracked skill', () {
      final tracker = SkillTracker()
        ..record('suma', correct: true)
        ..record('resta', correct: false);

      final map = tracker.toFirestoreMap();

      expect(map['suma'], {'correct': 1, 'total': 1});
      expect(map['resta'], {'correct': 0, 'total': 1});
    });

    test('tallies is unmodifiable from the outside', () {
      final tracker = SkillTracker()..record('suma', correct: true);
      expect(
        () => tracker.tallies['resta'] = const SkillTally(correct: 0, total: 1),
        throwsUnsupportedError,
      );
    });
  });

  group('skillSummaryText', () {
    test('returns an empty string when there is nothing to show', () {
      expect(skillSummaryText(const {}), '');
    });

    test('skips skills with a zero total (nothing graded yet)', () {
      final tallies = {
        'suma': const SkillTally(correct: 0, total: 0),
        'resta': const SkillTally(correct: 2, total: 2),
      };
      expect(skillSummaryText(tallies), 'Resta: 2/2');
    });

    test('joins multiple graded skills with a bullet separator', () {
      final tallies = {
        'suma': const SkillTally(correct: 4, total: 5),
        'resta': const SkillTally(correct: 2, total: 5),
      };
      final text = skillSummaryText(tallies);
      expect(text, contains('Suma: 4/5'));
      expect(text, contains('Resta: 2/5'));
      expect(text, contains(' · '));
    });

    test('falls back to the raw key for an unknown skill id', () {
      final tallies = {'mystery_skill': const SkillTally(correct: 1, total: 1)};
      expect(skillSummaryText(tallies), 'mystery_skill: 1/1');
    });
  });
}

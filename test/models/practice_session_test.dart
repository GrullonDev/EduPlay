// PracticeSession drives the parent-created practice kiosk flow
// (create_session -> child joins via PIN -> completes assigned games).
// It previously had zero test coverage despite non-trivial derived logic
// (completion tracking, progress fraction, session URLs).

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/features/practice_session/models/practice_session.dart';

PracticeSession _buildSession({
  List<String> assignedGameIds = const ['math-1', 'magic-words'],
  List<String> completedGameIds = const [],
  bool isActive = true,
  Map<String, int> scoreMap = const {},
}) {
  return PracticeSession(
    id: 'session-1',
    childProfileId: 'child-1',
    childName: 'Sofía',
    pin: '482913',
    assignedGameIds: assignedGameIds,
    createdAt: DateTime(2026, 1, 1),
    isActive: isActive,
    completedGameIds: completedGameIds,
    scoreMap: scoreMap,
  );
}

void main() {
  group('PracticeSession.generatePin', () {
    test('produces a 6-digit string', () {
      final pin = PracticeSession.generatePin();
      expect(RegExp(r'^\d{6}$').hasMatch(pin), isTrue,
          reason: 'PIN "$pin" is not 6 digits');
    });
  });

  group('PracticeSession.generateId', () {
    test('produces a non-empty numeric string', () {
      final id = PracticeSession.generateId();
      expect(id, isNotEmpty);
      expect(int.tryParse(id), isNotNull);
    });
  });

  group('PracticeSession.isCompleted / progressFraction', () {
    test('is not completed with no completed games', () {
      final session = _buildSession();
      expect(session.isCompleted, isFalse);
      expect(session.completedCount, 0);
      expect(session.totalCount, 2);
      expect(session.progressFraction, 0.0);
    });

    test('is partially complete with some games done', () {
      final session = _buildSession(completedGameIds: ['math-1']);
      expect(session.isCompleted, isFalse);
      expect(session.progressFraction, closeTo(0.5, 1e-9));
    });

    test('is completed once every assigned game is done', () {
      final session =
          _buildSession(completedGameIds: ['math-1', 'magic-words']);
      expect(session.isCompleted, isTrue);
      expect(session.progressFraction, 1.0);
    });

    test('an empty assignment list is never "completed"', () {
      final session = _buildSession(assignedGameIds: const []);
      expect(session.isCompleted, isFalse);
      expect(session.progressFraction, 0.0);
    });

    test('extra completed games beyond the assignment do not break completion', () {
      final session = _buildSession(
        completedGameIds: ['math-1', 'magic-words', 'extra-game'],
      );
      expect(session.isCompleted, isTrue);
    });
  });

  group('PracticeSession.sessionUrl', () {
    test('embeds the PIN as a query parameter', () {
      final session = _buildSession();
      expect(
        session.sessionUrl('https://eduplay.app'),
        'https://eduplay.app/practice-session?pin=482913',
      );
    });
  });

  group('PracticeSession.copyWith', () {
    test('overrides only the specified fields', () {
      final original = _buildSession();
      final updated = original.copyWith(
        isActive: false,
        completedGameIds: ['math-1'],
      );
      expect(updated.isActive, isFalse);
      expect(updated.completedGameIds, ['math-1']);
      expect(updated.id, original.id);
      expect(updated.pin, original.pin);
      expect(updated.assignedGameIds, original.assignedGameIds);
    });

    test('preserves unspecified fields', () {
      final original = _buildSession(scoreMap: {'math-1': 80});
      final updated = original.copyWith(isActive: false);
      expect(updated.scoreMap, original.scoreMap);
      expect(updated.completedGameIds, original.completedGameIds);
    });
  });

  group('PracticeSession JSON round-trip', () {
    test('toJson -> fromJson preserves all fields', () {
      final original = _buildSession(
        completedGameIds: ['math-1'],
        scoreMap: {'math-1': 90},
      );
      final restored = PracticeSession.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.childProfileId, original.childProfileId);
      expect(restored.childName, original.childName);
      expect(restored.pin, original.pin);
      expect(restored.assignedGameIds, original.assignedGameIds);
      expect(restored.createdAt, original.createdAt);
      expect(restored.isActive, original.isActive);
      expect(restored.completedGameIds, original.completedGameIds);
      expect(restored.scoreMap, original.scoreMap);
    });

    test('fromJson defaults isActive to true when absent', () {
      final json = _buildSession().toJson()..remove('isActive');
      final restored = PracticeSession.fromJson(json);
      expect(restored.isActive, isTrue);
    });

    test('fromJson defaults completedGameIds and scoreMap to empty', () {
      final json = _buildSession().toJson()
        ..remove('completedGameIds')
        ..remove('scoreMap');
      final restored = PracticeSession.fromJson(json);
      expect(restored.completedGameIds, isEmpty);
      expect(restored.scoreMap, isEmpty);
    });
  });
}

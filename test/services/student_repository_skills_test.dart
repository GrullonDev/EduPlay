// Tests for the skills side of the gamification data pipeline:
//  - StudentDatasource.recordScore persists the `skills` map on the score
//    entry (and omits it when there's nothing to report).
//  - StudentRepository.recordScore converts SkillTracker tallies into that
//    same persisted shape.
//  - StudentRepository.getSkillPerformance aggregates correct/total across
//    score entries into per-skill accuracy, bucketed into "current" vs
//    "previous" 7-day windows.
//
// Uses fake_cloud_firestore (already a dev dependency, used the same way in
// features_friends_service_test.dart / auth_gate_test.dart) via the
// StudentDatasource.useFirestoreForTest hook added alongside these tests.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/games/core/models/skill_result.dart';

Future<void> _seedScore(
  FakeFirebaseFirestore firestore, {
  required String studentId,
  required DateTime date,
  Map<String, dynamic>? skills,
}) {
  return firestore.collection('students').doc(studentId).collection('scores').add({
    'studentId': studentId,
    'subjectKey': 'math',
    'subjectLabel': 'Matemáticas',
    'gameTitle': 'Juego de Prueba',
    'score': 10,
    'date': Timestamp.fromDate(date),
    if (skills != null) 'skills': skills,
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    StudentDatasource.useFirestoreForTest(null);
  });

  group('StudentDatasource.recordScore skills persistence', () {
    test('persists the skills map alongside the score entry', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final datasource = StudentDatasource();

      await datasource.recordScore(
        studentId: 'student-1',
        subjectKey: 'math',
        subjectLabel: 'Matemáticas',
        gameTitle: 'Aventura Matemática',
        score: 40,
        skills: const {
          'suma': {'correct': 3, 'total': 4},
        },
      );

      final scores = await firestore
          .collection('students')
          .doc('student-1')
          .collection('scores')
          .get();

      expect(scores.docs, hasLength(1));
      final data = scores.docs.first.data();
      expect(data['skills'], {
        'suma': {'correct': 3, 'total': 4},
      });
      expect(data['score'], 40);
    });

    test('omits the skills field when none are provided', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final datasource = StudentDatasource();

      await datasource.recordScore(
        studentId: 'student-2',
        subjectKey: 'math',
        subjectLabel: 'Matemáticas',
        gameTitle: 'Aventura Matemática',
        score: 10,
        skills: null,
      );

      final scores = await firestore
          .collection('students')
          .doc('student-2')
          .collection('scores')
          .get();

      expect(scores.docs.first.data().containsKey('skills'), isFalse);
    });

    test('omits the skills field when the map is empty', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final datasource = StudentDatasource();

      await datasource.recordScore(
        studentId: 'student-3',
        subjectKey: 'math',
        subjectLabel: 'Matemáticas',
        gameTitle: 'Aventura Matemática',
        score: 10,
        skills: const {},
      );

      final scores = await firestore
          .collection('students')
          .doc('student-3')
          .collection('scores')
          .get();

      expect(scores.docs.first.data().containsKey('skills'), isFalse);
    });
  });

  group('StudentRepository.recordScore skills', () {
    test('converts SkillTracker tallies into the persisted skills map',
        () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());

      final tracker = SkillTracker()
        ..record('vocabulario', correct: true)
        ..record('vocabulario', correct: false);

      await repository.recordScore(
        subjectKey: 'language',
        gameTitle: 'Palabras Mágicas',
        score: 20,
        skills: tracker.tallies,
      );

      final studentId = await repository.getMyStudentId();
      final scoreDocs = await firestore
          .collection('students')
          .doc(studentId)
          .collection('scores')
          .get();

      expect(scoreDocs.docs, hasLength(1));
      expect(scoreDocs.docs.first.data()['skills'], {
        'vocabulario': {'correct': 1, 'total': 2},
      });
    });

    test('recording with no skills argument does not crash and stores no skills',
        () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());

      await repository.recordScore(
        subjectKey: 'math',
        gameTitle: 'Aventura Matemática',
        score: 15,
      );

      final studentId = await repository.getMyStudentId();
      final scoreDocs = await firestore
          .collection('students')
          .doc(studentId)
          .collection('scores')
          .get();

      expect(scoreDocs.docs.first.data().containsKey('skills'), isFalse);
    });
  });

  group('StudentRepository.getSkillPerformance aggregation', () {
    test('sums correct/total across multiple entries in the current window',
        () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());
      final now = DateTime.now();

      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 1)),
          skills: const {
            'suma': {'correct': 3, 'total': 4},
          });
      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 3)),
          skills: const {
            'suma': {'correct': 1, 'total': 1},
          });

      final performance = await repository.getSkillPerformance();
      final suma = performance.firstWhere((p) => p.skill.key == 'suma');

      expect(suma.totalAnswers, 5);
      expect(suma.accuracy, closeTo(4 / 5, 1e-9));
      expect(suma.hasData, isTrue);
    });

    test('computes previousAccuracy from the 7-14 day window', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());
      final now = DateTime.now();

      // Previous window (7-14 days ago).
      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 10)),
          skills: const {
            'resta': {'correct': 2, 'total': 4},
          });
      // Current window (last 7 days).
      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 2)),
          skills: const {
            'resta': {'correct': 3, 'total': 4},
          });

      final performance = await repository.getSkillPerformance();
      final resta = performance.firstWhere((p) => p.skill.key == 'resta');

      expect(resta.accuracy, closeTo(3 / 4, 1e-9));
      expect(resta.previousAccuracy, closeTo(2 / 4, 1e-9));
      expect(resta.totalAnswers, 4);
    });

    test('ignores legacy score entries that never recorded skills', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());
      final now = DateTime.now();

      await _seedScore(firestore,
          studentId: 's1', date: now.subtract(const Duration(days: 1)));

      final performance = await repository.getSkillPerformance();

      expect(performance, isEmpty);
    });

    test('sorts results by totalAnswers descending', () async {
      final firestore = FakeFirebaseFirestore();
      StudentDatasource.useFirestoreForTest(firestore);
      final repository = StudentRepository(datasource: StudentDatasource());
      final now = DateTime.now();

      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 1)),
          skills: const {
            'suma': {'correct': 10, 'total': 10},
          });
      await _seedScore(firestore,
          studentId: 's1',
          date: now.subtract(const Duration(days: 1)),
          skills: const {
            'resta': {'correct': 1, 'total': 2},
          });

      final performance = await repository.getSkillPerformance();

      expect(performance.first.skill.key, 'suma');
    });
  });
}

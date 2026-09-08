// Tests the cascading deleteClass() logic against fake_cloud_firestore, so
// this exercises the exact same code path production deletes run through —
// not a reimplementation of it.

// Package imports:
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/features/teacher_dashboard/data/datasources/teacher_classes_datasource.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late TeacherClassesDatasource datasource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    datasource = FirestoreTeacherClassesDatasource(
      firestore: firestore,
      auth: MockFirebaseAuth(),
    );
  });

  Future<void> seedClass(String classId,
      {int memberCount = 0, int challengeCount = 0}) async {
    await firestore.collection('classes').doc(classId).set({
      'teacherUid': 'teacher1',
      'name': 'Clase de prueba',
      'subject': 'Matemáticas',
      'gradeLevel': '3° Primaria',
      'joinCode': 'ABC123',
      'studentCount': memberCount,
      'minAge': 6,
      'maxAge': 10,
      'isPublic': false,
      'createdAt': DateTime.now().toIso8601String(),
    });

    for (var i = 0; i < memberCount; i++) {
      await firestore
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc('member$i')
          .set({'displayName': 'Alumno $i'});
    }

    for (var i = 0; i < challengeCount; i++) {
      await firestore
          .collection('classes')
          .doc(classId)
          .collection('challenges')
          .doc('challenge$i')
          .set({'title': 'Reto $i'});
    }
  }

  group('deleteClass', () {
    test('removes the class doc along with its members and challenges',
        () async {
      await seedClass('class1', memberCount: 3, challengeCount: 2);
      await seedClass('class2', memberCount: 1, challengeCount: 1);

      await datasource.deleteClass('class1');

      final classDoc =
          await firestore.collection('classes').doc('class1').get();
      expect(classDoc.exists, isFalse);

      final members = await firestore
          .collection('classes')
          .doc('class1')
          .collection('members')
          .get();
      expect(members.docs, isEmpty);

      final challenges = await firestore
          .collection('classes')
          .doc('class1')
          .collection('challenges')
          .get();
      expect(challenges.docs, isEmpty);

      // A sibling class untouched by the deletion keeps its subcollections.
      final otherClassDoc =
          await firestore.collection('classes').doc('class2').get();
      expect(otherClassDoc.exists, isTrue);
      final otherMembers = await firestore
          .collection('classes')
          .doc('class2')
          .collection('members')
          .get();
      expect(otherMembers.docs, hasLength(1));
    });

    test('handles a class with no members or challenges', () async {
      await seedClass('empty_class');

      await expectLater(datasource.deleteClass('empty_class'), completes);

      final classDoc =
          await firestore.collection('classes').doc('empty_class').get();
      expect(classDoc.exists, isFalse);
    });

    test('pages the delete when a class has more than one batch worth of '
        'subdocuments', () async {
      // 250 members + 250 challenges = 500 subdocuments, forcing the
      // chunked-batch path (chunkSize = 400) to run more than once.
      await seedClass('big_class', memberCount: 250, challengeCount: 250);

      await datasource.deleteClass('big_class');

      final members = await firestore
          .collection('classes')
          .doc('big_class')
          .collection('members')
          .get();
      final challenges = await firestore
          .collection('classes')
          .doc('big_class')
          .collection('challenges')
          .get();
      expect(members.docs, isEmpty);
      expect(challenges.docs, isEmpty);
    });
  });
}

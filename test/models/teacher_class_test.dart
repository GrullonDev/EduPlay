// TeacherClass and ClassMember back the entire teacher_dashboard feature
// (classes, join codes, roster) and had zero test coverage. These tests
// cover only the pure fromMap/toMap logic — no Firestore instance is
// touched (FieldValue.serverTimestamp() just builds a local sentinel).

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TeacherClass.fromMap', () {
    test('reads all fields from a complete map', () {
      final createdAt = DateTime(2026, 3, 1, 10, 30);
      final tc = TeacherClass.fromMap({
        'teacherUid': 'teacher-1',
        'teacherName': 'Profe Ana',
        'name': '4to Grado A',
        'subject': 'math',
        'gradeLevel': '4to',
        'joinCode': 'AB12CD',
        'studentCount': 25,
        'minAge': 8,
        'maxAge': 10,
        'isPublic': true,
        'createdAt': Timestamp.fromDate(createdAt),
      }, 'class-1');

      expect(tc.id, 'class-1');
      expect(tc.teacherUid, 'teacher-1');
      expect(tc.teacherName, 'Profe Ana');
      expect(tc.name, '4to Grado A');
      expect(tc.subject, 'math');
      expect(tc.gradeLevel, '4to');
      expect(tc.joinCode, 'AB12CD');
      expect(tc.studentCount, 25);
      expect(tc.minAge, 8);
      expect(tc.maxAge, 10);
      expect(tc.isPublic, isTrue);
      expect(tc.createdAt, createdAt);
    });

    test('fills in safe defaults for a mostly-empty map', () {
      final tc = TeacherClass.fromMap({}, 'class-2');

      expect(tc.id, 'class-2');
      expect(tc.teacherUid, '');
      expect(tc.name, '');
      expect(tc.studentCount, 0);
      expect(tc.minAge, 3);
      expect(tc.maxAge, 12);
      expect(tc.isPublic, isFalse);
    });

    test('does not throw when createdAt is missing or malformed', () {
      expect(
        () => TeacherClass.fromMap({'createdAt': 'not-a-timestamp'}, 'x'),
        returnsNormally,
      );
    });
  });

  group('TeacherClass.ageRangeLabel', () {
    test('formats the min/max age range', () {
      final tc = TeacherClass(
        id: 'x',
        teacherUid: 'u',
        name: 'Clase',
        subject: 'math',
        gradeLevel: '3ro',
        joinCode: 'ABCDEF',
        studentCount: 0,
        minAge: 6,
        maxAge: 9,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(tc.ageRangeLabel, '6–9 años');
    });
  });

  group('TeacherClass.toMap', () {
    final tc = TeacherClass(
      id: 'class-1',
      teacherUid: 'teacher-1',
      teacherName: 'Profe Ana',
      name: '4to Grado A',
      subject: 'math',
      gradeLevel: '4to',
      joinCode: 'AB12CD',
      studentCount: 25,
      minAge: 8,
      maxAge: 10,
      isPublic: true,
      createdAt: DateTime(2026, 1, 1),
    );

    test('includes every writable field except id', () {
      final map = tc.toMap();
      expect(map['teacherUid'], 'teacher-1');
      expect(map['teacherName'], 'Profe Ana');
      expect(map['name'], '4to Grado A');
      expect(map['subject'], 'math');
      expect(map['gradeLevel'], '4to');
      expect(map['joinCode'], 'AB12CD');
      expect(map['studentCount'], 25);
      expect(map['minAge'], 8);
      expect(map['maxAge'], 10);
      expect(map['isPublic'], isTrue);
      expect(map.containsKey('id'), isFalse);
    });

    test('stamps createdAt with a server timestamp sentinel', () {
      final map = tc.toMap();
      expect(map['createdAt'], isA<FieldValue>());
    });
  });

  group('ClassMember.fromMap', () {
    test('reads all fields from a complete map', () {
      final joinedAt = DateTime(2026, 2, 14);
      final member = ClassMember.fromMap({
        'classId': 'class-1',
        'teacherUid': 'teacher-1',
        'className': '4to Grado A',
        'classSubject': 'math',
        'classGradeLevel': '4to',
        'displayName': 'Sofía',
        'email': 'parent@example.com',
        'role': 'student',
        'studentId': 'student-9',
        'childProfileId': 'child-9',
        'parentUid': 'parent-1',
        'age': 9,
        'focusSubject': 'science',
        'completedChallengeIds': ['c1', 'c2'],
        'joinedAt': Timestamp.fromDate(joinedAt),
      }, 'member-1');

      expect(member.id, 'member-1');
      expect(member.classId, 'class-1');
      expect(member.displayName, 'Sofía');
      expect(member.role, 'student');
      expect(member.age, 9);
      expect(member.completedChallengeIds, ['c1', 'c2']);
      expect(member.joinedAt, joinedAt);
    });

    test('defaults studentId to the document id when absent', () {
      final member = ClassMember.fromMap({}, 'doc-id-42');
      expect(member.studentId, 'doc-id-42');
    });

    test('defaults role to "student" and age to null', () {
      final member = ClassMember.fromMap({}, 'x');
      expect(member.role, 'student');
      expect(member.age, isNull);
    });

    test('defaults completedChallengeIds to an empty list', () {
      final member = ClassMember.fromMap({}, 'x');
      expect(member.completedChallengeIds, isEmpty);
    });
  });
}

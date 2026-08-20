// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassMember {
  const ClassMember({
    required this.id,
    required this.classId,
    required this.teacherUid,
    required this.className,
    required this.classSubject,
    required this.classGradeLevel,
    required this.displayName,
    required this.email,
    required this.role,
    required this.studentId,
    required this.childProfileId,
    required this.parentUid,
    required this.age,
    required this.focusSubject,
    required this.completedChallengeIds,
    required this.joinedAt,
  });

  factory ClassMember.fromMap(Map<String, dynamic> map, String id) {
    return ClassMember(
      id: id,
      classId: (map['classId'] as String?) ?? '',
      teacherUid: (map['teacherUid'] as String?) ?? '',
      className: (map['className'] as String?) ?? '',
      classSubject: (map['classSubject'] as String?) ?? '',
      classGradeLevel: (map['classGradeLevel'] as String?) ?? '',
      displayName: (map['displayName'] as String?) ?? '',
      email: (map['email'] as String?) ?? '',
      role: (map['role'] as String?) ?? 'student',
      studentId: (map['studentId'] as String?) ?? id,
      childProfileId: (map['childProfileId'] as String?) ?? '',
      parentUid: (map['parentUid'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt(),
      focusSubject: (map['focusSubject'] as String?) ?? '',
      completedChallengeIds: List<String>.from(
        (map['completedChallengeIds'] as List?) ?? const [],
      ),
      joinedAt: map['joinedAt'] is Timestamp
          ? (map['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  final String id;
  final String classId;
  final String teacherUid;
  final String className;
  final String classSubject;
  final String classGradeLevel;
  final String displayName;
  final String email;
  final String role;
  final String studentId;
  final String childProfileId;
  final String parentUid;
  final int? age;
  final String focusSubject;
  final List<String> completedChallengeIds;
  final DateTime joinedAt;
}

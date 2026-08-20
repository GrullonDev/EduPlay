// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherClass {
  const TeacherClass({
    required this.id,
    required this.teacherUid,
    this.teacherName = '',
    required this.name,
    required this.subject,
    required this.gradeLevel,
    required this.joinCode,
    required this.studentCount,
    this.minAge = 3,
    this.maxAge = 12,
    this.isPublic = false,
    required this.createdAt,
  });

  factory TeacherClass.fromMap(Map<String, dynamic> map, String id) {
    return TeacherClass(
      id: id,
      teacherUid: (map['teacherUid'] as String?) ?? '',
      teacherName: (map['teacherName'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      subject: (map['subject'] as String?) ?? '',
      gradeLevel: (map['gradeLevel'] as String?) ?? '',
      joinCode: (map['joinCode'] as String?) ?? '',
      studentCount: (map['studentCount'] as int?) ?? 0,
      minAge: (map['minAge'] as num?)?.toInt() ?? 3,
      maxAge: (map['maxAge'] as num?)?.toInt() ?? 12,
      isPublic: (map['isPublic'] as bool?) ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  final String id;
  final String teacherUid;
  final String teacherName;
  final String name;
  final String subject;
  final String gradeLevel;
  final String joinCode;
  final int studentCount;
  final int minAge;
  final int maxAge;
  final bool isPublic;
  final DateTime createdAt;

  String get ageRangeLabel => '$minAge–$maxAge años';

  Map<String, dynamic> toMap() => {
        'teacherUid': teacherUid,
        'teacherName': teacherName,
        'name': name,
        'subject': subject,
        'gradeLevel': gradeLevel,
        'joinCode': joinCode,
        'studentCount': studentCount,
        'minAge': minAge,
        'maxAge': maxAge,
        'isPublic': isPublic,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

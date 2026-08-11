import 'package:cloud_firestore/cloud_firestore.dart';

class ClassroomChallenge {
  ClassroomChallenge({
    required this.id,
    required this.classId,
    required this.className,
    required this.title,
    required this.subjectKey,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.completed = false,
    this.memberId,
  });

  final String id;
  final String classId;
  final String className;
  final String title;
  final String subjectKey;
  final String status;
  final DateTime createdAt;
  final String? dueDate;
  final bool completed;
  final String? memberId;

  Map<String, dynamic> toStudentMap() => {
        'id': id,
        'class_id': classId,
        'class_name': className,
        'member_id': memberId,
        'title': title,
        'subject_key': subjectKey,
        'due_date': dueDate,
        'status': completed ? 'completed' : status,
      };

  Map<String, dynamic> toTeacherMap() => {
        'id': id,
        'class_id': classId,
        'class_name': className,
        'title': title,
        'subject_key': subjectKey,
        'due_date': dueDate,
        'status': status,
        'created_at': Timestamp.fromDate(createdAt),
      };
}

// Package imports:
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
    this.instructions,
    this.evaluationCriteria,
    this.targetGameRoute,
    this.targetScore,
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

  /// Activity instructions written by the teacher — what the student
  /// should actually do, beyond just the title.
  final String? instructions;

  /// The rubric/criteria the teacher will judge success by.
  final String? evaluationCriteria;

  /// One of the real game routes (see `GameRegistry`/the games catalog).
  /// When set together with [targetScore], completion is verified
  /// automatically instead of self-reported.
  final String? targetGameRoute;

  /// Minimum score the student must reach on [targetGameRoute] for this
  /// challenge to auto-complete.
  final int? targetScore;

  Map<String, dynamic> toStudentMap() => {
        'id': id,
        'class_id': classId,
        'class_name': className,
        'member_id': memberId,
        'title': title,
        'subject_key': subjectKey,
        'due_date': dueDate,
        'status': completed ? 'completed' : status,
        'instructions': instructions,
        'evaluation_criteria': evaluationCriteria,
        'target_game_route': targetGameRoute,
        'target_score': targetScore,
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
        'instructions': instructions,
        'evaluation_criteria': evaluationCriteria,
        'target_game_route': targetGameRoute,
        'target_score': targetScore,
      };
}

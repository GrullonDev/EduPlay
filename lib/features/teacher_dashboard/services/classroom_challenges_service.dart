import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';

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

class ClassroomChallengesService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _challengeCol(
          String classId) =>
      _db.collection('classes').doc(classId).collection('challenges');

  static Future<void> createChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
    String status = 'active',
  }) async {
    await _challengeCol(classId).add({
      'title': title,
      'subjectKey': subjectKey,
      'dueDate': dueDate,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  ) async {
    if (classes.isEmpty) return [];

    final results = <ClassroomChallenge>[];
    for (final tc in classes) {
      final snap = await _challengeCol(tc.id)
          .orderBy('createdAt', descending: true)
          .get();
      results.addAll(
        snap.docs.map(
          (doc) => ClassroomChallenge(
            id: doc.id,
            classId: tc.id,
            className: tc.name,
            title: (doc.data()['title'] as String?) ?? 'Reto',
            subjectKey: (doc.data()['subjectKey'] as String?) ?? 'math',
            status: (doc.data()['status'] as String?) ?? 'active',
            dueDate: doc.data()['dueDate'] as String?,
            createdAt: doc.data()['createdAt'] is Timestamp
                ? (doc.data()['createdAt'] as Timestamp).toDate()
                : DateTime.now(),
          ),
        ),
      );
    }
    return results;
  }

  static Future<List<ClassroomChallenge>> getChallengesForStudent(
    String studentId,
  ) async {
    final enrollments =
        await TeacherClassesService.getEnrollmentsForStudent(studentId);
    if (enrollments.isEmpty) return [];

    final classesById = {
      for (final e in enrollments)
        e.classId: TeacherClass(
          id: e.classId,
          teacherUid: e.teacherUid,
          name: e.className,
          subject: e.classSubject,
          gradeLevel: e.classGradeLevel,
          joinCode: '',
          studentCount: 0,
          createdAt: DateTime.now(),
        ),
    };

    final rawChallenges =
        await getChallengesForClasses(classesById.values.toList());
    final enrollmentsByClass = {
      for (final e in enrollments) e.classId: e,
    };

    return rawChallenges.map((challenge) {
      final enrollment = enrollmentsByClass[challenge.classId];
      final completed =
          enrollment?.completedChallengeIds.contains(challenge.id) ?? false;
      return ClassroomChallenge(
        id: challenge.id,
        classId: challenge.classId,
        className: challenge.className,
        title: challenge.title,
        subjectKey: challenge.subjectKey,
        status: challenge.status,
        createdAt: challenge.createdAt,
        dueDate: challenge.dueDate,
        completed: completed,
        memberId: enrollment?.id,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  }) async {
    await _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(memberId)
        .set({
      'completedChallengeIds': FieldValue.arrayUnion([challengeId]),
    }, SetOptions(merge: true));
  }
}

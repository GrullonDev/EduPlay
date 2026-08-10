import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';

abstract class ClassroomChallengesDatasource {
  Future<void> createChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
    String status = 'active',
  });

  Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  );

  Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  });
}

class FirestoreClassroomChallengesDatasource
    implements ClassroomChallengesDatasource {
  FirestoreClassroomChallengesDatasource({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _challengeCol(String classId) =>
      _db.collection('classes').doc(classId).collection('challenges');

  @override
  Future<void> createChallenge({
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

  @override
  Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  ) async {
    if (classes.isEmpty) return [];

    final results = <ClassroomChallenge>[];
    for (final teacherClass in classes) {
      final snap = await _challengeCol(teacherClass.id)
          .orderBy('createdAt', descending: true)
          .get();
      results.addAll(
        snap.docs.map(
          (doc) => ClassroomChallenge(
            id: doc.id,
            classId: teacherClass.id,
            className: teacherClass.name,
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

  @override
  Future<void> completeChallenge({
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

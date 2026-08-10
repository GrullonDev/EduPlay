import 'package:edu_play/features/teacher_dashboard/data/datasources/classroom_challenges_datasource.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';

class FirestoreClassroomChallengesRepository
    implements ClassroomChallengesRepository {
  const FirestoreClassroomChallengesRepository({
    required this.datasource,
    required this.teacherClassesRepository,
  });

  final ClassroomChallengesDatasource datasource;
  final TeacherClassesRepository teacherClassesRepository;

  @override
  Future<void> createChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
    String status = 'active',
  }) {
    return datasource.createChallenge(
      classId: classId,
      title: title,
      subjectKey: subjectKey,
      dueDate: dueDate,
      status: status,
    );
  }

  @override
  Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  ) {
    return datasource.getChallengesForClasses(classes);
  }

  @override
  Future<List<ClassroomChallenge>> getChallengesForStudent(
    String studentId,
  ) async {
    final enrollments =
        await teacherClassesRepository.getEnrollmentsForStudent(studentId);
    if (enrollments.isEmpty) return [];

    final classesById = {
      for (final enrollment in enrollments)
        enrollment.classId: TeacherClass(
          id: enrollment.classId,
          teacherUid: enrollment.teacherUid,
          name: enrollment.className,
          subject: enrollment.classSubject,
          gradeLevel: enrollment.classGradeLevel,
          joinCode: '',
          studentCount: 0,
          createdAt: DateTime.now(),
        ),
    };

    final rawChallenges =
        await datasource.getChallengesForClasses(classesById.values.toList());
    final enrollmentsByClass = {
      for (final enrollment in enrollments) enrollment.classId: enrollment,
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

  @override
  Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  }) {
    return datasource.completeChallenge(
      classId: classId,
      memberId: memberId,
      challengeId: challengeId,
    );
  }
}

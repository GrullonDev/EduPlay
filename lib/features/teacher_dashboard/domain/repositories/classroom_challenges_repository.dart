import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';

abstract class ClassroomChallengesRepository {
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

  Future<List<ClassroomChallenge>> getChallengesForStudent(String studentId);

  Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  });
}

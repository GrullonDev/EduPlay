export 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';

import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Backward-compatible facade while teacher/student dashboards migrate to the
/// injected [ClassroomChallengesRepository]. Firebase access lives in
/// `data/datasources`, not in this service.
class ClassroomChallengesService {
  static ClassroomChallengesRepository get _repository {
    init();
    return sl<ClassroomChallengesRepository>();
  }

  static Future<void> createChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
    String status = 'active',
  }) {
    return _repository.createChallenge(
      classId: classId,
      title: title,
      subjectKey: subjectKey,
      dueDate: dueDate,
      status: status,
    );
  }

  static Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  ) {
    return _repository.getChallengesForClasses(classes);
  }

  static Future<List<ClassroomChallenge>> getChallengesForStudent(
    String studentId,
  ) {
    return _repository.getChallengesForStudent(studentId);
  }

  static Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  }) {
    return _repository.completeChallenge(
      classId: classId,
      memberId: memberId,
      challengeId: challengeId,
    );
  }
}

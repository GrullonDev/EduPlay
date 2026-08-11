import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';

abstract class TeacherClassesRepository {
  Stream<List<TeacherClass>> watchMyClasses();

  Future<TeacherClass?> findByCode(String code);

  Future<List<ClassMember>> getMembers(String classId);

  Future<List<TeacherClass>> getMyClasses();

  Future<List<ClassMember>> getMembersForClasses(List<String> classIds);

  Future<List<ClassMember>> getEnrollmentsForStudent(String studentId);

  Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  });

  Future<List<TeacherClass>> getPublicClassesForAge(int childAge);

  Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  });

  Future<void> deleteClass(String classId);

  Future<void> joinClass({
    required String classId,
    required String displayName,
    required String email,
    required String role,
    String? studentId,
    String? childProfileId,
    String? parentUid,
    int? age,
    String? focusSubject,
  });

  Future<String> getCurrentTeacherFirstName();
}

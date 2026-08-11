import 'package:edu_play/features/teacher_dashboard/data/datasources/teacher_classes_datasource.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';

class FirestoreTeacherClassesRepository implements TeacherClassesRepository {
  const FirestoreTeacherClassesRepository({required this.datasource});

  final TeacherClassesDatasource datasource;

  @override
  Stream<List<TeacherClass>> watchMyClasses() => datasource.watchMyClasses();

  @override
  Future<TeacherClass?> findByCode(String code) => datasource.findByCode(code);

  @override
  Future<List<ClassMember>> getMembers(String classId) {
    return datasource.getMembers(classId);
  }

  @override
  Future<List<TeacherClass>> getMyClasses() => datasource.getMyClasses();

  @override
  Future<List<ClassMember>> getMembersForClasses(List<String> classIds) {
    return datasource.getMembersForClasses(classIds);
  }

  @override
  Future<List<ClassMember>> getEnrollmentsForStudent(String studentId) {
    return datasource.getEnrollmentsForStudent(studentId);
  }

  @override
  Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  }) {
    return datasource.createClass(
      name: name,
      subject: subject,
      gradeLevel: gradeLevel,
      minAge: minAge,
      maxAge: maxAge,
      isPublic: isPublic,
    );
  }

  @override
  Future<List<TeacherClass>> getPublicClassesForAge(int childAge) {
    return datasource.getPublicClassesForAge(childAge);
  }

  @override
  Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  }) {
    return datasource.isEnrolled(
      classId: classId,
      childProfileId: childProfileId,
    );
  }

  @override
  Future<void> deleteClass(String classId) => datasource.deleteClass(classId);

  @override
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
  }) {
    return datasource.joinClass(
      classId: classId,
      displayName: displayName,
      email: email,
      role: role,
      studentId: studentId,
      childProfileId: childProfileId,
      parentUid: parentUid,
      age: age,
      focusSubject: focusSubject,
    );
  }

  @override
  Future<String> getCurrentTeacherFirstName() {
    return datasource.getCurrentTeacherFirstName();
  }
}

// Project imports:
import 'package:edu_play/features/teacher_registration/data/datasources/teacher_registration_datasource.dart';
import 'package:edu_play/features/teacher_registration/domain/repositories/teacher_registration_repository.dart';

class FirebaseTeacherRegistrationRepository
    implements TeacherRegistrationRepository {
  const FirebaseTeacherRegistrationRepository({required this.datasource});

  final TeacherRegistrationDatasource datasource;

  @override
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String schoolName,
  }) {
    return datasource.registerTeacher(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      schoolName: schoolName,
    );
  }
}

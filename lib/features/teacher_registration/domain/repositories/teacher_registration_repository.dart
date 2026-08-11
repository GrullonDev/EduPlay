abstract class TeacherRegistrationRepository {
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String schoolName,
  });
}

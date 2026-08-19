// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/student_dashboard/services/student_session_navigation_service.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

/// Self-registration for a teen (15+) who registers without a parent
/// account. Creates the Firebase account + role doc via [AuthRepository],
/// then creates the gameplay profile (PIN, avatar, etc.) the same way a
/// parent would add a child, via [ChildProfilesService.addProfile].
class RegisterStudentBloc with ChangeNotifier {
  RegisterStudentBloc({
    required BuildContext context,
    required this.authRepository,
    required this.age,
  }) : _context = context;

  final BuildContext _context;
  final AuthRepository authRepository;
  final int age;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController guardianEmailController = TextEditingController();

  bool loading = false;
  String? errorMessage;

  Future<void> submit() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage = 'Completa tu nombre, correo y contraseña.';
      notifyListeners();
      return;
    }

    loading = true;
    errorMessage = null;
    notifyListeners();

    final guardianEmail = guardianEmailController.text.trim();

    final user = await authRepository.registerIndependentStudent(
      email: email,
      password: password,
      name: name,
      age: age,
      guardianEmail: guardianEmail.isEmpty ? null : guardianEmail,
    );

    if (user == null) {
      loading = false;
      errorMessage = 'No se pudo crear tu cuenta. Intenta de nuevo.';
      notifyListeners();
      return;
    }

    final profile = await ChildProfilesService.addProfile(
      name: name,
      age: age,
      focusSubject: 'Matemáticas',
      existingCount: 0,
    );
    await StudentSessionNavigationService.rememberChildPin(profile.pin);

    if (!_context.mounted) return;
    Navigator.of(_context).pushNamedAndRemoveUntil(
      RouterPaths.studentDashboard,
      (route) => false,
      arguments: profile,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    guardianEmailController.dispose();
    super.dispose();
  }
}

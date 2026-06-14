import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class LoginBloc extends ChangeNotifier {
  LoginBloc({
    required BuildContext context,
    required this.authRepository,
    this.userType,
  }) : _context = context;

  final BuildContext _context;
  final AuthRepository authRepository;

  /// Context the user came from: 'parent' or 'teacher'. Determines which
  /// dashboard to navigate to after a successful login.
  final String? userType;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool rememberMe = false;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    notifyListeners();
  }

  Future<void> login() async {
    isLoading = true;
    notifyListeners();

    // Set persistence before signing in: LOCAL keeps the session after
    // browser restart; SESSION clears it when the tab closes.
    await FirebaseAuth.instance.setPersistence(
      rememberMe ? Persistence.LOCAL : Persistence.SESSION,
    );

    User? user = await authRepository.loginParent(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    isLoading = false;
    notifyListeners();

    if (!_context.mounted) return;

    if (user != null) {
      Navigator.pushNamedAndRemoveUntil(
        _context,
        userType == 'teacher'
            ? RouterPaths.teacherDashboard
            : RouterPaths.parentsDashboard,
        (route) => false,
      );
    } else {
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Correo o contraseña incorrectos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

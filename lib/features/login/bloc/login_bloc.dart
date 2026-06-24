import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(
          'Campos requeridos', 'Por favor ingresa tu correo y contraseña.');
      return;
    }

    isLoading = true;
    notifyListeners();

    // Set persistence before signing in: LOCAL keeps the session after
    // browser restart; SESSION clears it when the tab closes.
    await FirebaseAuth.instance.setPersistence(
      rememberMe ? Persistence.LOCAL : Persistence.SESSION,
    );

    try {
      final user = await authRepository.loginParent(
        email: email,
        password: password,
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
      }
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      notifyListeners();
      if (!_context.mounted) return;

      final (title, message) = _messageForCode(e.code);
      _showError(title, message);
    } catch (_) {
      isLoading = false;
      notifyListeners();
      if (!_context.mounted) return;
      _showError('Error de conexión',
          'No se pudo conectar. Verifica tu conexión a internet e intenta de nuevo.');
    }
  }

  static (String, String) _messageForCode(String code) {
    switch (code) {
      case 'user-not-found':
      case 'invalid-email':
        return (
          'Correo no registrado',
          'No encontramos una cuenta con ese correo. ¿Quieres registrarte?'
        );
      case 'wrong-password':
      case 'invalid-credential':
        return (
          'Contraseña incorrecta',
          'La contraseña no coincide. Verifica e intenta de nuevo.'
        );
      case 'too-many-requests':
        return (
          'Demasiados intentos',
          'Cuenta temporalmente bloqueada por seguridad. Espera unos minutos o restablece tu contraseña.'
        );
      case 'user-disabled':
        return (
          'Cuenta desactivada',
          'Esta cuenta ha sido desactivada. Contacta a soporte.'
        );
      case 'network-request-failed':
        return (
          'Sin conexión',
          'Verifica tu conexión a internet e intenta de nuevo.'
        );
      default:
        return (
          'Error al iniciar sesión',
          'Correo o contraseña incorrectos. Intenta de nuevo.'
        );
    }
  }

  void _showError(String title, String message) {
    showDialog(
      context: _context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E1B6A)),
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(fontSize: 14, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1B6A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Aceptar',
                style: GoogleFonts.nunito(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

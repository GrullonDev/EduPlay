import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class LoginLayout extends StatelessWidget {
  const LoginLayout({super.key, this.userType});

  /// Context the user came from: 'parent' or 'teacher'. Customizes the
  /// copy shown on the login screen.
  final String? userType;

  String get _title {
    switch (userType) {
      case 'teacher':
        return 'Acceso Profesores';
      case 'parent':
        return 'Acceso Padres';
      default:
        return '¡EduPlay!';
    }
  }

  String get _subtitle {
    switch (userType) {
      case 'teacher':
        return 'Gestiona tus clases y recursos.';
      case 'parent':
        return 'Sigue el progreso de tus hijos.';
      default:
        return 'Aprende jugando en esta aventura mágica.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 48.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.school_rounded,
                      size: 80,
                      color: Color(0xFF6C63FF), // Primary color from theme
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF6C63FF),
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[700],
                            fontSize: 18,
                          ),
                    ),
                    const SizedBox(height: 32),
                    const _LoginForm(),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '¿No tienes cuenta?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                              context, RouterPaths.registerParents),
                          child: const Text('Regístrate'),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, RouterPaths.landing),
                      child: const Text('Conoce EduPlay'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginBloc>(
      builder: (context, bloc, __) {
        return Column(
          children: [
            TextField(
              controller: bloc.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bloc.passwordController,
              obscureText: bloc.obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    bloc.obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: bloc.togglePasswordVisibility,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bloc.isLoading ? null : bloc.login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: bloc.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'INICIAR SESIÓN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

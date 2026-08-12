import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/register_student/bloc/register_student_bloc.dart';
import 'package:edu_play/utils/injection_container.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);

/// Self-registration form for a 15+ teen who doesn't have a parent account.
/// Expects the already-collected age as the route argument (an [int]).
class RegisterStudentPage extends StatelessWidget {
  const RegisterStudentPage({super.key, required this.age});

  final int age;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterStudentBloc>(
      create: (context) => RegisterStudentBloc(
        context: context,
        authRepository: sl.get<AuthRepository>(),
        age: age,
      ),
      child: const _RegisterStudentLayout(),
    );
  }
}

class _RegisterStudentLayout extends StatefulWidget {
  const _RegisterStudentLayout();

  @override
  State<_RegisterStudentLayout> createState() =>
      _RegisterStudentLayoutState();
}

class _RegisterStudentLayoutState extends State<_RegisterStudentLayout> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RegisterStudentBloc>();

    return Scaffold(
      backgroundColor: _kBg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _kNavy.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFF8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.rocket_launch_rounded,
                        color: _kNavy, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Crea tu cuenta',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: _kNavy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Como tienes ${bloc.age} años, puedes registrarte tú mismo. '
                    'Tu cuenta y tu código secreto quedarán listos al instante.',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _LabeledField(
                    label: 'Tu nombre',
                    child: TextField(
                      controller: bloc.nameController,
                      decoration: _inputDecoration('Ej: Sofía Martínez'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Correo electrónico',
                    child: TextField(
                      controller: bloc.emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration('tucorreo@ejemplo.com'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _LabeledField(
                    label: 'Contraseña',
                    child: TextField(
                      controller: bloc.passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDecoration('••••••••').copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                  ),
                  if (bloc.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      bloc.errorMessage!,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: const Color(0xFFC0392B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: bloc.loading ? null : bloc.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kCoral,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _kCoral.withValues(alpha: 0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: bloc.loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Crear mi cuenta',
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: bloc.loading
                          ? null
                          : () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                                RouterPaths.studentDashboard,
                                (route) => false,
                              ),
                      child: Text(
                        'Prefiero jugar como invitado',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kNavy, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

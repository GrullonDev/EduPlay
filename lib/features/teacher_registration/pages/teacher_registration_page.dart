import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDk = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kRed = Color(0xFFC0392B);
const _kBg = Color(0xFFF8F7FF);

// ─────────────────────────────────────────────────────────────────────────────

/// Self-service teacher registration.
///
/// Creates a Firebase Auth account and writes the teacher document to
/// `teachers/{uid}` in Firestore. The AuthGate then detects `role:'teacher'`
/// and routes directly to TeacherDashboardLayout on the next launch.
class TeacherRegistrationPage extends StatefulWidget {
  const TeacherRegistrationPage({super.key});

  @override
  State<TeacherRegistrationPage> createState() =>
      _TeacherRegistrationPageState();
}

class _TeacherRegistrationPageState extends State<TeacherRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1 — Create Firebase Auth account
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final user = credential.user;
      if (user == null) throw Exception('No user returned');

      // 2 — Write teacher document so AuthGate can resolve role
      await FirebaseFirestore.instance
          .collection('teachers')
          .doc(user.uid)
          .set({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'schoolName': _schoolCtrl.text.trim(),
        'role': 'teacher',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Send verification email immediately after account creation.
      await user.sendEmailVerification();

      if (!mounted) return;

      // AuthGate will automatically route to TeacherDashboardLayout —
      // just push the app back to the root so it re-evaluates auth state.
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouterPaths.teacherDashboard,
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _authError(e.code);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado. Inicia sesión.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no es válido.';
      default:
        return 'Error al registrar. Código: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      backgroundColor: _kBg,
      body: isDesktop ? _desktop() : _mobile(),
    );
  }

  // ── Desktop layout (split-screen) ─────────────────────────────────────────

  Widget _desktop() {
    return Row(
      children: [
        // Left: navy panel
        Expanded(
          flex: 4,
          child: Container(
            color: _kNavyDk,
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _backButton(),
                const SizedBox(height: 48),
                Text('EduPlay',
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
                const SizedBox(height: 8),
                Text('Panel Docente',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white54,
                    )),
                const SizedBox(height: 56),
                ..._benefits.map((b) => _BenefitRow(icon: b.$1, text: b.$2)),
              ],
            ),
          ),
        ),
        // Right: form
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: _FormCard(
              formKey: _formKey,
              firstNameCtrl: _firstNameCtrl,
              lastNameCtrl: _lastNameCtrl,
              emailCtrl: _emailCtrl,
              passwordCtrl: _passwordCtrl,
              schoolCtrl: _schoolCtrl,
              obscurePassword: _obscurePassword,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onRegister: _register,
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile layout ─────────────────────────────────────────────────────────

  Widget _mobile() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _backButton(),
          const SizedBox(height: 24),
          Text('Registro de Docentes',
              style: GoogleFonts.fredoka(
                fontSize: 26,
                color: _kNavy,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 24),
          _FormCard(
            formKey: _formKey,
            firstNameCtrl: _firstNameCtrl,
            lastNameCtrl: _lastNameCtrl,
            emailCtrl: _emailCtrl,
            passwordCtrl: _passwordCtrl,
            schoolCtrl: _schoolCtrl,
            obscurePassword: _obscurePassword,
            isLoading: _isLoading,
            errorMessage: _errorMessage,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onRegister: _register,
          ),
        ],
      ),
    );
  }

  Widget _backButton() => TextButton.icon(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded,
            size: 18, color: Colors.white54),
        label: Text('Volver',
            style: GoogleFonts.nunito(
              color: Colors.white54,
              fontSize: 13,
            )),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
      );
}

// ── Benefits list ─────────────────────────────────────────────────────────────

const _benefits = [
  (Icons.class_rounded, 'Gestiona tus clases y alumnos'),
  (Icons.bar_chart_rounded, 'Seguimiento de rendimiento en tiempo real'),
  (Icons.assignment_rounded, 'Crea y asigna retos gamificados'),
  (Icons.picture_as_pdf, 'Genera informes para padres y dirección'),
];

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _kCoral, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Text(text,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.4,
                ))),
      ]),
    );
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.schoolCtrl,
    required this.obscurePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onRegister,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController schoolCtrl;
  final bool obscurePassword;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 480),
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crear cuenta docente',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                )),
            const SizedBox(height: 6),
            Text('Accede al panel de gestión académica',
                style:
                    GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 28),

            // Name row
            Row(children: [
              Expanded(
                  child: _field(
                ctrl: firstNameCtrl,
                label: 'Nombre',
                hint: 'Ana',
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              )),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(
                ctrl: lastNameCtrl,
                label: 'Apellido',
                hint: 'García',
                validator: (v) => (v?.isEmpty ?? true) ? 'Requerido' : null,
              )),
            ]),
            const SizedBox(height: 16),

            _field(
              ctrl: emailCtrl,
              label: 'Correo institucional',
              hint: 'docente@escuela.edu',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (!v.contains('@')) return 'Correo no válido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _field(
              ctrl: passwordCtrl,
              label: 'Contraseña',
              hint: '••••••••',
              obscure: obscurePassword,
              onToggleObscure: onTogglePassword,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),

            _field(
              ctrl: schoolCtrl,
              label: 'Nombre del centro educativo (opcional)',
              hint: 'Ej. Colegio San Martín',
            ),
            const SizedBox(height: 24),

            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 16, color: _kRed),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(errorMessage!,
                          style:
                              GoogleFonts.nunito(fontSize: 12, color: _kRed))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : onRegister,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 20),
                label: Text(
                  isLoading ? 'Creando cuenta...' : 'Crear cuenta',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(
                    context, RouterPaths.login,
                    arguments: 'teacher'),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: Colors.grey[600]),
                    children: [
                      const TextSpan(text: '¿Ya tienes cuenta? '),
                      TextSpan(
                        text: 'Inicia sesión',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: _kNavy,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                          decorationColor: _kNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kNavy,
            )),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                GoogleFonts.nunito(fontSize: 14, color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F7FF),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kNavy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kRed),
            ),
            suffixIcon: onToggleObscure != null
                ? IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 18,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

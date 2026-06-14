import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/login/bloc/login_bloc.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kNavyLight = Color(0xFF2D2A82);
const _kRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFE74C3C);

class LoginLayout extends StatelessWidget {
  const LoginLayout({super.key, this.userType});

  final String? userType;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    if (isDesktop) {
      return Row(
        children: [
          // Left navy panel
          Expanded(
            flex: 5,
            child: _LeftPanel(userType: userType),
          ),
          // Right form panel
          Expanded(
            flex: 4,
            child: _RightPanel(userType: userType),
          ),
        ],
      );
    }

    // Mobile: just the form with a compact header
    return SingleChildScrollView(
      child: Column(
        children: [
          _MobileHeader(),
          _RightPanel(userType: userType),
        ],
      ),
    );
  }
}

// ── Left panel ────────────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({this.userType});

  final String? userType;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Donde el aprendizaje y la diversión se\nencontran para crear un futuro brillante.',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Feature cards
          _FeatureCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFFF4A82B),
            title: 'Para Escuelas',
            subtitle: 'Herramientas analíticas robustas para educadores.',
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.videogame_asset_rounded,
            iconColor: const Color(0xFFF4A82B),
            title: 'Para Estudiantes',
            subtitle: 'Misiones y desafíos que motivan el progreso diario.',
          ),
          const Spacer(),
          Text(
            '© 2024 EduPlay Learning.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _kNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Text(
        'EduPlay',
        style: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── Right panel ───────────────────────────────────────────────────────────────

class _RightPanel extends StatelessWidget {
  const _RightPanel({this.userType});

  final String? userType;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Container(
      color: const Color(0xFFF8F7FF),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64 : 24,
              vertical: 48,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(40),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Bienvenido de nuevo',
                      style: GoogleFonts.fredoka(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ingresa tus credenciales para acceder a tu panel.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const _LoginForm(),
                    const SizedBox(height: 24),
                    _Divider(),
                    const SizedBox(height: 20),
                    _SocialButtons(),
                    const SizedBox(height: 28),
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(text: '¿No tienes una cuenta? '),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => Navigator.pushNamed(
                                    context, RouterPaths.registerParents),
                                child: Text(
                                  'Contáctanos para tu escuela',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    color: _kNavy,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: _kNavy,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

// ── Login form ────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginBloc>(
      builder: (context, bloc, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('Correo electrónico'),
          const SizedBox(height: 6),
          _TextField(
            controller: bloc.emailController,
            hint: 'ejemplo@escuela.edu',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _FieldLabel('Contraseña')),
              GestureDetector(
                onTap: () {}, // TODO: forgot password
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: _kNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _TextField(
            controller: bloc.passwordController,
            hint: '••••••••',
            obscure: true,
            onToggleObscure: bloc.togglePasswordVisibility,
            isObscured: bloc.obscurePassword,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: Checkbox(
                  value: bloc.rememberMe,
                  onChanged: (_) => bloc.toggleRememberMe(),
                  activeColor: _kNavy,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Recordarme en este dispositivo',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: bloc.isLoading ? null : bloc.login,
              icon: bloc.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.arrow_forward_rounded, size: 20),
              label: Text(
                bloc.isLoading ? 'Ingresando...' : 'Ingresar',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared field widgets ──────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.isObscured = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool isObscured;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure && isObscured,
      style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: Colors.grey[400],
        ),
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _kNavy, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 20,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}

// ── Divider "O CONTINUAR CON" ─────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O CONTINUAR CON',
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: Colors.grey[400],
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300])),
      ],
    );
  }
}

// ── Social buttons ────────────────────────────────────────────────────────────

class _SocialButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialButton(label: 'Google', iconPath: 'google')),
        const SizedBox(width: 12),
        Expanded(
            child: _SocialButton(label: 'Microsoft', iconPath: 'microsoft')),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.iconPath});

  final String label;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    final icon = iconPath == 'google'
        ? Icons.g_mobiledata_rounded
        : Icons.window_rounded;

    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 20, color: _kNavy),
      label: Text(
        label,
        style: GoogleFonts.nunito(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: _kNavy,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

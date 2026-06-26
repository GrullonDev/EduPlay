import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';
import 'package:edu_play/utils/responsive.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kRed = Color(0xFFC0392B);

class RegisterParentsLayout extends StatefulWidget {
  const RegisterParentsLayout({super.key});

  @override
  State<RegisterParentsLayout> createState() => _RegisterParentsLayoutState();
}

class _RegisterParentsLayoutState extends State<RegisterParentsLayout> {
  final _confirmPasswordController = TextEditingController();
  final _mobileScrollController = ScrollController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _mobileScrollController.dispose();
    super.dispose();
  }

  void _scrollToForm() {
    // Scroll to the end of the mobile SingleChildScrollView, which puts the
    // form card in view. On desktop the form panel is always visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mobileScrollController.hasClients) {
        _mobileScrollController.animateTo(
          _mobileScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Scaffold(
      backgroundColor: const Color(0xFFF0EFF8),
      body: Column(
        children: [
          _Navbar(onStartFree: isDesktop ? null : _scrollToForm),
          Expanded(
            child: isDesktop ? _desktopBody() : _mobileBody(),
          ),
          _Footer(),
        ],
      ),
    );
  }

  Widget _desktopBody() {
    return Row(
      children: [
        // Left: image + benefits
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: _LeftContent(),
          ),
        ),
        // Right: form — always visible on desktop, no scroll needed.
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 48),
            child: _FormCard(
              confirmPasswordController: _confirmPasswordController,
              obscurePassword: _obscurePassword,
              obscureConfirm: _obscureConfirm,
              acceptedTerms: _acceptedTerms,
              onTogglePassword: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onToggleConfirm: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onToggleTerms: (v) => setState(() => _acceptedTerms = v ?? false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileBody() {
    return SingleChildScrollView(
      controller: _mobileScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          _LeftContent(),
          const SizedBox(height: 24),
          _FormCard(
            confirmPasswordController: _confirmPasswordController,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            acceptedTerms: _acceptedTerms,
            onTogglePassword: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onToggleConfirm: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onToggleTerms: (v) => setState(() => _acceptedTerms = v ?? false),
          ),
        ],
      ),
    );
  }
}

// ── Navbar ────────────────────────────────────────────────────────────────────

class _Navbar extends StatelessWidget {
  const _Navbar({this.onStartFree});

  /// Called when the "Start Free" CTA is tapped.
  /// Null on desktop (form is always visible in the right panel).
  final VoidCallback? onStartFree;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 64 : 20,
            vertical: 14,
          ),
          child: Row(
            children: [
              Text(
                'EduPlay',
                style: GoogleFonts.fredoka(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _kNavy,
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 40),
                ...[
                  'Curriculum',
                  'Games',
                  'For Teachers',
                  'Pricing',
                ].map(
                  (label) => Padding(
                    padding: const EdgeInsets.only(right: 28),
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouterPaths.login),
                child: Text(
                  'Login',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                // On mobile: scroll to the sign-up form.
                // On desktop: form is already in view (no-op).
                onPressed: onStartFree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Start Free',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Left content ──────────────────────────────────────────────────────────────

class _LeftContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Illustration placeholder
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 240,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8E6FF),
                  Color(0xFFD5D3F5),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.family_restroom_rounded,
                  size: 100,
                  color: _kNavy.withValues(alpha: 0.15),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_alt_rounded,
                        size: 64, color: Color(0xFF6C63FF)),
                    const SizedBox(height: 12),
                    Text(
                      'EduPlay Familias',
                      style: GoogleFonts.fredoka(
                        fontSize: 20,
                        color: _kNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Acompaña su crecimiento',
          style: GoogleFonts.fredoka(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 20),
        const _BenefitItem(
          icon: Icons.bar_chart_rounded,
          iconColor: Color(0xFF6C63FF),
          accentColor: Color(0xFF6C63FF),
          title: 'Seguimiento en tiempo real',
          description:
              'Visualiza el progreso detallado de tus hijos en cada asignatura y competencia.',
        ),
        const SizedBox(height: 12),
        const _BenefitItem(
          icon: Icons.check_box_rounded,
          iconColor: _kRed,
          accentColor: _kRed,
          title: 'Desafíos personalizados',
          description:
              'Asigna misiones y retos especiales para reforzar temas específicos de forma divertida.',
        ),
      ],
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.iconColor,
    required this.accentColor,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color iconColor;
  final Color accentColor;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _kNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Form card ─────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.acceptedTerms,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onToggleTerms,
  });

  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final bool acceptedTerms;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final ValueChanged<bool?> onToggleTerms;

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterParentsBloc>(
      builder: (context, bloc, _) {
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decorative icon
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0EFF8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: Color(0xFFD0CFF0), size: 32),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registro de Padres',
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Únete a la comunidad EduPlay y transforma el aprendizaje de tus hijos.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Name + Email row
              _FieldRow(
                children: [
                  _LabeledField(
                    label: 'Nombre completo',
                    child: _Input(
                      controller: bloc.firstNameController,
                      hint: 'Ej: Elena García',
                    ),
                  ),
                  _LabeledField(
                    label: 'Correo electrónico',
                    child: _Input(
                      controller: bloc.emailController,
                      hint: 'elena@ejemplo.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password row
              _FieldRow(
                children: [
                  _LabeledField(
                    label: 'Contraseña',
                    child: _Input(
                      controller: bloc.passwordController,
                      hint: '••••••••',
                      obscure: obscurePassword,
                      onToggleObscure: onTogglePassword,
                    ),
                  ),
                  _LabeledField(
                    label: 'Confirmar contraseña',
                    child: _Input(
                      controller: confirmPasswordController,
                      hint: '••••••••',
                      obscure: obscureConfirm,
                      onToggleObscure: onToggleConfirm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Terms checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: acceptedTerms,
                      onChanged: onToggleTerms,
                      activeColor: _kNavy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                        children: [
                          const TextSpan(text: 'Acepto los '),
                          TextSpan(
                            text: 'Términos y Condiciones',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: _kNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' y la '),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              color: _kNavy,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: ' de EduPlay.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: acceptedTerms ? bloc.registerParent : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kRed,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Crear cuenta',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    children: [
                      const TextSpan(text: '¿Ya tienes una cuenta? '),
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, RouterPaths.login),
                          child: Text(
                            'Inicia sesión',
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
        );
      },
    );
  }
}

// ── Field helpers ─────────────────────────────────────────────────────────────

class _FieldRow extends StatelessWidget {
  const _FieldRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = ScreenSize.of(context);
    final isDesktop = !s.isMobile; // tablet + desktop get side-by-side layout
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 14),
            Expanded(child: children[i]),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          children[i],
        ],
      ],
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

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.onToggleObscure,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
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
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixIcon: onToggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                  size: 18,
                ),
                onPressed: onToggleObscure,
              )
            : null,
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDesktop = ScreenSize.of(context).isDesktop;

    return Container(
      color: const Color(0xFFF0EFF8),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 32,
      ),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _FooterBrand()),
                const Expanded(child: _FooterLinks('Product', _productLinks)),
                const Expanded(
                    child: _FooterLinks('Resources', _resourceLinks)),
                Expanded(child: _FooterNewsletter()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FooterBrand(),
                const SizedBox(height: 24),
                const _FooterLinks('Product', _productLinks),
                const SizedBox(height: 24),
                const _FooterLinks('Resources', _resourceLinks),
                const SizedBox(height: 24),
                _FooterNewsletter(),
              ],
            ),
    );
  }

  static const _productLinks = [
    'Teacher Toolkit',
    'Parent Guide',
    'Research Labs',
  ];
  static const _resourceLinks = [
    'Privacy Policy',
    'Terms of Service',
  ];
}

class _FooterBrand extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EduPlay',
          style: GoogleFonts.fredoka(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '© ${DateTime.now().year} EduPlay. Aprendizaje basado en\nevidencia para la próxima generación.',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks(this.title, this.links);

  final String title;
  final List<String> links;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 10),
        for (final link in links) ...[
          Text(
            link,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _FooterNewsletter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Newsletter',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            fontSize: 13,
            color: _kNavy,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                style: GoogleFonts.nunito(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tu email',
                  hintStyle:
                      GoogleFonts.nunito(fontSize: 13, color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias! Te avisaremos pronto.'),
                  duration: Duration(seconds: 3),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Suscribirse',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

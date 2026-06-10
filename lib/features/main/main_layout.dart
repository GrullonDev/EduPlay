import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

const _kNavyColor = Color(0xFF24235B);
const _kFooterColor = Color(0xFFEAEAF7);

/// Home screen profile picker: lets the user choose whether they're a
/// kid, a parent or a teacher, and routes them accordingly.
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _MainHeader(desktop: desktop),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: desktop ? 64 : 20,
                vertical: desktop ? 64 : 40,
              ),
              child: Column(
                children: [
                  Text(
                    '¿Quién va a aprender hoy?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.fredoka(
                      fontSize: desktop ? 42 : 28,
                      fontWeight: FontWeight.w700,
                      color: _kNavyColor,
                    ),
                  ),
                  SizedBox(height: desktop ? 56 : 36),
                  desktop
                      ? IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _buildKidsCard(context)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildParentsCard(context)),
                              const SizedBox(width: 24),
                              Expanded(child: _buildTeachersCard(context)),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            _buildKidsCard(context),
                            const SizedBox(height: 20),
                            _buildParentsCard(context),
                            const SizedBox(height: 20),
                            _buildTeachersCard(context),
                          ],
                        ),
                  SizedBox(height: desktop ? 48 : 32),
                  const _HelpLink(),
                ],
              ),
            ),
            const _MainFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildKidsCard(BuildContext context) {
    return _ProfileCard(
      icon: Icons.sentiment_very_satisfied_rounded,
      title: 'Niños',
      subtitle: '¡Entra a jugar y aprender!',
      buttonLabel: 'Jugar Ahora',
      buttonIcon: Icons.arrow_forward_rounded,
      highlighted: true,
      onPressed: () => Navigator.pushNamed(context, RouterPaths.guestEntry),
    );
  }

  Widget _buildParentsCard(BuildContext context) {
    return _ProfileCard(
      icon: Icons.family_restroom_rounded,
      title: 'Padres',
      subtitle: 'Sigue el progreso de tus hijos',
      buttonLabel: 'Panel Familiar',
      buttonIcon: Icons.login_rounded,
      onPressed: () => Navigator.pushNamed(
        context,
        RouterPaths.login,
        arguments: 'parent',
      ),
    );
  }

  Widget _buildTeachersCard(BuildContext context) {
    return _ProfileCard(
      icon: Icons.school_rounded,
      title: 'Profesores',
      subtitle: 'Gestiona tus clases y recursos',
      buttonLabel: 'Herramientas Docentes',
      buttonIcon: Icons.login_rounded,
      onPressed: () => Navigator.pushNamed(
        context,
        RouterPaths.login,
        arguments: 'teacher',
      ),
    );
  }
}

class _MainHeader extends StatelessWidget {
  const _MainHeader({required this.desktop});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 64 : 20,
        vertical: 20,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rocket_launch_rounded,
            color: AppTheme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 8),
          Text(
            'EduPlay',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = highlighted ? Colors.white : _kNavyColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: highlighted ? AppTheme.accentColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: highlighted ? null : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: highlighted ? 0.12 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.2)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: highlighted ? Colors.white : AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 15,
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.9)
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),
          highlighted
              ? ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(buttonIcon, color: AppTheme.accentColor),
                  label: Text(buttonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.accentColor,
                  ),
                )
              : OutlinedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(buttonIcon, color: _kNavyColor),
                  label: Text(buttonLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kNavyColor,
                    side: const BorderSide(color: _kNavyColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _HelpLink extends StatelessWidget {
  const _HelpLink();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.help_outline_rounded, color: Colors.grey[500], size: 20),
        const SizedBox(width: 8),
        Text(
          '¿Necesitas ayuda para empezar?',
          style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 15),
        ),
      ],
    );
  }
}

class _MainFooter extends StatelessWidget {
  const _MainFooter();

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    return Container(
      width: double.infinity,
      color: _kFooterColor,
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 64 : 20,
        vertical: 20,
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          Text(
            '© 2026 EduPlay. Aprendizaje basado en evidencia para la '
            'próxima generación.',
            style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 13),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Privacidad',
                style:
                    GoogleFonts.nunito(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(width: 24),
              Text(
                'Términos',
                style:
                    GoogleFonts.nunito(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

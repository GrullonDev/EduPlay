import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/core/config/release_flags.dart';
import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Sticky top navigation bar for the public landing page.
class LandingNavBar extends StatelessWidget {
  const LandingNavBar({
    super.key,
    required this.onNavigateToGames,
    required this.onNavigateToFamilies,
    required this.onNavigateToCommunity,
  });

  final VoidCallback onNavigateToGames;
  final VoidCallback onNavigateToFamilies;
  final VoidCallback onNavigateToCommunity;

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);
    final familiesLabel = ReleaseFlags.teacherExperienceEnabled
        ? 'Para Familias y Docentes'
        : 'Para Familias';

    return Material(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: desktop ? 64 : 16,
            vertical: 14,
          ),
          child: Row(
            children: [
              _buildLogo(),
              if (desktop) ...[
                const Spacer(),
                _NavLink(label: 'Juegos', onTap: onNavigateToGames),
                const SizedBox(width: 24),
                _NavLink(label: familiesLabel, onTap: onNavigateToFamilies),
                const SizedBox(width: 24),
                _NavLink(label: 'Comunidad', onTap: onNavigateToCommunity),
                const Spacer(),
              ] else
                const Spacer(),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouterPaths.login),
                child: Text(
                  'Ingresar',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, RouterPaths.registerParents),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                child: const Text('Empezar Gratis'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: AppTheme.textColor,
          ),
        ),
      ),
    );
  }
}

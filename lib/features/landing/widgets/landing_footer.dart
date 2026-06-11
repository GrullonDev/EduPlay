import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Footer with branding, quick links and project credits.
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_rounded,
                color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'EduPlay',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: Text(
            'Aprendizaje gamificado para que estudiar y enseñar sea una '
            'aventura.',
            style: GoogleFonts.nunito(color: Colors.grey[600], height: 1.5),
          ),
        ),
      ],
    );

    final columns = [
      _FooterColumn(
        title: 'Comenzar',
        items: const ['Jugar como invitado', 'Crear cuenta', 'Iniciar sesión'],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, RouterPaths.guestEntry);
              break;
            case 1:
              Navigator.pushNamed(context, RouterPaths.registerParents);
              break;
            case 2:
              Navigator.pushNamed(context, RouterPaths.login);
              break;
          }
        },
      ),
      const _FooterColumn(
        title: 'Comunidad',
        items: [
          'Canal de novedades (WhatsApp)',
          'Grupo de la comunidad',
          'GitHub: GrullonDev',
        ],
      ),
      const _FooterColumn(
        title: 'Legal',
        items: ['Política de Privacidad', 'Términos de Servicio'],
      ),
    ];

    return LandingSection(
      color: const Color(0xFF1F2233),
      padding: EdgeInsets.symmetric(
        horizontal: desktop ? 64 : 20,
        vertical: desktop ? 56 : 40,
      ),
      child: Theme(
        data: ThemeData(
          textTheme: GoogleFonts.nunitoTextTheme().apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            desktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: brand),
                      for (final column in columns)
                        Expanded(child: column),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      brand,
                      const SizedBox(height: 32),
                      for (final column in columns) ...[
                        column,
                        const SizedBox(height: 24),
                      ],
                    ],
                  ),
            const SizedBox(height: 32),
            Divider(color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            Text(
              '© 2026 EduPlay · Hecho con 💜 por GrullonDev',
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({
    required this.title,
    required this.items,
    this.onTap,
  });

  final String title;
  final List<String> items;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: onTap == null ? null : () => onTap!(i),
              child: Text(
                items[i],
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

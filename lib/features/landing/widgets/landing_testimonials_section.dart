import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';
import 'package:edu_play/features/landing/widgets/landing_section.dart';

/// Social-proof section with quotes from teachers and families.
class LandingTestimonialsSection extends StatelessWidget {
  const LandingTestimonialsSection({super.key});

  static const _testimonials = [
    (
      icon: Icons.school_rounded,
      name: 'Profe Ana',
      role: 'Maestra de primaria',
      quote: '"Mis estudiantes piden jugar Aventura Matemática incluso en el '
          'recreo. ¡Practican operaciones sin darse cuenta!"',
    ),
    (
      icon: Icons.family_restroom_rounded,
      name: 'Familia Pérez',
      role: 'Padres de dos niños',
      quote: '"La Zona de Padres nos muestra en qué necesita ayuda cada hijo, '
          'todo desde el celular y en pocos minutos."',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final desktop = isLandingDesktop(context);

    return LandingSection(
      color: AppTheme.backgroundColor,
      child: Column(
        children: [
          Text(
            'Lo que dice nuestra comunidad',
            textAlign: TextAlign.center,
            style: GoogleFonts.fredoka(
              fontSize: desktop ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 40),
          desktop
              ? Row(
                  children: [
                    Expanded(
                      child: _TestimonialCard(data: _testimonials[0]),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _TestimonialCard(data: _testimonials[1]),
                    ),
                  ],
                )
              : Column(
                  children: [
                    for (final t in _testimonials) ...[
                      _TestimonialCard(data: t),
                      if (t != _testimonials.last) const SizedBox(height: 20),
                    ],
                  ],
                ),
        ],
      ),
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  const _TestimonialCard({required this.data});

  final ({IconData icon, String name, String role, String quote}) data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Icon(data.icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    data.role,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            data.quote,
            style: GoogleFonts.nunito(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

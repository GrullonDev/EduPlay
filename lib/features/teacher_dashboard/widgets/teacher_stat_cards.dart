import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';

/// Row of small stat cards summarizing the class: total students, assigned
/// challenges and average progress. Wraps onto multiple lines on narrow
/// screens.
class TeacherStatCardsRow extends StatelessWidget {
  const TeacherStatCardsRow({
    super.key,
    required this.totalStudents,
    required this.newStudentsThisWeek,
    required this.activeChallenges,
    required this.completedChallenges,
    required this.averageProgress,
  });

  final int totalStudents;
  final int newStudentsThisWeek;
  final int activeChallenges;
  final int completedChallenges;
  final double averageProgress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final cards = [
          _StatCard(
            icon: Icons.groups_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Total de Estudiantes',
            value: '$totalStudents',
            subtitle: newStudentsThisWeek > 0
                ? '+$newStudentsThisWeek esta semana'
                : null,
          ),
          _StatCard(
            icon: Icons.flag_rounded,
            iconColor: AppTheme.secondaryColor,
            title: 'Retos Asignados',
            value: '$activeChallenges activos',
            subtitle: '$completedChallenges completados',
          ),
          _StatCard(
            icon: Icons.trending_up_rounded,
            iconColor: const Color(0xFFFF9800),
            title: 'Progreso Promedio',
            value: '${(averageProgress * 100).round()}%',
            subtitle: null,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                cards[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.nunito(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}

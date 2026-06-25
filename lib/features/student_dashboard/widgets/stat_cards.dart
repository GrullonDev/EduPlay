import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';

/// Row of small stat cards: current streak, level/XP progress and active
/// challenge count. Wraps onto multiple lines on narrow screens.
class StatCardsRow extends StatelessWidget {
  const StatCardsRow({
    super.key,
    required this.streak,
    required this.level,
    required this.xpIntoLevel,
    required this.xpProgress,
    required this.activeChallenges,
  });

  final int streak;
  final int level;
  final int xpIntoLevel;
  final double xpProgress;
  final int activeChallenges;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 720;
        final cards = [
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFF7043),
            title: 'Racha Actual',
            value: '$streak ${streak == 1 ? 'día' : 'días'}',
            child: null,
          ),
          _StatCard(
            icon: Icons.military_tech_rounded,
            iconColor: AppTheme.primaryColor,
            title: 'Nivel $level',
            value: '$xpIntoLevel / 100 XP',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: xpProgress,
                minHeight: 8,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          _StatCard(
            icon: Icons.flag_rounded,
            iconColor: AppTheme.secondaryColor,
            title: 'Retos Activos',
            value: '$activeChallenges',
            child: null,
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
    required this.child,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final Widget? child;

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
          if (child != null) ...[
            const SizedBox(height: 10),
            child!,
          ],
        ],
      ),
    );
  }
}

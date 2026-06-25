import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/shared/widgets/simple_bar_chart.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Progreso del Estudiante" card: total points scored by the whole class
/// over each of the last few weeks.
class WeeklyProgressCard extends StatelessWidget {
  const WeeklyProgressCard({super.key, required this.weeklyTotals});

  /// Totals oldest-first, e.g. 4 entries for the last 4 weeks.
  final List<double> weeklyTotals;

  @override
  Widget build(BuildContext context) {
    final maxValue = weeklyTotals.isEmpty
        ? 1.0
        : weeklyTotals
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, double.infinity);

    final bars = [
      for (var i = 0; i < weeklyTotals.length; i++)
        BarChartEntry(
          label: 'Sem ${i + 1}',
          value: weeklyTotals[i] / maxValue,
          valueLabel: weeklyTotals[i].round().toString(),
          color: AppTheme.primaryColor,
        ),
    ];

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
              const Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                'Progreso del Estudiante',
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Puntos totales de la clase por semana',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          if (bars.every((b) => b.value == 0))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Aún no hay puntajes registrados esta semana.',
                  style: GoogleFonts.nunito(color: Colors.grey[600]),
                ),
              ),
            )
          else
            SimpleBarChart(bars: bars),
        ],
      ),
    );
  }
}

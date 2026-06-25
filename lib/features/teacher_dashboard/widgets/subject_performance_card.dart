import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Rendimiento por Materia" card: average score per subject over the last
/// 7 days, with a trend arrow comparing it to the previous 7 days.
class SubjectPerformanceCard extends StatelessWidget {
  const SubjectPerformanceCard({super.key, required this.performance});

  final List<SubjectPerformance> performance;

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
              const Icon(Icons.insights_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text(
                'Rendimiento por Materia',
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
            'Promedio de los últimos 7 días',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth >= 720
                  ? 4
                  : constraints.maxWidth >= 420
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  for (final entry in performance) _SubjectTile(entry: entry),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SubjectTile extends StatelessWidget {
  const _SubjectTile({required this.entry});

  final SubjectPerformance entry;

  @override
  Widget build(BuildContext context) {
    final trend = entry.trendDelta;
    final hasTrend = entry.hasData && trend != 0;
    final trendUp = trend > 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(entry.subject.icon, size: 18, color: entry.subject.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.subject.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          if (entry.hasData) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.percentage.round()}%',
                  style: GoogleFonts.fredoka(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textColor,
                  ),
                ),
                if (hasTrend) ...[
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Icon(
                      trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 16,
                      color: trendUp ? Colors.green : Colors.redAccent,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: entry.percentage / 100,
                minHeight: 6,
                backgroundColor: entry.subject.color.withValues(alpha: 0.12),
                color: entry.subject.color,
              ),
            ),
          ] else
            Text(
              'Sin datos aún',
              style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

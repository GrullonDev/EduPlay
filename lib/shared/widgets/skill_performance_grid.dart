import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/data/repositories/student_repository.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kGreen = Color(0xFF27AE60);
const _kCoral = Color(0xFFFF6E6C);

/// Renders concrete skill mastery ("Suma 90% · Resta 65%") instead of just
/// points — shared between the parent progress report and the teacher's
/// class performance panel so both read from the same `SkillPerformance`
/// data (`StudentRepository.getSkillPerformance[ForStudents]`).
class SkillPerformanceGrid extends StatelessWidget {
  const SkillPerformanceGrid({super.key, required this.items});
  final List<SkillPerformance> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => _SkillCard(item: item)).toList(),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({required this.item});
  final SkillPerformance item;

  Color get _accuracyColor {
    if (item.percentage >= 75) return _kGreen;
    if (item.percentage >= 50) return const Color(0xFFF39C12);
    return _kCoral;
  }

  @override
  Widget build(BuildContext context) {
    final trend = item.trendDelta;
    return Container(
      width: 168,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.skill.icon, size: 18, color: _kNavy),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.skill.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _kNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${item.percentage.round()}%',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _accuracyColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.accuracy.clamp(0, 1),
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation(_accuracyColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (trend.abs() >= 1)
                Icon(
                  trend > 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 13,
                  color: trend > 0 ? _kGreen : _kCoral,
                ),
              if (trend.abs() >= 1) const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '${item.totalAnswers} respuestas · últimos 7 días',
                  style: GoogleFonts.nunito(
                      fontSize: 10, color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

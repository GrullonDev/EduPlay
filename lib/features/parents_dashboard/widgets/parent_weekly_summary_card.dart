// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

const _kNavyDark = Color(0xFF14125A);

class ParentWeeklySummaryCard extends StatelessWidget {
  const ParentWeeklySummaryCard({
    super.key,
    required this.totalMinutes,
    required this.topSubject,
  });

  final int totalMinutes;
  final String topSubject;

  String get _timeLabel {
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kNavyDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RESUMEN SEMANAL',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),
          _SummaryRow(
            icon: Icons.access_time_rounded,
            label: 'Tiempo de Juego',
            value: totalMinutes > 0 ? _timeLabel : '-',
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.menu_book_rounded,
            label: 'Materia Top',
            value: topSubject.isNotEmpty ? topSubject : '-',
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

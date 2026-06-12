import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/utils/app_theme.dart';

/// A single bar in a [SimpleBarChart].
class BarChartEntry {
  const BarChartEntry({
    required this.label,
    required this.value,
    this.color = AppTheme.primaryColor,
    this.valueLabel,
  });

  /// Label drawn under the bar.
  final String label;

  /// Bar height as a fraction of the chart's max height, in `[0, 1]`.
  final double value;

  final Color color;

  /// Optional label drawn above the bar (e.g. a formatted total).
  final String? valueLabel;
}

/// Minimal bar chart built from [Container]s, styled after the dashboard
/// mockup on the landing page. Used for "Progreso del Estudiante" (weekly
/// totals) and other small comparisons that don't warrant a charting
/// dependency.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.bars,
    this.height = 160,
    this.barWidth = 28,
  });

  final List<BarChartEntry> bars;
  final double height;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final bar in bars)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (bar.valueLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      bar.valueLabel!,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                Container(
                  width: barWidth,
                  height: (height - 40) * bar.value.clamp(0.0, 1.0),
                  constraints: const BoxConstraints(minHeight: 4),
                  decoration: BoxDecoration(
                    color: bar.color,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  bar.label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

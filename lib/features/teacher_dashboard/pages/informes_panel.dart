import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kNavyDark = Color(0xFF14125A);
const _kCoral = Color(0xFFFF6E6C);
const _kLavender = Color(0xFFEEEDF8);

// ── Demo data ─────────────────────────────────────────────────────────────────

const _kRecentReports = [
  _ReportData(
    icon: Icons.picture_as_pdf_rounded,
    iconColor: Color(0xFFE11D48),
    title: 'Resumen Semanal – Semana 14',
    subtitle: 'Generado hoy, 09:15 AM',
    size: '2.4 MB',
    shared: false,
  ),
  _ReportData(
    icon: Icons.table_chart_rounded,
    iconColor: Color(0xFF3B82F6),
    title: 'Progreso Matemáticas – 4º A',
    subtitle: 'Generado ayer, 04:30 PM',
    size: '1.1 MB',
    shared: false,
  ),
  _ReportData(
    icon: Icons.task_alt_rounded,
    iconColor: Color(0xFF10B981),
    title: 'Evaluación Trimestral – Primer Periodo',
    subtitle: 'Generado hace 5 días',
    size: '15.8 MB',
    shared: true,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────

class InformesPanel extends StatelessWidget {
  const InformesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return Stack(
      children: [
        SingleChildScrollView(
          padding:
              EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(),
              const SizedBox(height: 24),

              // Top two cards
              wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 4, child: _SemanalesCard()),
                          const SizedBox(width: 16),
                          Expanded(flex: 6, child: _ReportBuilderCard()),
                        ],
                      ),
                    )
                  : Column(children: [
                      _SemanalesCard(),
                      const SizedBox(height: 16),
                      _ReportBuilderCard(),
                    ]),
              const SizedBox(height: 20),

              // Lower two cards
              wide
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: _ProgresoIndividualCard()),
                          const SizedBox(width: 16),
                          Expanded(child: _VisionClaseCard()),
                        ],
                      ),
                    )
                  : Column(children: [
                      _ProgresoIndividualCard(),
                      const SizedBox(height: 16),
                      _VisionClaseCard(),
                    ]),
              const SizedBox(height: 24),

              // Informes Recientes
              _InformesRecientes(),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),

        // FAB
        Positioned(
          right: 24,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: _kCoral,
            child: const Icon(Icons.insert_chart_outlined_rounded,
                color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Centro de Informes',
                style: GoogleFonts.fredoka(
                    fontSize: 22, color: _kNavy, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Analiza el progreso y genera reportes detallados\npara padres y administración.',
              style:
                  GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_rounded, size: 14, color: _kNavy),
          label: Text('Exportar Todo',
              style: GoogleFonts.nunito(
                  color: _kNavy, fontWeight: FontWeight.w700, fontSize: 13)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kNavy, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Informes Semanales card ───────────────────────────────────────────────────

class _SemanalesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today_rounded,
                  color: Color(0xFFD97706), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('ACTIVO',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF16A34A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Text('Informes Semanales',
              style: GoogleFonts.fredoka(
                  fontSize: 16, color: _kNavy, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            'Generación automática cada\nviernes a las 16:00h.',
            style: GoogleFonts.nunito(
                fontSize: 13, color: Colors.grey.shade500, height: 1.4),
          ),
          const Spacer(),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {},
            child: Row(children: [
              Text('Configurar parámetros',
                  style: GoogleFonts.nunito(
                      color: _kNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: _kNavy),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Custom Report Builder card ────────────────────────────────────────────────

class _ReportBuilderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Background decoration
          const Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.build_rounded, size: 100, color: Colors.white),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Custom Report Builder',
                  style: GoogleFonts.fredoka(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                'Combina métricas de asistencia, participación en retos y calificaciones para crear un informe único.',
                style: GoogleFonts.nunito(
                    color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    ['Filtros Avanzados', 'Gráficos Dinámicos', 'PDF / Excel']
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Text(t,
                                  style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ))
                        .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCoral,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Diseñar Informe Personalizado',
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progreso Individual card ──────────────────────────────────────────────────

class _ProgresoIndividualCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(top: BorderSide(color: Color(0xFFE11D48), width: 3)),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFFCE7F3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_search_rounded,
                  size: 18, color: Color(0xFFEC4899)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progreso Individual',
                    style: GoogleFonts.fredoka(
                        fontSize: 15,
                        color: _kNavy,
                        fontWeight: FontWeight.w700)),
                Text('Reportes detallados por alumno.',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          const _StudentRow(
              initials: 'SM',
              name: 'Sofía Martínez',
              metric: '+15% este mes',
              metricColor: Color(0xFF16A34A),
              avatarBg: Color(0xFFDBEAFE),
              avatarColor: Color(0xFF3B82F6)),
          const SizedBox(height: 8),
          const _StudentRow(
              initials: 'LG',
              name: 'Lucas García',
              metric: 'Requiere apoyo',
              metricColor: Color(0xFFE11D48),
              avatarBg: Color(0xFFFCE7F3),
              avatarColor: Color(0xFFEC4899)),
          const Divider(height: 24),
          GestureDetector(
            onTap: () {},
            child: Center(
              child: Text('Ver todos los estudiantes',
                  style: GoogleFonts.nunito(
                      color: _kNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.initials,
    required this.name,
    required this.metric,
    required this.metricColor,
    required this.avatarBg,
    required this.avatarColor,
  });
  final String initials;
  final String name;
  final String metric;
  final Color metricColor;
  final Color avatarBg;
  final Color avatarColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: avatarBg,
          child: Text(initials,
              style: GoogleFonts.nunito(
                  color: avatarColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name,
              style: GoogleFonts.nunito(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _kNavy)),
        ),
        Text(metric,
            style: GoogleFonts.nunito(
                fontSize: 12, color: metricColor, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ── Visión General de Clase card ──────────────────────────────────────────────

class _VisionClaseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(top: BorderSide(color: Color(0xFF3B82F6), width: 3)),
        boxShadow: [
          BoxShadow(
              color: _kNavy.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.donut_large_rounded,
                  size: 18, color: Color(0xFF3B82F6)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visión General de Clase',
                    style: GoogleFonts.fredoka(
                        fontSize: 15,
                        color: _kNavy,
                        fontWeight: FontWeight.w700)),
                Text('Estadísticas grupales y objetivos.',
                    style: GoogleFonts.nunito(
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ]),
          const SizedBox(height: 16),
          const _MetricBar(
              label: 'Objetivo Mensual: Comprensión Lectora',
              fraction: 0.78,
              color: Color(0xFFD97706)),
          const SizedBox(height: 10),
          const _MetricBar(
              label: 'Participación en Retos', fraction: 0.92, color: _kNavy),
          const Divider(height: 24),
          GestureDetector(
            onTap: () {},
            child: Center(
              child: Text('Analizar métricas grupales',
                  style: GoogleFonts.nunito(
                      color: _kNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.fraction,
    required this.color,
  });
  final String label;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 12, fontWeight: FontWeight.w600, color: _kNavy)),
          ),
          Text('${(fraction * 100).round()}%',
              style: GoogleFonts.nunito(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: const Color(0xFFE8E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Informes Recientes ────────────────────────────────────────────────────────

class _ReportData {
  const _ReportData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.shared,
  });
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String size;
  final bool shared;
}

class _InformesRecientes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(children: [
              Text('Informes Recientes',
                  style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text('Ver Histórico',
                    style: GoogleFonts.nunito(
                        color: _kCoral,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ]),
          ),
          ..._kRecentReports.map((r) => _ReportRow(data: r)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({required this.data});
  final _ReportData data;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;

    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: data.iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(data.icon, color: data.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.title,
                      style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kNavy)),
                  Text('${data.subtitle} • ${data.size}',
                      style: GoogleFonts.nunito(
                          fontSize: 11, color: Colors.grey.shade400)),
                ],
              ),
            ),
            if (wide) ...[
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined,
                    size: 14, color: Color(0xFF6366F1)),
                label: Text('Descargar',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF6366F1), width: 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),
              if (data.shared)
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_rounded,
                      size: 14, color: Color(0xFF9CA3AF)),
                  label: Text('Compartido',
                      style: GoogleFonts.nunito(
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE0DEFF), width: 1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded,
                      size: 14, color: Colors.white),
                  label: Text('Compartir con Padres',
                      style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kNavy,
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
            ] else
              const Row(children: [
                Icon(Icons.download_rounded,
                    size: 18, color: Color(0xFF6366F1)),
                SizedBox(width: 12),
                Icon(Icons.share_rounded, size: 18, color: _kNavy),
              ]),
          ]),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3))
      ],
    );

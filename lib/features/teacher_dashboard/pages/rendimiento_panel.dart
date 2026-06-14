import 'dart:math' show max;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Palette ───────────────────────────────────────────────────────────────────

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kAmber = Color(0xFFD97706);

// ── Demo data ─────────────────────────────────────────────────────────────────

const _kSubjects = [
  ('Mate', 0.84, 0.90),
  ('Lengua', 0.76, 0.85),
  ('Ciencias', 0.91, 0.88),
  ('Historia', 0.68, 0.80),
  ('Arte', 0.79, 0.82),
];

const _kAlertas = [
  ('MS', 'Mateo Sánchez', '-18% en Mate', Color(0xFF3B82F6)),
  ('LG', 'Lucía Gómez', '-16% en Lengua', Color(0xFFEC4899)),
];

const _kRanking = [
  ('AC', 'Alejandro Cano', '#4421', 9.8, 0.82, true, 42, 45,
      Color(0xFF6366F1)),
  ('SM', 'Sofía Martínez', '#4398', 9.4, 0.79, true, 38, 45,
      Color(0xFF3B82F6)),
  ('LG', 'Lucas García', '#4105', 8.7, 0.73, true, 35, 45,
      Color(0xFF10B981)),
  ('VL', 'Valeria Luna', '#4230', 7.9, 0.65, false, 28, 45,
      Color(0xFFF59E0B)),
];

// ─────────────────────────────────────────────────────────────────────────────

class RendimientoPanel extends StatefulWidget {
  const RendimientoPanel({super.key});

  @override
  State<RendimientoPanel> createState() => _RendimientoPanelState();
}

class _RendimientoPanelState extends State<RendimientoPanel> {
  String _clase = '5º Primaria A';
  String _asignatura = 'Todas';
  String _rango = 'Último mes';

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(
            clase: _clase,
            asignatura: _asignatura,
            rango: _rango,
            onClaseChanged: (v) => setState(() => _clase = v),
            onAsignaturaChanged: (v) => setState(() => _asignatura = v),
            onRangoChanged: (v) => setState(() => _rango = v),
          ),
          const SizedBox(height: 24),

          // Chart + alert card
          wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: _SubjectProgressCard()),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _AlertaCard()),
                    ],
                  ),
                )
              : Column(children: [
                  _SubjectProgressCard(),
                  const SizedBox(height: 20),
                  _AlertaCard(),
                ]),
          const SizedBox(height: 24),

          // Ranking table
          _RankingTable(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Header + filters ──────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({
    required this.clase,
    required this.asignatura,
    required this.rango,
    required this.onClaseChanged,
    required this.onAsignaturaChanged,
    required this.onRangoChanged,
  });

  final String clase;
  final String asignatura;
  final String rango;
  final ValueChanged<String> onClaseChanged;
  final ValueChanged<String> onAsignaturaChanged;
  final ValueChanged<String> onRangoChanged;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 700;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESTADÍSTICAS GLOBALES',
                style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: _kAmber,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3)),
            const SizedBox(height: 4),
            Text('Resumen del Curso\n2023-24',
                style: GoogleFonts.fredoka(
                    fontSize: 26,
                    color: _kNavy,
                    fontWeight: FontWeight.w700,
                    height: 1.15)),
          ],
        ),
        const Spacer(),
        if (wide)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(children: [
                _FilterDropdown(
                    label: 'Clase',
                    value: clase,
                    options: const [
                      '5º Primaria A',
                      '4º Primaria B',
                      '6º Primaria A'
                    ],
                    onChanged: onClaseChanged),
                const SizedBox(width: 12),
                _FilterDropdown(
                    label: 'Asignatura',
                    value: asignatura,
                    options: const [
                      'Todas',
                      'Matemáticas',
                      'Lengua',
                      'Ciencias'
                    ],
                    onChanged: onAsignaturaChanged),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                _FilterDropdown(
                    label: 'Rango',
                    value: rango,
                    options: const [
                      'Último mes',
                      'Último trimestre',
                      'Este año'
                    ],
                    onChanged: onRangoChanged),
                const SizedBox(width: 8),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kNavy,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_list_rounded,
                      color: Colors.white, size: 18),
                ),
              ]),
            ],
          ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0DEFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: _kNavy,
                              fontWeight: FontWeight.w600))))
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
              style: GoogleFonts.nunito(
                  fontSize: 12, color: _kNavy, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: Color(0xFF9CA3AF)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Subject progress chart ────────────────────────────────────────────────────

class _SubjectProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Progreso por Asignatura',
                style: GoogleFonts.fredoka(
                    fontSize: 16, color: _kNavy, fontWeight: FontWeight.w700)),
            const Spacer(),
            _LegendDot(color: const Color(0xFF3B82F6), label: 'Media actual'),
            const SizedBox(width: 12),
            _LegendDot(color: _kAmber, label: 'Objetivo'),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _GroupedBarChart(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 10, height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.nunito(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600)),
      ]);
}

class _GroupedBarChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: _kSubjects.map((s) {
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Media actual bar
                    Flexible(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: s.$2.clamp(0.05, 1.0),
                        child: Container(
                          width: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(s.$1,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Alerta card ───────────────────────────────────────────────────────────────

class _AlertaCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Alerta de Atención',
                style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            const Text('⚠️', style: TextStyle(fontSize: 16)),
          ]),
          const SizedBox(height: 8),
          Text(
            'Hay 4 estudiantes cuyo rendimiento ha bajado más de un 15% esta semana.',
            style: GoogleFonts.nunito(
                color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          ..._kAlertas.map((a) => _AlertaRow(
                initials: a.$1,
                name: a.$2,
                note: a.$3,
                color: a.$4,
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _kNavy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Ver Todos los Alertas',
                  style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertaRow extends StatelessWidget {
  const _AlertaRow({
    required this.initials,
    required this.name,
    required this.note,
    required this.color,
  });
  final String initials;
  final String name;
  final String note;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withOpacity(0.2),
          child: Text(initials,
              style: GoogleFonts.nunito(
                  color: color, fontWeight: FontWeight.w800, fontSize: 11)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Text(note,
                  style: GoogleFonts.nunito(
                      color: Colors.white60, fontSize: 11)),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded,
            size: 18, color: Colors.white38),
      ]),
    );
  }
}

// ── Ranking table ─────────────────────────────────────────────────────────────

class _RankingTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              Text('Ranking de Progreso',
                  style: GoogleFonts.fredoka(
                      fontSize: 16,
                      color: _kNavy,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded,
                    size: 14, color: Color(0xFF6366F1)),
                label: Text('Exportar',
                    style: GoogleFonts.nunito(
                        color: const Color(0xFF6366F1),
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ]),
          ),
          // Column headers
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 200,
                  child: Text('ESTUDIANTE',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                Expanded(
                  child: Text('PUNTUACIÓN MEDIA',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: 90,
                  child: Text('TENDENCIA',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: 120,
                  child: Text('RETOS COMPLETADOS',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
                SizedBox(
                  width: 60,
                  child: Text('ACCIONES',
                      style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ..._kRanking.map((r) => _RankingRow(data: r)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.data});
  // (initials, name, id, score, fraction, trending_up, done, total, color)
  final (String, String, String, double, double, bool, int, int, Color) data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(children: [
            // Student info
            SizedBox(
              width: 200,
              child: Row(children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: data.$9.withOpacity(0.15),
                  child: Text(data.$1,
                      style: GoogleFonts.nunito(
                          color: data.$9,
                          fontWeight: FontWeight.w800,
                          fontSize: 11)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.$2,
                        style: GoogleFonts.nunito(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kNavy)),
                    Text('ID: ${data.$3}',
                        style: GoogleFonts.nunito(
                            fontSize: 10, color: Colors.grey.shade400)),
                  ],
                ),
              ]),
            ),
            // Score + bar
            Expanded(
              child: Row(children: [
                Text(data.$4.toStringAsFixed(1),
                    style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: _kNavy,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: data.$5,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE8E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          data.$6
                              ? const Color(0xFF16A34A)
                              : _kCoral),
                    ),
                  ),
                ),
              ]),
            ),
            // Trend
            SizedBox(
              width: 90,
              child: Row(children: [
                Icon(
                  data.$6
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16,
                  color: data.$6
                      ? const Color(0xFF16A34A)
                      : _kCoral,
                ),
                const SizedBox(width: 4),
                Text('+4%',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: data.$6
                            ? const Color(0xFF16A34A)
                            : _kCoral,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
            // Completed challenges badge
            SizedBox(
              width: 120,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEDF8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${data.$7}/${data.$8}',
                    style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: _kNavy,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
              ),
            ),
            // Actions
            SizedBox(
              width: 60,
              child: Icon(Icons.visibility_outlined,
                  size: 18, color: const Color(0xFF6366F1)),
            ),
          ]),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: _kNavy.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3))
      ],
    );

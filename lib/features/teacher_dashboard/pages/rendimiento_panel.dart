import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kAmber = Color(0xFFD97706);

class RendimientoPanel extends StatelessWidget {
  const RendimientoPanel({super.key, required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;
    final alerts = bloc.supportStudents;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderSection(bloc: bloc),
          const SizedBox(height: 24),
          wide
              ? IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 6, child: _SubjectProgressCard(bloc: bloc)),
                      const SizedBox(width: 20),
                      Expanded(flex: 4, child: _AlertsCard(alerts: alerts)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _SubjectProgressCard(bloc: bloc),
                    const SizedBox(height: 20),
                    _AlertsCard(alerts: alerts),
                  ],
                ),
          const SizedBox(height: 24),
          _RankingTable(students: bloc.students),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final classLabel =
        bloc.classes.isEmpty ? 'Sin clases' : bloc.classes.first.name;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ESTADÍSTICAS GLOBALES',
              style: GoogleFonts.nunito(
                fontSize: 11,
                color: _kAmber,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Resumen del Curso\n${DateTime.now().year}',
              style: GoogleFonts.fredoka(
                fontSize: 26,
                color: _kNavy,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0DEFF)),
          ),
          child: Text(
            classLabel,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _kNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  const _SubjectProgressCard({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final items = bloc.subjectPerformance.isEmpty
        ? subjectCatalog
            .take(5)
            .map((subject) => (subject.label, 0.0, subject.color))
            .toList()
        : bloc.subjectPerformance
            .take(5)
            .map(
              (entry) => (
                entry.subject.label,
                (entry.averageScore / 100).clamp(0.0, 1.0),
                entry.subject.color,
              ),
            )
            .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progreso por Asignatura',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: _kNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const _LegendDot(color: Color(0xFF3B82F6), label: 'Media actual'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: FractionallySizedBox(
                          alignment: Alignment.bottomCenter,
                          heightFactor: item.$2 == 0 ? 0.04 : item.$2,
                          child: Container(
                            width: 24,
                            decoration: BoxDecoration(
                              color: item.$3.withValues(alpha: 0.2),
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                              border: Border.all(color: item.$3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.$1,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.alerts});

  final List<Map<String, dynamic>> alerts;

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
          Row(
            children: [
              Text(
                'Alerta de Atención',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Text('⚠️', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alerts.isEmpty
                ? 'Todavía no hay señales de refuerzo para tus alumnos.'
                : 'Estos estudiantes necesitan una revisión más cercana según su actividad reciente.',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (alerts.isEmpty)
            Text(
              'Sin alertas activas.',
              style: GoogleFonts.nunito(color: Colors.white60),
            )
          else
            ...alerts.map((student) => _AlertRow(student: student)),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({required this.student});

  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final name = student['name'] as String? ?? 'Estudiante';
    final note = (student['recentScoreCount'] as int? ?? 0) == 0
        ? 'Sin actividad reciente'
        : 'Promedio actual ${(student['recentAverage'] as num?)?.toStringAsFixed(1) ?? '0.0'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            child: Text(
              name[0].toUpperCase(),
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  note,
                  style:
                      GoogleFonts.nunito(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingTable extends StatelessWidget {
  const _RankingTable({required this.students});

  final List<Map<String, dynamic>> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text(
                  'Ranking de Progreso',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: _kNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Todavía no hay alumnos vinculados a tus clases.',
                style: GoogleFonts.nunito(color: Colors.grey.shade600),
              ),
            )
          else
            ...students.take(8).map((student) => _RankingRow(student: student)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.student});

  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final progress = (student['progress'] as num?)?.toDouble() ?? 0;
    final points = (student['points'] as num?)?.toInt() ?? 0;
    final trend = (student['trend'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 220,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFDBEAFE),
                      child: Text(
                        (student['name'] as String? ?? 'E')[0].toUpperCase(),
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['name'] as String? ?? 'Estudiante',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kNavy,
                            ),
                          ),
                          Text(
                            student['className'] as String? ?? 'Clase',
                            style: GoogleFonts.nunito(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      points.toString(),
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        color: _kNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE8E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            trend >= 0 ? const Color(0xFF16A34A) : _kCoral,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 90,
                child: Text(
                  trend >= 0 ? '+${trend.round()}' : trend.round().toString(),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: trend >= 0 ? const Color(0xFF16A34A) : _kCoral,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
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
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
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
          offset: const Offset(0, 3),
        ),
      ],
    );

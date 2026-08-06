import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

class InformesPanel extends StatelessWidget {
  const InformesPanel({super.key, required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;
    final topStudents = bloc.topStudents;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderRow(
              totalStudents: bloc.totalStudents,
              totalClasses: bloc.classes.length),
          const SizedBox(height: 24),
          wide
              ? IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(child: _SummaryCard(bloc: bloc)),
                      const SizedBox(width: 16),
                      Expanded(child: _BuilderCard(bloc: bloc)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _SummaryCard(bloc: bloc),
                    const SizedBox(height: 16),
                    _BuilderCard(bloc: bloc),
                  ],
                ),
          const SizedBox(height: 20),
          wide
              ? IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                          child: _StudentProgressCard(students: topStudents)),
                      const SizedBox(width: 16),
                      Expanded(child: _ClassVisionCard(bloc: bloc)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    _StudentProgressCard(students: topStudents),
                    const SizedBox(height: 16),
                    _ClassVisionCard(bloc: bloc),
                  ],
                ),
          const SizedBox(height: 24),
          _RecentDataCard(bloc: bloc),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.totalStudents,
    required this.totalClasses,
  });

  final int totalStudents;
  final int totalClasses;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Centro de Informes',
              style: GoogleFonts.fredoka(
                fontSize: 22,
                color: _kNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vista en vivo de $totalStudents alumnos en $totalClasses clases.',
              style:
                  GoogleFonts.nunito(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Exportación disponible próximamente.'),
              duration: Duration(seconds: 2),
            ),
          ),
          icon: const Icon(Icons.upload_rounded, size: 14, color: _kNavy),
          label: Text(
            'Exportar Todo',
            style: GoogleFonts.nunito(
              color: _kNavy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _kNavy, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVO',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF16A34A),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Resumen Semanal',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              color: _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Los datos del panel se actualizan con la actividad real de tus alumnos y retos de clase.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _MiniMetric(
              label: 'Alumnos con actividad reciente',
              value: '${bloc.completionRate}%'),
          _MiniMetric(
              label: 'Tiempo promedio de práctica',
              value: '${bloc.averageMinutes} min'),
          _MiniMetric(
              label: 'Retos activos', value: '${bloc.activeChallenges.length}'),
        ],
      ),
    );
  }
}

class _BuilderCard extends StatelessWidget {
  const _BuilderCard({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _kNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Report Builder',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ya tienes la base de datos conectada: alumnos, progreso, retos y clases se pueden combinar en un solo reporte.',
            style: GoogleFonts.nunito(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Clases', 'Retos', 'Progreso', 'Top alumnos']
                .map(
                  (label) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Informes personalizados disponibles próximamente.'),
                duration: Duration(seconds: 2),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kCoral,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Diseñar Informe Personalizado',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentProgressCard extends StatelessWidget {
  const _StudentProgressCard({required this.students});

  final List<Map<String, dynamic>> students;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(top: BorderSide(color: Color(0xFFE11D48), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso Individual',
            style: GoogleFonts.fredoka(
              fontSize: 15,
              color: _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estudiantes con mejor evolución reciente.',
            style:
                GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          if (students.isEmpty)
            Text(
              'No hay datos suficientes todavía.',
              style: GoogleFonts.nunito(color: Colors.grey.shade500),
            )
          else
            ...students.take(3).map((student) => _StudentRow(student: student)),
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final Map<String, dynamic> student;

  @override
  Widget build(BuildContext context) {
    final trend = (student['trend'] as num?)?.toDouble() ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
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
            child: Text(
              student['name'] as String? ?? 'Estudiante',
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _kNavy,
              ),
            ),
          ),
          Text(
            trend >= 0 ? '+${trend.round()}' : trend.round().toString(),
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: trend >= 0 ? const Color(0xFF16A34A) : _kCoral,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassVisionCard extends StatelessWidget {
  const _ClassVisionCard({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            const Border(top: BorderSide(color: Color(0xFF3B82F6), width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visión General de Clase',
            style: GoogleFonts.fredoka(
              fontSize: 15,
              color: _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Métricas agrupadas por actividad real.',
            style:
                GoogleFonts.nunito(fontSize: 11, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          _MetricBar(
            label: 'Participación reciente',
            fraction: (bloc.completionRate / 100).clamp(0.0, 1.0),
            color: const Color(0xFFD97706),
          ),
          const SizedBox(height: 10),
          _MetricBar(
            label: 'Progreso promedio',
            fraction: bloc.averageProgress,
            color: _kNavy,
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
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _kNavy,
                ),
              ),
            ),
            Text(
              '${(fraction * 100).round()}%',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
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

class _RecentDataCard extends StatelessWidget {
  const _RecentDataCard({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
            child: Row(
              children: [
                Text(
                  'Datos Recientes',
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    color: _kNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (bloc.challenges.isEmpty && bloc.students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Aún no hay clases, alumnos o retos vinculados para mostrar.',
                style: GoogleFonts.nunito(color: Colors.grey.shade600),
              ),
            )
          else ...[
            ...bloc.classes.take(3).map((tc) => _RowItem(
                  icon: Icons.groups_rounded,
                  iconColor: const Color(0xFF3B82F6),
                  title: tc.name,
                  subtitle: '${tc.studentCount} alumnos · ${tc.subject}',
                  actionLabel: tc.gradeLevel,
                )),
            ...bloc.challenges.take(3).map((challenge) => _RowItem(
                  icon: Icons.emoji_events_rounded,
                  iconColor: _kCoral,
                  title: challenge['title'] as String? ?? 'Reto',
                  subtitle: challenge['class_name'] as String? ?? 'Clase',
                  actionLabel: 'Activo',
                )),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                actionLabel,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style:
                  GoogleFonts.nunito(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              color: _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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

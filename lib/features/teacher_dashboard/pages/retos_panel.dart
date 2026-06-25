import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/shared/data/subject_catalog.dart';
import 'package:edu_play/utils/responsive.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);

class RetosPanel extends StatelessWidget {
  const RetosPanel({super.key, required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;
    final active =
        bloc.challenges.where((c) => c['status'] == 'active').toList();
    final completed =
        bloc.challenges.where((c) => c['status'] == 'completed').toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: wide ? 32 : 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(
            onCreate: () => _showCreateDialog(context),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _CountChip(label: 'Activos', count: active.length, active: true),
              const SizedBox(width: 10),
              _CountChip(label: 'Completados', count: completed.length),
              const SizedBox(width: 10),
              _CountChip(label: 'Clases', count: bloc.classes.length),
            ],
          ),
          const SizedBox(height: 20),
          if (bloc.classes.isEmpty)
            _EmptyRetos(
              message:
                  'Crea una clase primero para poder asignar actividades reales a tus alumnos.',
              onCreate: null,
            )
          else if (bloc.challenges.isEmpty)
            _EmptyRetos(
              message:
                  'Todavía no has asignado retos. El siguiente reto que crees aparecerá también en el panel del alumno.',
              onCreate: () => _showCreateDialog(context),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: wide ? 360 : 540,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: wide ? 0.95 : 1.4,
              ),
              itemCount: bloc.challenges.length + 1,
              itemBuilder: (context, index) {
                if (index == bloc.challenges.length) {
                  return _CreateCard(onTap: () => _showCreateDialog(context));
                }
                return _ChallengeCard(data: bloc.challenges[index]);
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    if (bloc.classes.isEmpty) return;

    final titleCtrl = TextEditingController();
    String classId = bloc.classes.first.id;
    String subjectKey = subjectCatalog.first.key;
    String? dueDate;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Nuevo reto',
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  color: _kNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Título del reto'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: classId,
                    decoration: const InputDecoration(labelText: 'Clase'),
                    items: bloc.classes
                        .map(
                          (tc) => DropdownMenuItem(
                            value: tc.id,
                            child: Text('${tc.name} · ${tc.gradeLevel}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => classId = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: subjectKey,
                    decoration: const InputDecoration(labelText: 'Materia'),
                    items: subjectCatalog
                        .map(
                          (subject) => DropdownMenuItem(
                            value: subject.key,
                            child: Text(subject.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => subjectKey = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => dueDate = picked.toIso8601String());
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: Text(
                      dueDate == null
                          ? 'Agregar fecha límite'
                          : 'Fecha asignada',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    await bloc.addChallenge(
                      classId: classId,
                      title: title,
                      subjectKey: subjectKey,
                      dueDate: dueDate,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCoral,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DASHBOARD EDUCATIVO',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  color: _kCoral,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Retos Gamificados',
                style: GoogleFonts.fredoka(
                  fontSize: 30,
                  color: _kNavy,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Asigna actividades reales a tus clases y publícalas en el panel del alumno.',
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
          label: Text(
            'Nuevo Reto',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kCoral,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip({
    required this.label,
    required this.count,
    this.active = false,
  });

  final String label;
  final int count;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: active ? _kNavy : const Color(0xFFE0DEFF),
        ),
      ),
      child: Text(
        '$label ($count)',
        style: GoogleFonts.nunito(
          color: active ? Colors.white : _kNavy,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final subject = subjectByKey((data['subject_key'] as String?) ?? 'math');
    final className = data['class_name'] as String? ?? 'Clase';
    final status = (data['status'] as String?) ?? 'active';
    final dueDate = data['due_date'] as String?;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: status == 'completed' ? _kNavy : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: status == 'completed'
                      ? Colors.white.withValues(alpha: 0.14)
                      : subject.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status == 'completed' ? 'Completado' : 'Activo',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: status == 'completed' ? Colors.white : subject.color,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                subject.icon,
                color: status == 'completed' ? Colors.white70 : subject.color,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            data['title'] as String? ?? 'Reto',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              color: status == 'completed' ? Colors.white : _kNavy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${subject.label} • $className',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color:
                  status == 'completed' ? Colors.white60 : Colors.grey.shade500,
            ),
          ),
          const Spacer(),
          if (dueDate != null)
            Text(
              'Fecha límite asignada',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: status == 'completed'
                    ? Colors.white70
                    : Colors.grey.shade600,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            status == 'completed'
                ? 'Este reto ya forma parte del historial de la clase.'
                : 'Visible en el panel del alumno para esta clase.',
            style: GoogleFonts.nunito(
              fontSize: 13,
              height: 1.4,
              color:
                  status == 'completed' ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0DEFF), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Color(0xFFEEEDF8),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded, color: _kNavy, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              'Crear nuevo reto',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _kNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRetos extends StatelessWidget {
  const _EmptyRetos({
    required this.message,
    required this.onCreate,
  });

  final String message;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_outlined, size: 54, color: _kNavy),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                GoogleFonts.nunito(fontSize: 14, color: Colors.grey.shade600),
          ),
          if (onCreate != null) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _kCoral,
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear reto'),
            ),
          ],
        ],
      ),
    );
  }
}

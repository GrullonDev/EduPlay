import 'package:edu_play/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kLavender = Color(0xFFEEEDF8);

class AlumnosPanel extends StatefulWidget {
  const AlumnosPanel({super.key});

  @override
  State<AlumnosPanel> createState() => _AlumnosPanelState();
}

class _AlumnosPanelState extends State<AlumnosPanel> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = ScreenSize.of(context).isDesktop;

    return Padding(
      padding: EdgeInsets.all(wide ? 32 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Text(
                'Alumnos',
                style: GoogleFonts.fredoka(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: _kNavy,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  style: GoogleFonts.nunito(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o clase...',
                    hintStyle: GoogleFonts.nunito(
                        fontSize: 13, color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: _kLavender,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Niños inscritos en tus clases mediante código de invitación.',
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<TeacherClass>>(
              stream: sl<TeacherClassesRepository>().watchMyClasses(),
              builder: (context, classSnap) {
                if (classSnap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: _kNavy, strokeWidth: 2),
                  );
                }

                final classes = classSnap.data ?? const <TeacherClass>[];
                if (classes.isEmpty) {
                  return const _EmptyAlumnos();
                }

                return FutureBuilder<List<ClassMember>>(
                  future: sl<TeacherClassesRepository>()
                      .getMembersForClasses(classes.map((c) => c.id).toList()),
                  builder: (context, memberSnap) {
                    if (memberSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: _kNavy, strokeWidth: 2),
                      );
                    }

                    final members = memberSnap.data ?? const <ClassMember>[];
                    final filtered = _query.isEmpty
                        ? members
                        : members
                            .where((m) =>
                                m.displayName.toLowerCase().contains(_query) ||
                                m.className.toLowerCase().contains(_query))
                            .toList();

                    if (members.isEmpty) return const _EmptyAlumnos();
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'Sin resultados para "$_query".',
                          style: GoogleFonts.nunito(color: Colors.grey[500]),
                        ),
                      );
                    }

                    filtered.sort(
                      (a, b) => a.displayName
                          .toLowerCase()
                          .compareTo(b.displayName.toLowerCase()),
                    );

                    return _AlumnosTable(members: filtered);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AlumnosTable extends StatelessWidget {
  const _AlumnosTable({required this.members});
  final List<ClassMember> members;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(_kLavender),
            columnSpacing: 28,
            columns: [
              _column('Nombre'),
              _column('Edad'),
              _column('Clase'),
              _column('Materia'),
              _column('Ingresó'),
            ],
            rows: members
                .map(
                  (m) => DataRow(
                    cells: [
                      DataCell(Text(
                        m.displayName.isEmpty ? '—' : m.displayName,
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, color: _kNavy),
                      )),
                      DataCell(Text(
                        m.age != null ? '${m.age} años' : '—',
                        style: GoogleFonts.nunito(color: Colors.grey[700]),
                      )),
                      DataCell(Text(
                        m.className.isEmpty ? '—' : m.className,
                        style: GoogleFonts.nunito(color: Colors.grey[700]),
                      )),
                      DataCell(Text(
                        m.focusSubject.isEmpty
                            ? m.classSubject
                            : m.focusSubject,
                        style: GoogleFonts.nunito(color: Colors.grey[700]),
                      )),
                      DataCell(Text(
                        _formatDate(m.joinedAt),
                        style: GoogleFonts.nunito(
                            fontSize: 12, color: Colors.grey[500]),
                      )),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _column(String label) => DataColumn(
        label: Text(
          label,
          style: GoogleFonts.nunito(
              fontSize: 12, fontWeight: FontWeight.w800, color: _kNavy),
        ),
      );

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _EmptyAlumnos extends StatelessWidget {
  const _EmptyAlumnos();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🧑‍🎓', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes alumnos',
            style: GoogleFonts.fredoka(
                fontSize: 20, fontWeight: FontWeight.w700, color: _kNavy),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una clase en "Mis Clases" y comparte el código\npara que tus alumnos se unan.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

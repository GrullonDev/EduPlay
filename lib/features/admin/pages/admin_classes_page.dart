// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:google_fonts/google_fonts.dart';

// Project imports:
import 'package:edu_play/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/utils/injection_container.dart';

const _kNavy = Color(0xFF1E1B6A);
const _kCoral = Color(0xFFFF6E6C);
const _kBg = Color(0xFFF8F7FF);
const _kLav = Color(0xFFEEEDF8);

class AdminClassesPage extends StatefulWidget {
  const AdminClassesPage({super.key});

  @override
  State<AdminClassesPage> createState() => _AdminClassesPageState();
}

class _AdminClassesPageState extends State<AdminClassesPage> {
  late Future<List<TeacherClass>> _classesFuture;

  @override
  void initState() {
    super.initState();
    _classesFuture = sl<AdminDashboardRepository>().listAllClasses();
  }

  void _refresh() {
    setState(() {
      _classesFuture = sl<AdminDashboardRepository>().listAllClasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: Colors.white,
        title: Text(
          'Todas las clases',
          style: GoogleFonts.fredoka(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<TeacherClass>>(
        future: _classesFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: _kNavy, strokeWidth: 2));
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'No se pudieron cargar las clases.',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            );
          }

          final classes = snap.data ?? const <TeacherClass>[];
          if (classes.isEmpty) {
            return Center(
              child: Text(
                'Aún no hay clases registradas en la plataforma.',
                style: GoogleFonts.nunito(color: Colors.grey[600]),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _ClassTile(teacherClass: classes[i]),
          );
        },
      ),
    );
  }
}

class _ClassTile extends StatelessWidget {
  const _ClassTile({required this.teacherClass});
  final TeacherClass teacherClass;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _kLav,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.groups_rounded, color: _kNavy, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teacherClass.name.isNotEmpty
                      ? teacherClass.name
                      : 'Clase sin nombre',
                  style: GoogleFonts.nunito(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _kNavy),
                ),
                const SizedBox(height: 2),
                Text(
                  '${teacherClass.teacherName.isNotEmpty ? teacherClass.teacherName : 'Profesor desconocido'} · '
                  '${teacherClass.subject.isNotEmpty ? teacherClass.subject : 'Sin materia'} · '
                  '${teacherClass.gradeLevel.isNotEmpty ? teacherClass.gradeLevel : 'Sin grado'}',
                  style:
                      GoogleFonts.nunito(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${teacherClass.studentCount} '
              '${teacherClass.studentCount == 1 ? 'alumno' : 'alumnos'}',
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: _kCoral,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

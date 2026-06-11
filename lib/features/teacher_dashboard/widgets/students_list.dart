import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/app_theme.dart';

/// "Mis Clases": full roster of students with their level, points and
/// streak, ordered by points (as returned by [StudentRepository.getAllStudents]).
class StudentsList extends StatelessWidget {
  const StudentsList({super.key, required this.students});

  final List<Map<String, dynamic>> students;

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Aún no hay estudiantes registrados.',
            style: GoogleFonts.nunito(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = students[index];
        final name = student['name'] as String? ?? 'Estudiante';
        final age = (student['age'] as num?)?.toInt();
        final points = (student['points'] as num?)?.toInt() ?? 0;
        final streak = (student['streak'] as num?)?.toInt() ?? 0;
        final level = StudentRepository.levelForPoints(points);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                child: const Icon(Icons.face_rounded,
                    color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: AppTheme.textColor,
                      ),
                    ),
                    if (age != null)
                      Text(
                        '$age años · Nivel $level',
                        style: GoogleFonts.nunito(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              _Pill(
                icon: Icons.local_fire_department_rounded,
                label: '$streak',
                color: const Color(0xFFFF7043),
              ),
              const SizedBox(width: 8),
              _Pill(
                icon: Icons.star_rounded,
                label: '$points pts',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

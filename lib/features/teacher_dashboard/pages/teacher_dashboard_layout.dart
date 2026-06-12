import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/features/teacher_dashboard/widgets/assigned_challenges_card.dart';
import 'package:edu_play/features/teacher_dashboard/widgets/students_list.dart';
import 'package:edu_play/features/teacher_dashboard/widgets/subject_performance_card.dart';
import 'package:edu_play/features/teacher_dashboard/widgets/teacher_stat_cards.dart';
import 'package:edu_play/features/teacher_dashboard/widgets/weekly_progress_card.dart';
import 'package:edu_play/shared/widgets/dashboard_shell.dart';
import 'package:edu_play/shared/widgets/placeholder_section.dart';
import 'package:edu_play/utils/app_theme.dart';

const _navItems = [
  DashboardNavItem(icon: Icons.dashboard_rounded, label: 'Panel de Control'),
  DashboardNavItem(icon: Icons.groups_rounded, label: 'Mis Clases'),
  DashboardNavItem(icon: Icons.bar_chart_rounded, label: 'Informes'),
  DashboardNavItem(icon: Icons.menu_book_rounded, label: 'Currículo'),
  DashboardNavItem(icon: Icons.settings_rounded, label: 'Configuración'),
];

class TeacherDashboardLayout extends StatefulWidget {
  const TeacherDashboardLayout({super.key});

  @override
  State<TeacherDashboardLayout> createState() =>
      _TeacherDashboardLayoutState();
}

class _TeacherDashboardLayoutState extends State<TeacherDashboardLayout> {
  int _selectedIndex = 0;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<TeacherDashboardBloc>();

    Widget body;
    if (bloc.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      switch (_selectedIndex) {
        case 1:
          body = StudentsList(students: bloc.students);
          break;
        case 2:
          body = const PlaceholderSection(
            icon: Icons.bar_chart_rounded,
            title: 'Informes',
            message: 'Pronto podrás generar informes detallados de progreso.',
          );
          break;
        case 3:
          body = const PlaceholderSection(
            icon: Icons.menu_book_rounded,
            title: 'Currículo',
            message: 'Pronto podrás organizar el currículo por unidades.',
          );
          break;
        case 4:
          body = const PlaceholderSection(
            icon: Icons.settings_rounded,
            title: 'Configuración',
            message: 'Pronto podrás ajustar las preferencias de tu cuenta.',
          );
          break;
        default:
          body = _OverviewView(bloc: bloc);
      }
    }

    return DashboardShell(
      title: 'EduPlay',
      headerSubtitle: 'Sra. Johnson',
      accentColor: const Color(0xFF24235B),
      items: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: _selectTab,
      body: body,
      footer: _TeacherFooter(),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView({required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 900;

    return RefreshIndicator(
      onRefresh: bloc.refresh,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PANEL DEL PROFESOR',
                    style: GoogleFonts.nunito(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Analíticas de Clase',
                    style: GoogleFonts.fredoka(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF24235B),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(
                  'Exportar Informe',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF24235B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TeacherStatCardsRow(
            totalStudents: bloc.totalStudents,
            newStudentsThisWeek: bloc.newStudentsThisWeek,
            activeChallenges: bloc.activeChallenges.length,
            completedChallenges: bloc.completedChallenges.length,
            averageProgress: bloc.averageProgress,
          ),
          const SizedBox(height: 20),
          WeeklyProgressCard(weeklyTotals: bloc.weeklyTotals),
          const SizedBox(height: 20),
          AssignedChallengesCard(
            challenges: bloc.challenges,
            onAddChallenge: ({
              required title,
              required subjectKey,
              dueDate,
            }) =>
                bloc.addChallenge(
              title: title,
              subjectKey: subjectKey,
              dueDate: dueDate,
            ),
          ),
          const SizedBox(height: 20),
          SubjectPerformanceCard(performance: bloc.subjectPerformance),
          if (!desktop) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _TeacherFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF24235B),
            child: Text(
              'J',
              style: GoogleFonts.fredoka(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sra. Johnson',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF24235B),
                  ),
                ),
                Text(
                  'Mentora Senior',
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

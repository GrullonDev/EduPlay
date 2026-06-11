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
      accentColor: Colors.deepPurple,
      items: _navItems,
      selectedIndex: _selectedIndex,
      onSelect: _selectTab,
      body: body,
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
          Text(
            'Panel del Profesor',
            style: GoogleFonts.fredoka(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Resumen del progreso de tu clase',
            style: GoogleFonts.nunito(color: Colors.grey[600], fontSize: 15),
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

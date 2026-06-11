import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/features/teacher_dashboard/pages/teacher_dashboard_layout.dart';

/// Entry point for the "Panel del Profesor".
class TeacherDashboardPage extends StatelessWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeacherDashboardBloc>(
      create: (_) => TeacherDashboardBloc(),
      child: const TeacherDashboardLayout(),
    );
  }
}

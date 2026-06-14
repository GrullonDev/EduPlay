import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_layout.dart';

/// Entry point for the student "Panel de Control". Replaces the old
/// `MenuPage`: provides the gamification profile/challenges/leaderboard
/// (via [StudentDashboardBloc]) plus the existing games catalog (via
/// [MenuProvider]) to the dashboard layout.
class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({
    super.key,
    required this.username,
    this.childProfile,
  });

  final String? username;

  /// Optional ChildProfile passed from the PIN login flow.
  final Object? childProfile;

  @override
  Widget build(BuildContext context) {
    final registerProvider = context.read<RegisterProvider>();
    final age = int.tryParse(registerProvider.age) ?? 6;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StudentDashboardBloc>(
          create: (_) => StudentDashboardBloc(username: username, age: age),
        ),
        ChangeNotifierProvider<MenuProvider>(
          create: (context) => MenuProvider(
            context: context,
            age: age,
            username: username,
          ),
        ),
      ],
      child: const StudentDashboardLayout(),
    );
  }
}

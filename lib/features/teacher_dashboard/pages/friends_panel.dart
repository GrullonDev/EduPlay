// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/features/friends/pages/friends_view.dart';
import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';

/// "Amigos" tab of the teacher dashboard — lets a teacher connect with other
/// teachers to share resources and coordinate across classes.
class FriendsPanel extends StatelessWidget {
  const FriendsPanel({super.key, required this.bloc});

  final TeacherDashboardBloc bloc;

  @override
  Widget build(BuildContext context) {
    return FriendsView(
      identity: teacherIdentity(bloc.teacherName),
      subtitle: 'Conecta con otros profesores de EduPlay.',
    );
  }
}

import 'package:flutter/material.dart';

import 'package:edu_play/features/parents_dashboard/services/child_profiles_service.dart';
import 'package:edu_play/features/student_dashboard/pages/student_dashboard_page.dart';

/// Resolves the single gameplay profile owned by a self-registered
/// independent student (uid acts as both account owner and child) and hands
/// off to [StudentDashboardPage].
///
/// Used by [AuthGate] and [EmailVerificationGatePage] once the
/// `independent_student` role has been resolved for the signed-in user.
class IndependentStudentLoader extends StatelessWidget {
  const IndependentStudentLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ChildProfilesService.getProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F7FF),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E1B6A),
                strokeWidth: 3,
              ),
            ),
          );
        }

        final profiles = snapshot.data;
        // Shouldn't happen in practice — registration always creates exactly
        // one profile — but fail safe into guest mode rather than a blank
        // screen if it's ever missing.
        if (profiles == null || profiles.isEmpty) {
          return const StudentDashboardPage(username: null);
        }
        return StudentDashboardPage(childProfile: profiles.first);
      },
    );
  }
}

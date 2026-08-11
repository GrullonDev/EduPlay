import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';

abstract class ParentDashboardRepository {
  Future<ParentQuickControls> getQuickControls();

  Future<void> saveQuickControls(ParentQuickControls controls);
}

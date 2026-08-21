// Project imports:
import 'package:edu_play/features/parents_dashboard/data/datasources/parent_dashboard_datasource.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';

class FirestoreParentDashboardRepository implements ParentDashboardRepository {
  FirestoreParentDashboardRepository({
    required ParentDashboardDatasource datasource,
  }) : _datasource = datasource;

  final ParentDashboardDatasource _datasource;

  @override
  Future<ParentQuickControls> getQuickControls() {
    return _datasource.getQuickControls();
  }

  @override
  Future<ParentQuickControls> getQuickControlsForUser(String uid) {
    return _datasource.getQuickControlsForUser(uid);
  }

  @override
  Future<void> saveQuickControls(ParentQuickControls controls) {
    return _datasource.saveQuickControls(controls);
  }
}

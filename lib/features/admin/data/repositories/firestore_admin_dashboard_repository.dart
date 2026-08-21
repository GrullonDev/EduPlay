// Project imports:
import 'package:edu_play/features/admin/data/datasources/admin_dashboard_datasource.dart';
import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';
import 'package:edu_play/features/admin/domain/repositories/admin_dashboard_repository.dart';

class FirestoreAdminDashboardRepository implements AdminDashboardRepository {
  const FirestoreAdminDashboardRepository({required this.datasource});

  final AdminDashboardDatasource datasource;

  @override
  Future<PlatformStats?> loadStats() => datasource.loadStats();

  @override
  Future<bool> setAdminRoleByEmail({
    required String email,
    required bool granting,
  }) {
    return datasource.setAdminRoleByEmail(email: email, granting: granting);
  }
}

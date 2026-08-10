import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';

abstract class AdminDashboardRepository {
  Future<PlatformStats?> loadStats();
  Future<bool> setAdminRoleByEmail({
    required String email,
    required bool granting,
  });
}

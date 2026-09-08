// Project imports:
import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';

abstract class AdminDashboardRepository {
  Future<PlatformStats?> loadStats();
  Future<List<TeacherClass>> listAllClasses();
}

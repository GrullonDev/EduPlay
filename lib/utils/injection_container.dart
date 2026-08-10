import 'package:get_it/get_it.dart';
import 'package:edu_play/data/datasources/auth_datasource.dart';
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/data/datasources/child_profiles_datasource.dart';
import 'package:edu_play/features/parents_dashboard/data/repositories/firestore_child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/data/datasources/parent_dashboard_datasource.dart';
import 'package:edu_play/features/parents_dashboard/data/repositories/firestore_parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/practice_session/data/datasources/practice_sessions_datasource.dart';
import 'package:edu_play/features/practice_session/data/repositories/firestore_practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';

class InjectionContainer {}

final sl = GetIt.instance;

void init() {
  // Datasources
  sl.registerLazySingleton<AuthDatasource>(() => ImplAuthDatasource());
  sl.registerLazySingleton<StudentDatasource>(() => StudentDatasource());
  sl.registerLazySingleton<ChildProfilesDatasource>(
    () => FirestoreChildProfilesDatasource(),
  );
  sl.registerLazySingleton<ParentDashboardDatasource>(
    () => FirestoreParentDashboardDatasource(),
  );
  sl.registerLazySingleton<PracticeSessionsDatasource>(
    () => FirestorePracticeSessionsDatasource(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => ImplAuthRepository(authDatasource: sl()),
  );
  sl.registerLazySingleton<StudentRepository>(
    () => StudentRepository(datasource: sl()),
  );
  sl.registerLazySingleton<ChildProfilesRepository>(
    () => FirestoreChildProfilesRepository(datasource: sl()),
  );
  sl.registerLazySingleton<ParentDashboardRepository>(
    () => FirestoreParentDashboardRepository(datasource: sl()),
  );
  sl.registerLazySingleton<PracticeSessionsRepository>(
    () => FirestorePracticeSessionsRepository(datasource: sl()),
  );
}

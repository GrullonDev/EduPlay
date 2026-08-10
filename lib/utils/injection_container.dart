import 'package:get_it/get_it.dart';
import 'package:edu_play/data/datasources/auth_datasource.dart';
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/data/datasources/child_profiles_datasource.dart';
import 'package:edu_play/features/parents_dashboard/data/datasources/parent_dashboard_datasource.dart';
import 'package:edu_play/features/parents_dashboard/data/repositories/firestore_child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/data/repositories/firestore_parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/practice_session/data/datasources/practice_sessions_datasource.dart';
import 'package:edu_play/features/practice_session/data/repositories/firestore_practice_sessions_repository.dart';
import 'package:edu_play/features/practice_session/domain/repositories/practice_sessions_repository.dart';
import 'package:edu_play/features/settings/data/datasources/account_security_datasource.dart';
import 'package:edu_play/features/settings/data/datasources/settings_datasource.dart';
import 'package:edu_play/features/settings/data/repositories/firebase_account_security_repository.dart';
import 'package:edu_play/features/settings/data/repositories/firestore_settings_repository.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';
import 'package:edu_play/features/settings/domain/repositories/settings_repository.dart';
import 'package:edu_play/features/teacher_dashboard/data/datasources/classroom_challenges_datasource.dart';
import 'package:edu_play/features/teacher_dashboard/data/repositories/firestore_classroom_challenges_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/sticker_album/data/datasources/level_progress_datasource.dart';
import 'package:edu_play/features/sticker_album/data/repositories/local_level_progress_repository.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';
import 'package:edu_play/features/subscription/data/datasources/subscription_datasource.dart';
import 'package:edu_play/features/subscription/data/repositories/firestore_subscription_repository.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';

class InjectionContainer {}

final sl = GetIt.instance;

void init() {
  // Datasources
  if (!sl.isRegistered<AuthDatasource>()) {
    sl.registerLazySingleton<AuthDatasource>(() => ImplAuthDatasource());
  }
  if (!sl.isRegistered<StudentDatasource>()) {
    sl.registerLazySingleton<StudentDatasource>(() => StudentDatasource());
  }
  if (!sl.isRegistered<ChildProfilesDatasource>()) {
    sl.registerLazySingleton<ChildProfilesDatasource>(
      () => FirestoreChildProfilesDatasource(),
    );
  }
  if (!sl.isRegistered<ParentDashboardDatasource>()) {
    sl.registerLazySingleton<ParentDashboardDatasource>(
      () => FirestoreParentDashboardDatasource(),
    );
  }
  if (!sl.isRegistered<PracticeSessionsDatasource>()) {
    sl.registerLazySingleton<PracticeSessionsDatasource>(
      () => FirestorePracticeSessionsDatasource(),
    );
  }
  if (!sl.isRegistered<LevelProgressDatasource>()) {
    sl.registerLazySingleton<LevelProgressDatasource>(
      () => LevelProgressLocalDatasource(),
    );
  }
  if (!sl.isRegistered<SettingsDatasource>()) {
    sl.registerLazySingleton<SettingsDatasource>(
      () => FirestoreSettingsDatasource(),
    );
  }
  if (!sl.isRegistered<AccountSecurityDatasource>()) {
    sl.registerLazySingleton<AccountSecurityDatasource>(
      () => FirebaseAccountSecurityDatasource(),
    );
  }
  if (!sl.isRegistered<SubscriptionDatasource>()) {
    sl.registerLazySingleton<SubscriptionDatasource>(
      () => FirestoreSubscriptionDatasource(),
    );
  }
  if (!sl.isRegistered<ClassroomChallengesDatasource>()) {
    sl.registerLazySingleton<ClassroomChallengesDatasource>(
      () => FirestoreClassroomChallengesDatasource(),
    );
  }

  // Repositories
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => ImplAuthRepository(authDatasource: sl()),
    );
  }
  if (!sl.isRegistered<StudentRepository>()) {
    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ChildProfilesRepository>()) {
    sl.registerLazySingleton<ChildProfilesRepository>(
      () => FirestoreChildProfilesRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ParentDashboardRepository>()) {
    sl.registerLazySingleton<ParentDashboardRepository>(
      () => FirestoreParentDashboardRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<PracticeSessionsRepository>()) {
    sl.registerLazySingleton<PracticeSessionsRepository>(
      () => FirestorePracticeSessionsRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<LevelProgressRepository>()) {
    sl.registerLazySingleton<LevelProgressRepository>(
      () => LocalLevelProgressRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<SettingsRepository>()) {
    sl.registerLazySingleton<SettingsRepository>(
      () => FirestoreSettingsRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<AccountSecurityRepository>()) {
    sl.registerLazySingleton<AccountSecurityRepository>(
      () => FirebaseAccountSecurityRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<SubscriptionRepository>()) {
    sl.registerLazySingleton<SubscriptionRepository>(
      () => FirestoreSubscriptionRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ClassroomChallengesRepository>()) {
    sl.registerLazySingleton<ClassroomChallengesRepository>(
      () => FirestoreClassroomChallengesRepository(datasource: sl()),
    );
  }
}

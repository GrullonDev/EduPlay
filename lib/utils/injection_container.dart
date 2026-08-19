import 'package:get_it/get_it.dart';
import 'package:edu_play/features/teacher_registration/domain/repositories/teacher_registration_repository.dart';
import 'package:edu_play/features/teacher_registration/data/repositories/firebase_teacher_registration_repository.dart';
import 'package:edu_play/features/teacher_registration/data/datasources/teacher_registration_datasource.dart';
import 'package:edu_play/features/subscription/domain/repositories/checkout_repository.dart';
import 'package:edu_play/features/subscription/data/repositories/firebase_checkout_repository.dart';
import 'package:edu_play/features/subscription/data/datasources/checkout_datasource.dart';
import 'package:edu_play/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:edu_play/features/onboarding/data/repositories/firestore_onboarding_repository.dart';
import 'package:edu_play/features/onboarding/data/datasources/onboarding_datasource.dart';
import 'package:edu_play/features/admin/domain/repositories/admin_dashboard_repository.dart';
import 'package:edu_play/features/admin/data/repositories/firestore_admin_dashboard_repository.dart';
import 'package:edu_play/features/admin/data/datasources/admin_dashboard_datasource.dart';
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
import 'package:edu_play/features/teacher_dashboard/data/datasources/teacher_classes_datasource.dart';
import 'package:edu_play/features/teacher_dashboard/data/repositories/firestore_teacher_classes_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';
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
  if (!sl.isRegistered<AdminDashboardDatasource>()) {
    sl.registerLazySingleton<AdminDashboardDatasource>(
      () => FirestoreAdminDashboardDatasource(),
    );
  }
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
  if (!sl.isRegistered<OnboardingDatasource>()) {
    sl.registerLazySingleton<OnboardingDatasource>(
      () => FirestoreOnboardingDatasource(),
    );
  }
  if (!sl.isRegistered<CheckoutDatasource>()) {
    sl.registerLazySingleton<CheckoutDatasource>(
      () => FirebaseCheckoutDatasource(),
    );
  }
  if (!sl.isRegistered<TeacherRegistrationDatasource>()) {
    sl.registerLazySingleton<TeacherRegistrationDatasource>(
      () => FirebaseTeacherRegistrationDatasource(),
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
  if (!sl.isRegistered<TeacherClassesDatasource>()) {
    sl.registerLazySingleton<TeacherClassesDatasource>(
      () => FirestoreTeacherClassesDatasource(),
    );
  }

  // Repositories
  if (!sl.isRegistered<AdminDashboardRepository>()) {
    sl.registerLazySingleton<AdminDashboardRepository>(
      () => FirestoreAdminDashboardRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<AuthRepository>()) {
    sl.registerLazySingleton<AuthRepository>(
      () => ImplAuthRepository(authDatasource: sl()),
    );
  }
  if (!sl.isRegistered<StudentRepository>()) {
    // Lazily resolved: by the time this factory actually runs (first
    // `sl<StudentRepository>()` call at runtime), every registration below
    // — including ClassroomChallengesRepository — has already happened, so
    // registration order here doesn't matter.
    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepository(
        datasource: sl(),
        challengesRepository: sl(),
      ),
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
  if (!sl.isRegistered<OnboardingRepository>()) {
    sl.registerLazySingleton<OnboardingRepository>(
      () => FirestoreOnboardingRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<CheckoutRepository>()) {
    sl.registerLazySingleton<CheckoutRepository>(
      () => FirebaseCheckoutRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<TeacherRegistrationRepository>()) {
    sl.registerLazySingleton<TeacherRegistrationRepository>(
      () => FirebaseTeacherRegistrationRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<SubscriptionRepository>()) {
    sl.registerLazySingleton<SubscriptionRepository>(
      () => FirestoreSubscriptionRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<TeacherClassesRepository>()) {
    sl.registerLazySingleton<TeacherClassesRepository>(
      () => FirestoreTeacherClassesRepository(datasource: sl()),
    );
  }
  if (!sl.isRegistered<ClassroomChallengesRepository>()) {
    sl.registerLazySingleton<ClassroomChallengesRepository>(
      () => FirestoreClassroomChallengesRepository(
        datasource: sl(),
        teacherClassesRepository: sl(),
      ),
    );
  }
}

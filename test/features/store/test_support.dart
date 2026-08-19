// Shared test doubles for the store test suite. StudentDashboardBloc's
// constructor eagerly resolves five sl<...>() repositories regardless of
// guest/registered mode, so any test that constructs it — even a
// guest-mode one — needs all of them registered in GetIt first.
//
// StudentRepository is deliberately real (backed by fake_cloud_firestore)
// rather than faked: it's the one piece under test (purchase/points logic),
// so exercising the real transaction code is the point. The rest
// (subscription, parent controls, level progress, classroom challenges,
// store catalog) are peripheral to what these tests check, so hand-rolled
// fakes keep setup simple.

// Package imports:
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Project imports:
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/parent_dashboard_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';
import 'package:edu_play/features/store/domain/repositories/store_catalog_repository.dart';
import 'package:edu_play/features/store/models/store_item.dart';
import 'package:edu_play/features/store/services/store_catalog_cache.dart';
import 'package:edu_play/features/student_dashboard/bloc/student_dashboard_bloc.dart';
import 'package:edu_play/features/subscription/domain/repositories/subscription_repository.dart';
import 'package:edu_play/features/subscription/models/subscription.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> registerParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required List<String> children,
  }) async =>
      null;

  @override
  Future<User?> loginParent(
          {required String email, required String password}) async =>
      null;

  @override
  Future<User?> registerIndependentStudent({
    required String email,
    required String password,
    required String name,
    required int age,
    String? guardianEmail,
  }) async =>
      null;

  @override
  Future<bool> isChildRegistered(String name) async => false;

  @override
  Future<void> registerChild(String name, String age) async {}

  @override
  Future<void> logout() async {}

  @override
  User? getCurrentUser() => null;

  @override
  String? getCurrentUserUid() => 'test-user';

  @override
  String? getCurrentUserEmail() => null;

  @override
  String? getCurrentUserDisplayName() => null;

  @override
  bool isCurrentUserAnonymous() => true;

  @override
  bool isCurrentUserEmailVerified() => true;

  @override
  Future<void> reloadCurrentUser() async {}

  @override
  Future<void> sendCurrentUserEmailVerification() async {}

  @override
  Future<bool> ensureAnonymousAuth(
          {Duration timeout = const Duration(seconds: 8)}) async =>
      true;

  @override
  Future<void> setSessionPersistence({required bool rememberSession}) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}

class FakeLevelProgressRepository implements LevelProgressRepository {
  final Map<String, int> _levels = {};

  @override
  Future<int> getLastCelebratedLevel(String key) async => _levels[key] ?? 0;

  @override
  Future<void> setLastCelebratedLevel(String key, int level) async {
    _levels[key] = level;
  }
}

class FakeClassroomChallengesRepository
    implements ClassroomChallengesRepository {
  @override
  Future<void> createChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
    String status = 'active',
    String? instructions,
    String? evaluationCriteria,
    String? targetGameRoute,
    int? targetScore,
  }) async {}

  @override
  Future<List<ClassroomChallenge>> getChallengesForClasses(
    List<TeacherClass> classes,
  ) async =>
      [];

  @override
  Future<List<ClassroomChallenge>> getChallengesForStudent(
    String studentId,
  ) async =>
      [];

  @override
  Future<void> completeChallenge({
    required String classId,
    required String memberId,
    required String challengeId,
  }) async {}
}

class FakeSubscriptionRepository implements SubscriptionRepository {
  FakeSubscriptionRepository({this.isPro = false});
  bool isPro;

  Subscription get _subscription => Subscription(
        tier: isPro ? 'pro' : 'free',
        sessionsThisMonth: 0,
        monthYear: '2026-01',
      );

  @override
  Future<Subscription> getSubscription() async => _subscription;

  @override
  Future<Subscription> getSubscriptionForUser(String uid) async =>
      _subscription;

  @override
  Stream<Subscription> watchSubscription() => Stream.value(_subscription);

  @override
  Future<void> initSubscription(String uid) async {}

  @override
  Future<void> incrementSessionCount() async {}

  @override
  Future<bool> canAddChild(int currentChildCount) async => true;

  @override
  Future<bool> canCreateSession() async => true;
}

class FakeParentDashboardRepository implements ParentDashboardRepository {
  FakeParentDashboardRepository({ParentQuickControls? controls})
      : _controls = controls ?? const ParentQuickControls();
  ParentQuickControls _controls;

  @override
  Future<ParentQuickControls> getQuickControls() async => _controls;

  @override
  Future<ParentQuickControls> getQuickControlsForUser(String uid) async =>
      _controls;

  @override
  Future<void> saveQuickControls(ParentQuickControls controls) async {
    _controls = controls;
  }
}

class FakeStoreCatalogRepository implements StoreCatalogRepository {
  FakeStoreCatalogRepository([List<StoreItem>? items])
      : _items = items ?? allStoreItems;
  final List<StoreItem> _items;

  @override
  Future<List<StoreItem>> getCatalog() async => _items;

  @override
  Future<void> upsertItem(StoreItem item) async {}

  @override
  Future<void> deleteItem(String itemId) async {}
}

/// Registers everything StudentDashboardBloc/StoreBloc need in GetIt.
/// Call `sl.reset()` in `tearDown` between tests. Returns the fake
/// Firestore instance backing StudentRepository, in case a test needs to
/// pre-seed a student document directly.
FakeFirebaseFirestore registerTestFakes({
  bool isProSubscriber = false,
  ParentQuickControls? parentControls,
  List<StoreItem>? catalogItems,
}) {
  final firestore = FakeFirebaseFirestore();
  sl.registerLazySingleton<AuthRepository>(() => FakeAuthRepository());
  sl.registerLazySingleton<StudentRepository>(
    () =>
        StudentRepository(datasource: StudentDatasource(firestore: firestore)),
  );
  sl.registerLazySingleton<LevelProgressRepository>(
      () => FakeLevelProgressRepository());
  sl.registerLazySingleton<ClassroomChallengesRepository>(
      () => FakeClassroomChallengesRepository());
  sl.registerLazySingleton<SubscriptionRepository>(
      () => FakeSubscriptionRepository(isPro: isProSubscriber));
  sl.registerLazySingleton<ParentDashboardRepository>(
      () => FakeParentDashboardRepository(controls: parentControls));
  sl.registerLazySingleton<StoreCatalogRepository>(
      () => FakeStoreCatalogRepository(catalogItems));
  sl.registerLazySingleton<StoreCatalogCache>(
      () => StoreCatalogCache(repository: sl()));
  return firestore;
}

/// Polls until [bloc]'s initial async `_load()` has finished, instead of
/// guessing a fixed delay — the guest-mode chain is short (SharedPreferences
/// only) but the registered/non-guest chain touches several fake
/// repositories, so this bounds the wait generously either way.
Future<void> settle(StudentDashboardBloc bloc) async {
  for (var i = 0; i < 200 && bloc.isLoading; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

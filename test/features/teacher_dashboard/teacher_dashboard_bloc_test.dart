// TeacherDashboardBloc coverage: the derived roster/aggregate getters
// (totalStudents, averageProgress, completionRate, topStudents,
// supportStudents), the post-dispose notifyListeners() guard added to fix
// "A TeacherDashboardBloc was used after being disposed." (see `_disposed`
// in teacher_dashboard_bloc.dart), and that refresh() actually reloads.
//
// TeacherClassesRepository/ClassroomChallengesRepository are hand-rolled
// local fakes (both are plain interfaces, easy to fake directly).
// StudentRepository is deliberately real, backed by a FakeFirebaseFirestore
// — same pattern as test/features/store/test_support.dart — since it's
// straightforward to seed and exercises the real points/score aggregation
// code the bloc depends on.

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:edu_play/data/datasources/student_datasource.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/teacher_dashboard/bloc/teacher_dashboard_bloc.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/classroom_challenge.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/classroom_challenges_repository.dart';
import 'package:edu_play/features/teacher_dashboard/domain/repositories/teacher_classes_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

class FakeTeacherClassesRepository implements TeacherClassesRepository {
  FakeTeacherClassesRepository({
    List<TeacherClass>? classes,
    List<ClassMember>? members,
    this.teacherFirstName = 'Ana',
    this.getMyClassesDelay,
  })  : classes = classes ?? [],
        members = members ?? [];

  List<TeacherClass> classes;
  List<ClassMember> members;
  String teacherFirstName;

  /// When set, `getMyClasses()` awaits this instead of returning
  /// immediately — lets a test hold `_load()` mid-flight to exercise the
  /// dispose-while-loading path.
  Completer<void>? getMyClassesDelay;

  @override
  Future<List<TeacherClass>> getMyClasses() async {
    if (getMyClassesDelay != null) await getMyClassesDelay!.future;
    return classes;
  }

  @override
  Future<List<ClassMember>> getMembersForClasses(List<String> classIds) async {
    return members.where((m) => classIds.contains(m.classId)).toList();
  }

  @override
  Future<String> getCurrentTeacherFirstName() async => teacherFirstName;

  @override
  Stream<List<TeacherClass>> watchMyClasses() => Stream.value(classes);

  @override
  Future<TeacherClass?> findByCode(String code) async => null;

  @override
  Future<List<ClassMember>> getMembers(String classId) async =>
      members.where((m) => m.classId == classId).toList();

  @override
  Future<List<ClassMember>> getEnrollmentsForStudent(String studentId) async =>
      members.where((m) => m.studentId == studentId).toList();

  @override
  Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<TeacherClass>> getPublicClassesForAge(int childAge) async => [];

  @override
  Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  }) async =>
      false;

  @override
  Future<void> deleteClass(String classId) async {}

  @override
  Future<void> removeMember({
    required String classId,
    required String memberId,
  }) async {}

  @override
  Future<void> joinClass({
    required String classId,
    required String displayName,
    required String email,
    required String role,
    String? studentId,
    String? childProfileId,
    String? parentUid,
    int? age,
    String? focusSubject,
  }) async {}
}

class FakeClassroomChallengesRepository
    implements ClassroomChallengesRepository {
  FakeClassroomChallengesRepository({List<ClassroomChallenge>? challenges})
      : challenges = challenges ?? [];

  List<ClassroomChallenge> challenges;

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
  ) async {
    final ids = classes.map((c) => c.id).toSet();
    return challenges.where((c) => ids.contains(c.classId)).toList();
  }

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

final _class1 = TeacherClass(
  id: 'c1',
  teacherUid: 'teacher-1',
  teacherName: 'Ana',
  name: '4to Grado A',
  subject: 'math',
  gradeLevel: '4to',
  joinCode: 'AB12CD',
  studentCount: 3,
  createdAt: DateTime(2026, 1, 1),
);

ClassMember _member(String id, String studentId) => ClassMember(
      id: id,
      classId: 'c1',
      teacherUid: 'teacher-1',
      className: '4to Grado A',
      classSubject: 'math',
      classGradeLevel: '4to',
      displayName: 'Estudiante $studentId',
      email: '$studentId@example.com',
      role: 'student',
      studentId: studentId,
      childProfileId: 'child-$studentId',
      parentUid: 'parent-$studentId',
      age: 9,
      focusSubject: 'math',
      completedChallengeIds: const [],
      joinedAt: DateTime(2026, 1, 5),
    );

/// Polls until the bloc's initial/refresh async `_load()` has finished,
/// instead of guessing a fixed delay.
Future<void> _settle(TeacherDashboardBloc bloc) async {
  for (var i = 0; i < 200 && bloc.isLoading; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  late FakeFirebaseFirestore firestore;
  late FakeTeacherClassesRepository teacherClassesRepository;
  late FakeClassroomChallengesRepository classroomChallengesRepository;

  Future<void> seedStudent(
    String id, {
    required int points,
    List<Map<String, dynamic>>? scores,
  }) async {
    final doc = firestore.collection('students').doc(id);
    await doc.set({'name': 'Estudiante $id', 'age': 9, 'points': points});
    for (final score in scores ?? const []) {
      await doc.collection('scores').add(score);
    }
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    teacherClassesRepository = FakeTeacherClassesRepository(
      classes: [_class1],
      members: [_member('m1', 's1'), _member('m2', 's2'), _member('m3', 's3')],
    );
    classroomChallengesRepository = FakeClassroomChallengesRepository();

    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepository(
        datasource: StudentDatasource(firestore: firestore),
      ),
    );
    sl.registerLazySingleton<TeacherClassesRepository>(
      () => teacherClassesRepository,
    );
    sl.registerLazySingleton<ClassroomChallengesRepository>(
      () => classroomChallengesRepository,
    );
  });

  tearDown(() {
    sl.reset();
  });

  group('initial load', () {
    test('sets isLoading to false and loads the teacher name', () async {
      await seedStudent('s1', points: 100);
      await seedStudent('s2', points: 150);
      await seedStudent('s3', points: 190);

      final bloc = TeacherDashboardBloc();
      expect(bloc.isLoading, isTrue);
      await _settle(bloc);

      expect(bloc.isLoading, isFalse);
      expect(bloc.teacherName, 'Ana');
      expect(bloc.classes, hasLength(1));

      bloc.dispose();
    });

    test('computes totalStudents and averageProgress from the roster',
        () async {
      // progress = points % 100 / 100 → s1: 0.0, s2: 0.5, s3: 0.9
      await seedStudent('s1', points: 100);
      await seedStudent('s2', points: 150);
      await seedStudent('s3', points: 190);

      final bloc = TeacherDashboardBloc();
      await _settle(bloc);

      expect(bloc.totalStudents, 3);
      expect(bloc.averageProgress, closeTo((0.0 + 0.5 + 0.9) / 3, 1e-9));

      bloc.dispose();
    });

    test('computes completionRate from students with recent scores',
        () async {
      final now = DateTime.now();
      await seedStudent(
        's1',
        points: 100,
        scores: [
          {
            'subjectKey': 'math',
            'gameTitle': 'Suma',
            'score': 80,
            'date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
          },
        ],
      );
      await seedStudent(
        's2',
        points: 150,
        scores: [
          {
            'subjectKey': 'math',
            'gameTitle': 'Resta',
            'score': 60,
            'date': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
          },
        ],
      );
      // s3 has no recent scores at all.
      await seedStudent('s3', points: 190);

      final bloc = TeacherDashboardBloc();
      await _settle(bloc);

      // 2 of 3 students have at least one recent score → round(2/3*100) = 67
      expect(bloc.completionRate, 67);

      bloc.dispose();
    });

    test('topStudents ranks by trend descending, supportStudents by '
        'recentAverage ascending', () async {
      final now = DateTime.now();
      await seedStudent(
        's1',
        points: 100,
        scores: [
          {
            'subjectKey': 'math',
            'gameTitle': 'Suma',
            'score': 80,
            'date': Timestamp.fromDate(now.subtract(const Duration(days: 2))),
          },
        ],
      );
      await seedStudent(
        's2',
        points: 150,
        scores: [
          {
            'subjectKey': 'math',
            'gameTitle': 'Resta',
            'score': 60,
            'date': Timestamp.fromDate(now.subtract(const Duration(days: 3))),
          },
        ],
      );
      await seedStudent('s3', points: 190);

      final bloc = TeacherDashboardBloc();
      await _settle(bloc);

      expect(
        bloc.topStudents.map((s) => s['id']).toList(),
        ['s1', 's2', 's3'],
      );
      expect(
        bloc.supportStudents.map((s) => s['id']).toList(),
        ['s3', 's2', 's1'],
      );

      bloc.dispose();
    });
  });

  group('dispose', () {
    test('a load in flight when dispose() is called does not throw on '
        'the pending notifyListeners()', () async {
      final delay = Completer<void>();
      teacherClassesRepository.getMyClassesDelay = delay;

      final bloc = TeacherDashboardBloc();
      // The bloc's constructor kicked off _load(), which is now suspended
      // awaiting getMyClasses(). Dispose before it can resolve.
      bloc.dispose();

      // Let the in-flight _load() finish; without the `_disposed` guard
      // this would throw "A TeacherDashboardBloc was used after being
      // disposed." from the final notifyListeners() call.
      delay.complete();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      // No exception propagated — the test reaching here is the assertion.
    });
  });

  group('refresh', () {
    test('reloads data reflecting changes made after the initial load',
        () async {
      await seedStudent('s1', points: 100);
      await seedStudent('s2', points: 150);
      await seedStudent('s3', points: 190);

      final bloc = TeacherDashboardBloc();
      await _settle(bloc);
      expect(bloc.totalStudents, 3);

      // Add a 4th member to the roster and a matching student profile,
      // then confirm refresh() picks it up.
      teacherClassesRepository.members = [
        ...teacherClassesRepository.members,
        _member('m4', 's4'),
      ];
      await seedStudent('s4', points: 200);

      await bloc.refresh();

      expect(bloc.totalStudents, 4);

      bloc.dispose();
    });
  });
}

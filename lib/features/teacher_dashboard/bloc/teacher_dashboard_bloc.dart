import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/features/teacher_dashboard/services/classroom_challenges_service.dart';
import 'package:edu_play/features/teacher_dashboard/services/teacher_classes_service.dart';
import 'package:edu_play/utils/injection_container.dart';

class TeacherDashboardBloc extends ChangeNotifier {
  TeacherDashboardBloc() {
    _load();
  }

  final StudentRepository _studentRepository = sl<StudentRepository>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isLoading = true;
  String teacherName = 'Profe';
  List<TeacherClass> classes = [];
  List<ClassMember> members = [];
  List<Map<String, dynamic>> students = [];
  List<double> weeklyTotals = [];
  List<SubjectPerformance> subjectPerformance = [];
  List<Map<String, dynamic>> challenges = [];

  int get totalStudents => students.length;

  int get newStudentsThisWeek =>
      students.where((s) => _isWithinDays(s['joinedAt'], 7)).length;

  List<Map<String, dynamic>> get activeChallenges =>
      challenges.where((c) => c['status'] == 'active').toList();

  List<Map<String, dynamic>> get completedChallenges =>
      challenges.where((c) => c['status'] == 'completed').toList();

  double get averageProgress {
    if (students.isEmpty) return 0;
    final total = students.fold<double>(
      0,
      (acc, s) => acc + ((s['progress'] as num?)?.toDouble() ?? 0),
    );
    return total / students.length;
  }

  int get averageMinutes {
    final activeStudents =
        students.where((s) => (s['recentScoreCount'] as int? ?? 0) > 0).length;
    if (activeStudents == 0) return 0;
    final totalScores = students.fold<int>(
      0,
      (runningTotal, s) => runningTotal + (s['recentScoreCount'] as int? ?? 0),
    );
    return ((totalScores * 5) / activeStudents).round();
  }

  int get completionRate {
    if (students.isEmpty) return 0;
    final completed =
        students.where((s) => (s['recentScoreCount'] as int? ?? 0) > 0).length;
    return ((completed / students.length) * 100).round();
  }

  List<Map<String, dynamic>> get topStudents {
    final copy = [...students];
    copy.sort(
      (a, b) => ((b['trend'] as num?)?.toDouble() ?? 0)
          .compareTo((a['trend'] as num?)?.toDouble() ?? 0),
    );
    return copy.take(3).toList();
  }

  List<Map<String, dynamic>> get supportStudents {
    final copy = [...students];
    copy.sort((a, b) {
      final aScore = (a['recentAverage'] as num?)?.toDouble() ?? 0;
      final bScore = (b['recentAverage'] as num?)?.toDouble() ?? 0;
      return aScore.compareTo(bScore);
    });
    return copy.take(3).toList();
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      teacherName = await _loadTeacherName();
      classes = await TeacherClassesService.getMyClasses();
      members = await TeacherClassesService.getMembersForClasses(
        classes.map((c) => c.id).toList(),
      );

      final linkedStudentIds = members
          .map((m) => m.studentId)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      final results = await Future.wait([
        _studentRepository.getStudentsByIds(linkedStudentIds),
        _studentRepository.getRecentScoresForStudents(linkedStudentIds,
            days: 28),
        _studentRepository.getWeeklyScoreTotalsForStudents(linkedStudentIds),
        _studentRepository.getSubjectPerformanceForStudents(linkedStudentIds),
        ClassroomChallengesService.getChallengesForClasses(classes),
      ]);

      final studentProfiles = results[0] as List<Map<String, dynamic>>;
      final recentScores = results[1] as List<Map<String, dynamic>>;
      weeklyTotals = results[2] as List<double>;
      subjectPerformance = results[3] as List<SubjectPerformance>;
      challenges = (results[4] as List<ClassroomChallenge>)
          .map((c) => c.toTeacherMap())
          .toList();

      students = _buildRoster(
        members: members,
        classes: classes,
        profiles: studentProfiles,
        recentScores: recentScores,
      );
    } catch (e) {
      debugPrint('TeacherDashboardBloc load error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> addChallenge({
    required String classId,
    required String title,
    required String subjectKey,
    String? dueDate,
  }) async {
    await ClassroomChallengesService.createChallenge(
      classId: classId,
      title: title,
      subjectKey: subjectKey,
      dueDate: dueDate,
    );
    await _load();
  }

  List<Map<String, dynamic>> _buildRoster({
    required List<ClassMember> members,
    required List<TeacherClass> classes,
    required List<Map<String, dynamic>> profiles,
    required List<Map<String, dynamic>> recentScores,
  }) {
    final classById = {for (final c in classes) c.id: c};
    final profileById = {for (final p in profiles) p['id'] as String: p};
    final scoresByStudent = <String, List<Map<String, dynamic>>>{};

    for (final score in recentScores) {
      final studentId = score['studentId'] as String?;
      if (studentId == null || studentId.isEmpty) continue;
      (scoresByStudent[studentId] ??= []).add(score);
    }

    return members.map((member) {
      final profile = profileById[member.studentId];
      final classInfo = classById[member.classId];
      final scoreEntries = scoresByStudent[member.studentId] ?? const [];
      final recentAverage = _averageForLastDays(scoreEntries, 7);
      final previousAverage = _averageForDaysRange(scoreEntries, 7, 14);
      final trend = recentAverage - previousAverage;
      final points = (profile?['points'] as num?)?.toInt() ?? 0;

      return {
        'id': member.studentId,
        'memberId': member.id,
        'classId': member.classId,
        'className': classInfo?.name ?? member.className,
        'name': (profile?['name'] as String?)?.trim().isNotEmpty == true
            ? profile!['name']
            : member.displayName,
        'email': member.email,
        'age': (profile?['age'] as num?)?.toInt() ?? member.age,
        'focusSubject': member.focusSubject,
        'points': points,
        'streak': (profile?['streak'] as num?)?.toInt() ?? 0,
        'progress': StudentRepository.xpProgress(points),
        'joinedAt': member.joinedAt,
        'recentAverage': recentAverage,
        'previousAverage': previousAverage,
        'trend': trend,
        'recentScoreCount': scoreEntries.length,
        'completedChallengeIds': member.completedChallengeIds,
      };
    }).toList()
      ..sort(
        (a, b) => ((b['points'] as num?)?.toInt() ?? 0)
            .compareTo((a['points'] as num?)?.toInt() ?? 0),
      );
  }

  double _averageForLastDays(
    List<Map<String, dynamic>> entries,
    int days,
  ) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final values = entries
        .where((entry) {
          final date = _toDate(entry['date']);
          return date != null && date.isAfter(cutoff);
        })
        .map((entry) => (entry['score'] as num?)?.toDouble() ?? 0)
        .toList();
    return _average(values);
  }

  double _averageForDaysRange(
    List<Map<String, dynamic>> entries,
    int startDaysAgo,
    int endDaysAgo,
  ) {
    final newer = DateTime.now().subtract(Duration(days: startDaysAgo));
    final older = DateTime.now().subtract(Duration(days: endDaysAgo));
    final values = entries
        .where((entry) {
          final date = _toDate(entry['date']);
          return date != null && date.isBefore(newer) && date.isAfter(older);
        })
        .map((entry) => (entry['score'] as num?)?.toDouble() ?? 0)
        .toList();
    return _average(values);
  }

  double _average(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  DateTime? _toDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }

  bool _isWithinDays(dynamic value, int days) {
    if (value is DateTime) {
      return DateTime.now().difference(value).inDays < days;
    }
    if (value is Timestamp) {
      return DateTime.now().difference(value.toDate()).inDays < days;
    }
    return false;
  }

  Future<String> _loadTeacherName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 'Profe';

    final doc = await _db.collection('teachers').doc(uid).get();
    if (!doc.exists) return 'Profe';

    final firstName = (doc.data()?['firstName'] as String?)?.trim();
    return (firstName == null || firstName.isEmpty) ? 'Profe' : firstName;
  }
}

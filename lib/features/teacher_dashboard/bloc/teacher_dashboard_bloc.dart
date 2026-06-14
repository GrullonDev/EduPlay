import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:edu_play/data/datasources/local/database_helper.dart';
import 'package:edu_play/data/repositories/student_repository.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Loads and exposes everything the teacher dashboard ("Panel del Profesor")
/// needs: the full student roster (Firestore), weekly score totals,
/// per-subject performance and the locally-stored assigned challenges.
class TeacherDashboardBloc extends ChangeNotifier {
  TeacherDashboardBloc() {
    _load();
  }

  final StudentRepository _studentRepository = sl<StudentRepository>();
  final DatabaseHelper _db = DatabaseHelper();

  bool isLoading = true;
  List<Map<String, dynamic>> students = [];
  List<double> weeklyTotals = [];
  List<SubjectPerformance> subjectPerformance = [];
  List<Map<String, dynamic>> challenges = [];

  int get totalStudents => students.length;

  int get newStudentsThisWeek =>
      students.where((s) => _isWithinDays(s['createdAt'], 7)).length;

  List<Map<String, dynamic>> get activeChallenges =>
      challenges.where((c) => c['status'] == 'active').toList();

  List<Map<String, dynamic>> get completedChallenges =>
      challenges.where((c) => c['status'] == 'completed').toList();

  /// Average level progress (0-1) across all students.
  double get averageProgress {
    if (students.isEmpty) return 0;
    final total = students.fold<double>(
      0,
      (acc, s) =>
          acc +
          StudentRepository.xpProgress((s['points'] as num?)?.toInt() ?? 0),
    );
    return total / students.length;
  }

  Future<void> _load() async {
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _studentRepository.getAllStudents(),
        _studentRepository.getWeeklyScoreTotals(),
        _studentRepository.getSubjectPerformance(),
        _db.getChallenges(),
      ]);

      students = results[0] as List<Map<String, dynamic>>;
      weeklyTotals = results[1] as List<double>;
      subjectPerformance = results[2] as List<SubjectPerformance>;
      challenges = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('TeacherDashboardBloc load error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() => _load();

  Future<void> addChallenge({
    required String title,
    required String subjectKey,
    String? dueDate,
  }) async {
    await _db.insertChallenge(
      title: title,
      subjectKey: subjectKey,
      dueDate: dueDate,
    );
    challenges = await _db.getChallenges();
    notifyListeners();
  }

  bool _isWithinDays(dynamic timestamp, int days) {
    if (timestamp is! Timestamp) return false;
    return DateTime.now().difference(timestamp.toDate()).inDays < days;
  }
}

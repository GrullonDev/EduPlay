import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Firestore-backed datasource for the student gamification profile
/// (points, streak, level) and per-game score history. This is the data
/// source shared between the student dashboard (own profile) and the
/// teacher dashboard (roster + aggregates), so it works across devices and
/// on the web build where the local sqflite database is unavailable.
class StudentDatasource {
  static const _studentIdKey = 'student_id';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _students =>
      _firestore.collection('students');

  Future<void> setStudentId(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_studentIdKey, studentId);
  }

  Future<String> getOrCreateStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_studentIdKey);
    if (id == null) {
      id = _firestore.collection('students').doc().id;
      await prefs.setString(_studentIdKey, id);
    }
    return id;
  }

  Future<void> ensureProfile({
    required String studentId,
    required String name,
    required int age,
    String? avatar,
  }) async {
    try {
      final doc = _students.doc(studentId);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set({
          'name': name,
          'age': age,
          'avatar': avatar ?? 'lion',
          'points': 0,
          'streak': 0,
          'lastPlayedDate': null,
          'childProfileId': studentId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await doc.set({
          'name': name,
          'age': age,
          if (avatar != null) 'avatar': avatar,
          'childProfileId': studentId,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('StudentDatasource.ensureProfile error: $e');
    }
  }

  Future<Map<String, dynamic>?> getProfile(String studentId) async {
    try {
      final snapshot = await _students.doc(studentId).get();
      if (!snapshot.exists) return null;
      return {...snapshot.data()!, 'id': snapshot.id};
    } catch (e) {
      debugPrint('StudentDatasource.getProfile error: $e');
      return null;
    }
  }

  Future<void> recordScore({
    required String studentId,
    required String subjectKey,
    required String subjectLabel,
    required String gameTitle,
    required int score,
  }) async {
    try {
      final doc = _students.doc(studentId);
      final now = DateTime.now();
      final today = _dateKey(now);
      final yesterday = _dateKey(now.subtract(const Duration(days: 1)));

      await _firestore.runTransaction((tx) async {
        final snapshot = await tx.get(doc);
        final data = snapshot.data();
        final lastPlayedDate = data?['lastPlayedDate'] as String?;
        var streak = (data?['streak'] as num?)?.toInt() ?? 0;

        if (lastPlayedDate == today) {
          // Already played today, streak stays the same.
        } else if (lastPlayedDate == yesterday) {
          streak += 1;
        } else {
          streak = 1;
        }

        tx.set(
          doc,
          {
            'points': FieldValue.increment(score),
            'streak': streak,
            'lastPlayedDate': today,
          },
          SetOptions(merge: true),
        );
      });

      await doc.collection('scores').add({
        'studentId': studentId,
        'subjectKey': subjectKey,
        'subjectLabel': subjectLabel,
        'gameTitle': gameTitle,
        'score': score,
        'date': Timestamp.fromDate(now),
      });
    } catch (e) {
      debugPrint('StudentDatasource.recordScore error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    try {
      final snapshot = await _students
          .orderBy('points', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getLeaderboard error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final snapshot =
          await _students.orderBy('points', descending: true).get();
      return snapshot.docs.map((d) => {...d.data(), 'id': d.id}).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getAllStudents error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    try {
      final results = <Map<String, dynamic>>[];
      for (var i = 0; i < ids.length; i += 10) {
        final chunk = ids.sublist(i, i + 10 > ids.length ? ids.length : i + 10);
        final snapshot =
            await _students.where(FieldPath.documentId, whereIn: chunk).get();
        results.addAll(
          snapshot.docs.map((d) => {...d.data(), 'id': d.id}),
        );
      }
      return results;
    } catch (e) {
      debugPrint('StudentDatasource.getStudentsByIds error: $e');
      return [];
    }
  }

  /// All score entries (across every student) from the last [days] days,
  /// used to build the teacher's weekly progress chart and per-subject
  /// performance breakdown.
  Future<List<Map<String, dynamic>>> getRecentScores({int days = 28}) async {
    try {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      final snapshot = await _firestore
          .collectionGroup('scores')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
          .get();
      return snapshot.docs.map((d) => d.data()).toList();
    } catch (e) {
      debugPrint('StudentDatasource.getRecentScores error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getRecentScoresForStudents(
    List<String> studentIds, {
    int days = 28,
  }) async {
    if (studentIds.isEmpty) return [];

    final cutoff = DateTime.now().subtract(Duration(days: days));
    final results = <Map<String, dynamic>>[];

    try {
      for (final studentId in studentIds) {
        final snapshot = await _students
            .doc(studentId)
            .collection('scores')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
            .get();
        results.addAll(
          snapshot.docs.map((d) => {
                ...d.data(),
                'studentId': studentId,
              }),
        );
      }
      return results;
    } catch (e) {
      debugPrint('StudentDatasource.getRecentScoresForStudents error: $e');
      return [];
    }
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

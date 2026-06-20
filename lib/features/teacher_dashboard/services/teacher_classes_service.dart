import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class TeacherClass {
  const TeacherClass({
    required this.id,
    required this.teacherUid,
    required this.name,
    required this.subject,
    required this.gradeLevel,
    required this.joinCode,
    required this.studentCount,
    required this.createdAt,
  });

  final String id;
  final String teacherUid;
  final String name;
  final String subject;
  final String gradeLevel;
  final String joinCode; // 6-char alphanumeric
  final int studentCount;
  final DateTime createdAt;

  factory TeacherClass.fromMap(Map<String, dynamic> m, String id) =>
      TeacherClass(
        id: id,
        teacherUid: (m['teacherUid'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        subject: (m['subject'] as String?) ?? '',
        gradeLevel: (m['gradeLevel'] as String?) ?? '',
        joinCode: (m['joinCode'] as String?) ?? '',
        studentCount: (m['studentCount'] as int?) ?? 0,
        createdAt: m['createdAt'] is Timestamp
            ? (m['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'teacherUid': teacherUid,
        'name': name,
        'subject': subject,
        'gradeLevel': gradeLevel,
        'joinCode': joinCode,
        'studentCount': studentCount,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ── Class member (student / parent in a class) ────────────────────────────────

class ClassMember {
  const ClassMember({
    required this.id,
    required this.classId,
    required this.displayName,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  final String id;
  final String classId;
  final String displayName;
  final String email;
  final String role; // 'student' | 'parent'
  final DateTime joinedAt;

  factory ClassMember.fromMap(Map<String, dynamic> m, String id) =>
      ClassMember(
        id: id,
        classId: (m['classId'] as String?) ?? '',
        displayName: (m['displayName'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        role: (m['role'] as String?) ?? 'student',
        joinedAt: m['joinedAt'] is Timestamp
            ? (m['joinedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class TeacherClassesService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _classes =>
      _db.collection('classes');

  // ── Generate unique 6-char join code ──────────────────────────────────────

  static Future<String> _uniqueJoinCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    while (true) {
      final code = List.generate(6, (_) => chars[rng.nextInt(chars.length)])
          .join();
      final existing = await _classes
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Real-time stream of the current teacher's classes.
  static Stream<List<TeacherClass>> watchMyClasses() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _classes
        .where('teacherUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => TeacherClass.fromMap(d.data(), d.id))
            .toList());
  }

  /// Looks up a class by its join code (no auth required).
  static Future<TeacherClass?> findByCode(String code) async {
    final snap = await _classes
        .where('joinCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return TeacherClass.fromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  /// Returns members of a class.
  static Future<List<ClassMember>> getMembers(String classId) async {
    final snap = await _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .orderBy('joinedAt')
        .get();
    return snap.docs
        .map((d) => ClassMember.fromMap(d.data(), d.id))
        .toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Creates a new class and returns it.
  static Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not authenticated');

    final joinCode = await _uniqueJoinCode();
    final docRef = _classes.doc();

    final tc = TeacherClass(
      id: docRef.id,
      teacherUid: uid,
      name: name,
      subject: subject,
      gradeLevel: gradeLevel,
      joinCode: joinCode,
      studentCount: 0,
      createdAt: DateTime.now(),
    );

    await docRef.set(tc.toMap());
    return tc;
  }

  /// Deletes a class (teacher only).
  static Future<void> deleteClass(String classId) async {
    await _classes.doc(classId).delete();
  }

  /// Adds the current user to a class as [role].
  static Future<void> joinClass({
    required String classId,
    required String displayName,
    required String email,
    required String role,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not authenticated');

    final memberRef = _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(uid);

    await memberRef.set({
      'classId': classId,
      'displayName': displayName,
      'email': email,
      'role': role,
      'joinedAt': FieldValue.serverTimestamp(),
    });

    // Increment student count
    await _classes.doc(classId).update({
      'studentCount': FieldValue.increment(1),
    });
  }
}

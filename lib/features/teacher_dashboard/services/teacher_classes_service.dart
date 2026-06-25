import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

class TeacherClass {
  factory TeacherClass.fromMap(Map<String, dynamic> m, String id) =>
      TeacherClass(
        id: id,
        teacherUid: (m['teacherUid'] as String?) ?? '',
        teacherName: (m['teacherName'] as String?) ?? '',
        name: (m['name'] as String?) ?? '',
        subject: (m['subject'] as String?) ?? '',
        gradeLevel: (m['gradeLevel'] as String?) ?? '',
        joinCode: (m['joinCode'] as String?) ?? '',
        studentCount: (m['studentCount'] as int?) ?? 0,
        minAge: (m['minAge'] as num?)?.toInt() ?? 3,
        maxAge: (m['maxAge'] as num?)?.toInt() ?? 12,
        isPublic: (m['isPublic'] as bool?) ?? false,
        createdAt: m['createdAt'] is Timestamp
            ? (m['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
  const TeacherClass({
    required this.id,
    required this.teacherUid,
    this.teacherName = '',
    required this.name,
    required this.subject,
    required this.gradeLevel,
    required this.joinCode,
    required this.studentCount,
    this.minAge = 3,
    this.maxAge = 12,
    this.isPublic = false,
    required this.createdAt,
  });

  final String id;
  final String teacherUid;
  /// Display name of the teacher — populated when fetched via the directory.
  final String teacherName;
  final String name;
  final String subject;
  final String gradeLevel;
  final String joinCode; // 6-char alphanumeric
  final int studentCount;
  /// Age range this class accepts (inclusive). Used by the parent directory.
  final int minAge;
  final int maxAge;
  /// When true, the class appears in the parent-facing teacher directory.
  final bool isPublic;
  final DateTime createdAt;

  /// Human-readable age range string, e.g. "6–9 años".
  String get ageRangeLabel => '$minAge–$maxAge años';

  Map<String, dynamic> toMap() => {
        'teacherUid': teacherUid,
        'teacherName': teacherName,
        'name': name,
        'subject': subject,
        'gradeLevel': gradeLevel,
        'joinCode': joinCode,
        'studentCount': studentCount,
        'minAge': minAge,
        'maxAge': maxAge,
        'isPublic': isPublic,
        'createdAt': FieldValue.serverTimestamp(),
      };
}

// ── Class member (student / parent in a class) ────────────────────────────────

class ClassMember {
  factory ClassMember.fromMap(Map<String, dynamic> m, String id) => ClassMember(
        id: id,
        classId: (m['classId'] as String?) ?? '',
        teacherUid: (m['teacherUid'] as String?) ?? '',
        className: (m['className'] as String?) ?? '',
        classSubject: (m['classSubject'] as String?) ?? '',
        classGradeLevel: (m['classGradeLevel'] as String?) ?? '',
        displayName: (m['displayName'] as String?) ?? '',
        email: (m['email'] as String?) ?? '',
        role: (m['role'] as String?) ?? 'student',
        studentId: (m['studentId'] as String?) ?? id,
        childProfileId: (m['childProfileId'] as String?) ?? '',
        parentUid: (m['parentUid'] as String?) ?? '',
        age: (m['age'] as num?)?.toInt(),
        focusSubject: (m['focusSubject'] as String?) ?? '',
        completedChallengeIds: List<String>.from(
            (m['completedChallengeIds'] as List?) ?? const []),
        joinedAt: m['joinedAt'] is Timestamp
            ? (m['joinedAt'] as Timestamp).toDate()
            : DateTime.now(),
      );
  const ClassMember({
    required this.id,
    required this.classId,
    required this.teacherUid,
    required this.className,
    required this.classSubject,
    required this.classGradeLevel,
    required this.displayName,
    required this.email,
    required this.role,
    required this.studentId,
    required this.childProfileId,
    required this.parentUid,
    required this.age,
    required this.focusSubject,
    required this.completedChallengeIds,
    required this.joinedAt,
  });

  final String id;
  final String classId;
  final String teacherUid;
  final String className;
  final String classSubject;
  final String classGradeLevel;
  final String displayName;
  final String email;
  final String role; // 'student' | 'parent'
  final String studentId;
  final String childProfileId;
  final String parentUid;
  final int? age;
  final String focusSubject;
  final List<String> completedChallengeIds;
  final DateTime joinedAt;
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
      final code =
          List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
      final existing =
          await _classes.where('joinCode', isEqualTo: code).limit(1).get();
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
    return snap.docs.map((d) => ClassMember.fromMap(d.data(), d.id)).toList();
  }

  static Future<List<TeacherClass>> getMyClasses() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _classes
        .where('teacherUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => TeacherClass.fromMap(d.data(), d.id)).toList();
  }

  static Future<List<ClassMember>> getMembersForClasses(
    List<String> classIds,
  ) async {
    final results = <ClassMember>[];
    for (final classId in classIds) {
      results.addAll(await getMembers(classId));
    }
    return results;
  }

  static Future<List<ClassMember>> getEnrollmentsForStudent(
    String studentId,
  ) async {
    final results = <ClassMember>[];

    final byStudentId = await _db
        .collectionGroup('members')
        .where('studentId', isEqualTo: studentId)
        .get();
    results.addAll(
      byStudentId.docs.map((d) => ClassMember.fromMap(d.data(), d.id)),
    );

    if (results.isEmpty) {
      final byChildProfileId = await _db
          .collectionGroup('members')
          .where('childProfileId', isEqualTo: studentId)
          .get();
      results.addAll(
        byChildProfileId.docs.map((d) => ClassMember.fromMap(d.data(), d.id)),
      );
    }

    return results;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Creates a new class and returns it.
  static Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not authenticated');

    // Fetch the teacher's display name so directory listings can show it
    // without an extra round-trip.
    String teacherName = '';
    try {
      final teacherDoc = await _db.collection('teachers').doc(uid).get();
      final d = teacherDoc.data();
      if (d != null) {
        final first = (d['firstName'] as String?)?.trim() ?? '';
        final last = (d['lastName'] as String?)?.trim() ?? '';
        teacherName = [first, last].where((s) => s.isNotEmpty).join(' ');
      }
    } catch (_) {}

    final joinCode = await _uniqueJoinCode();
    final docRef = _classes.doc();

    final tc = TeacherClass(
      id: docRef.id,
      teacherUid: uid,
      teacherName: teacherName,
      name: name,
      subject: subject,
      gradeLevel: gradeLevel,
      joinCode: joinCode,
      studentCount: 0,
      minAge: minAge,
      maxAge: maxAge,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );

    await docRef.set(tc.toMap());
    return tc;
  }

  // ── Teacher directory (parent-facing) ─────────────────────────────────────

  /// Returns all public classes whose age range includes [childAge].
  /// Results are ordered by creation date (newest first).
  static Future<List<TeacherClass>> getPublicClassesForAge(int childAge) async {
    final snap = await _classes
        .where('isPublic', isEqualTo: true)
        .where('minAge', isLessThanOrEqualTo: childAge)
        .orderBy('minAge')
        .orderBy('createdAt', descending: true)
        .get();

    // Firestore compound queries can only filter one inequality field, so we
    // filter maxAge on the client side.
    return snap.docs
        .map((d) => TeacherClass.fromMap(d.data(), d.id))
        .where((tc) => tc.maxAge >= childAge)
        .toList();
  }

  /// Checks whether [childProfileId] is already enrolled in [classId].
  static Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  }) async {
    final doc = await _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(childProfileId)
        .get();
    return doc.exists;
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
    String? studentId,
    String? childProfileId,
    String? parentUid,
    int? age,
    String? focusSubject,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not authenticated');

    final classDoc = await _classes.doc(classId).get();
    if (!classDoc.exists) throw StateError('Class not found');

    final classData = classDoc.data() ?? <String, dynamic>{};
    final memberKey = (studentId?.isNotEmpty ?? false) ? studentId! : uid;
    final memberRef = _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .doc(memberKey);

    await _db.runTransaction((tx) async {
      final existing = await tx.get(memberRef);

      tx.set(
          memberRef,
          {
            'classId': classId,
            'teacherUid': (classData['teacherUid'] as String?) ?? '',
            'className': (classData['name'] as String?) ?? '',
            'classSubject': (classData['subject'] as String?) ?? '',
            'classGradeLevel': (classData['gradeLevel'] as String?) ?? '',
            'displayName': displayName,
            'email': email,
            'role': role,
            'studentId': studentId ?? memberKey,
            'childProfileId': childProfileId ?? '',
            'parentUid': parentUid ?? uid,
            'age': age,
            'focusSubject': focusSubject ?? '',
            'completedChallengeIds':
                existing.data()?['completedChallengeIds'] ?? const [],
            'joinedAt': existing.exists
                ? (existing.data()?['joinedAt'] ?? FieldValue.serverTimestamp())
                : FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true));

      if (!existing.exists) {
        tx.update(_classes.doc(classId), {
          'studentCount': FieldValue.increment(1),
        });
      }
    });
  }
}

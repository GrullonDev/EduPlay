import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/teacher_dashboard/domain/entities/class_member.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';

abstract class TeacherClassesDatasource {
  Stream<List<TeacherClass>> watchMyClasses();

  Future<TeacherClass?> findByCode(String code);

  Future<List<ClassMember>> getMembers(String classId);

  Future<List<TeacherClass>> getMyClasses();

  Future<List<ClassMember>> getMembersForClasses(List<String> classIds);

  Future<List<ClassMember>> getEnrollmentsForStudent(String studentId);

  Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  });

  Future<List<TeacherClass>> getPublicClassesForAge(int childAge);

  Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  });

  Future<void> deleteClass(String classId);

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
  });

  Future<String> getCurrentTeacherFirstName();
}

class FirestoreTeacherClassesDatasource implements TeacherClassesDatasource {
  FirestoreTeacherClassesDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _classes =>
      _db.collection('classes');

  @override
  Stream<List<TeacherClass>> watchMyClasses() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _classes
        .where('teacherUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => _teacherClassFromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<TeacherClass?> findByCode(String code) async {
    final snap = await _classes
        .where('joinCode', isEqualTo: code.trim().toUpperCase())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _teacherClassFromMap(snap.docs.first.data(), snap.docs.first.id);
  }

  @override
  Future<List<ClassMember>> getMembers(String classId) async {
    final snap = await _db
        .collection('classes')
        .doc(classId)
        .collection('members')
        .orderBy('joinedAt')
        .get();
    return snap.docs
        .map((doc) => _classMemberFromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<TeacherClass>> getMyClasses() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _classes
        .where('teacherUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => _teacherClassFromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<ClassMember>> getMembersForClasses(List<String> classIds) async {
    final results = <ClassMember>[];
    for (final classId in classIds) {
      results.addAll(await getMembers(classId));
    }
    return results;
  }

  @override
  Future<List<ClassMember>> getEnrollmentsForStudent(String studentId) async {
    final results = <ClassMember>[];

    final byStudentId = await _db
        .collectionGroup('members')
        .where('studentId', isEqualTo: studentId)
        .get();
    results.addAll(
      byStudentId.docs.map((doc) => _classMemberFromMap(doc.data(), doc.id)),
    );

    if (results.isEmpty) {
      final byChildProfileId = await _db
          .collectionGroup('members')
          .where('childProfileId', isEqualTo: studentId)
          .get();
      results.addAll(
        byChildProfileId.docs
            .map((doc) => _classMemberFromMap(doc.data(), doc.id)),
      );
    }

    return results;
  }

  @override
  Future<TeacherClass> createClass({
    required String name,
    required String subject,
    required String gradeLevel,
    int minAge = 3,
    int maxAge = 12,
    bool isPublic = false,
  }) async {
    final uid = _uid;
    if (uid == null) throw StateError('Not authenticated');

    final teacherName = await _loadTeacherName(uid);
    final joinCode = await _uniqueJoinCode();
    final docRef = _classes.doc();

    final teacherClass = TeacherClass(
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

    await docRef.set(_teacherClassToMap(teacherClass));
    return teacherClass;
  }

  @override
  Future<List<TeacherClass>> getPublicClassesForAge(int childAge) async {
    final snap = await _classes
        .where('isPublic', isEqualTo: true)
        .where('minAge', isLessThanOrEqualTo: childAge)
        .orderBy('minAge')
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((doc) => _teacherClassFromMap(doc.data(), doc.id))
        .where((teacherClass) => teacherClass.maxAge >= childAge)
        .toList();
  }

  @override
  Future<bool> isEnrolled({
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

  @override
  Future<void> deleteClass(String classId) {
    return _classes.doc(classId).delete();
  }

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
        SetOptions(merge: true),
      );

      if (!existing.exists) {
        tx.update(_classes.doc(classId), {
          'studentCount': FieldValue.increment(1),
        });
      }
    });
  }

  @override
  Future<String> getCurrentTeacherFirstName() async {
    final uid = _uid;
    if (uid == null) return 'Profe';

    final doc = await _db.collection('teachers').doc(uid).get();
    if (!doc.exists) return 'Profe';

    final firstName = (doc.data()?['firstName'] as String?)?.trim();
    return (firstName == null || firstName.isEmpty) ? 'Profe' : firstName;
  }

  Future<String> _uniqueJoinCode() async {
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

  Future<String> _loadTeacherName(String uid) async {
    try {
      final teacherDoc = await _db.collection('teachers').doc(uid).get();
      final data = teacherDoc.data();
      if (data == null) return '';
      final first = (data['firstName'] as String?)?.trim() ?? '';
      final last = (data['lastName'] as String?)?.trim() ?? '';
      return [first, last].where((value) => value.isNotEmpty).join(' ');
    } catch (_) {
      return '';
    }
  }
}

TeacherClass _teacherClassFromMap(Map<String, dynamic> map, String id) {
  return TeacherClass(
    id: id,
    teacherUid: (map['teacherUid'] as String?) ?? '',
    teacherName: (map['teacherName'] as String?) ?? '',
    name: (map['name'] as String?) ?? '',
    subject: (map['subject'] as String?) ?? '',
    gradeLevel: (map['gradeLevel'] as String?) ?? '',
    joinCode: (map['joinCode'] as String?) ?? '',
    studentCount: (map['studentCount'] as int?) ?? 0,
    minAge: (map['minAge'] as num?)?.toInt() ?? 3,
    maxAge: (map['maxAge'] as num?)?.toInt() ?? 12,
    isPublic: (map['isPublic'] as bool?) ?? false,
    createdAt: map['createdAt'] is Timestamp
        ? (map['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}

Map<String, dynamic> _teacherClassToMap(TeacherClass teacherClass) {
  return {
    'teacherUid': teacherClass.teacherUid,
    'teacherName': teacherClass.teacherName,
    'name': teacherClass.name,
    'subject': teacherClass.subject,
    'gradeLevel': teacherClass.gradeLevel,
    'joinCode': teacherClass.joinCode,
    'studentCount': teacherClass.studentCount,
    'minAge': teacherClass.minAge,
    'maxAge': teacherClass.maxAge,
    'isPublic': teacherClass.isPublic,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

ClassMember _classMemberFromMap(Map<String, dynamic> map, String id) {
  return ClassMember(
    id: id,
    classId: (map['classId'] as String?) ?? '',
    teacherUid: (map['teacherUid'] as String?) ?? '',
    className: (map['className'] as String?) ?? '',
    classSubject: (map['classSubject'] as String?) ?? '',
    classGradeLevel: (map['classGradeLevel'] as String?) ?? '',
    displayName: (map['displayName'] as String?) ?? '',
    email: (map['email'] as String?) ?? '',
    role: (map['role'] as String?) ?? 'student',
    studentId: (map['studentId'] as String?) ?? id,
    childProfileId: (map['childProfileId'] as String?) ?? '',
    parentUid: (map['parentUid'] as String?) ?? '',
    age: (map['age'] as num?)?.toInt(),
    focusSubject: (map['focusSubject'] as String?) ?? '',
    completedChallengeIds: List<String>.from(
      (map['completedChallengeIds'] as List?) ?? const [],
    ),
    joinedAt: map['joinedAt'] is Timestamp
        ? (map['joinedAt'] as Timestamp).toDate()
        : DateTime.now(),
  );
}

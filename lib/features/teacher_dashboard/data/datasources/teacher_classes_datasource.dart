// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
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

  Future<void> removeMember(
      {required String classId, required String memberId});

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
    FirebaseFunctions? functions,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _providedFunctions = functions;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseFunctions? _providedFunctions;

  // Resolved lazily rather than in the initializer list: constructing this
  // datasource in a test that never calls findByCode/joinClass/createClass
  // (e.g. one exercising only deleteClass against fake_cloud_firestore,
  // with no FirebaseApp initialized) shouldn't fail just because
  // FirebaseFunctions.instance requires Firebase.initializeApp().
  FirebaseFunctions get _functions =>
      _providedFunctions ?? FirebaseFunctions.instance;

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
              .map((doc) => TeacherClass.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  @override
  Future<TeacherClass?> findByCode(String code) async {
    // Looking up a class by code is a cross-tenant read (the caller
    // doesn't own the class they're searching for), so it's mediated by a
    // Cloud Function rather than a direct query — classes/{classId} read
    // is restricted to `isPublic == true || teacherUid == uid` precisely
    // so a client can't enumerate every class's joinCode itself.
    final callable = _functions.httpsCallable('lookupClassByJoinCode');
    final result = await callable.call<Map<String, dynamic>>({'code': code});
    final data = result.data;
    if (data['found'] != true) return null;
    return _classFromCallableMap(
      Map<String, dynamic>.from(data['teacherClass'] as Map),
    );
  }

  TeacherClass _classFromCallableMap(Map<String, dynamic> map) {
    final millis = map['createdAtMillis'] as int?;
    return TeacherClass(
      id: map['id'] as String? ?? '',
      teacherUid: map['teacherUid'] as String? ?? '',
      teacherName: map['teacherName'] as String? ?? '',
      name: map['name'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      gradeLevel: map['gradeLevel'] as String? ?? '',
      joinCode: map['joinCode'] as String? ?? '',
      studentCount: (map['studentCount'] as num?)?.toInt() ?? 0,
      minAge: (map['minAge'] as num?)?.toInt() ?? 3,
      maxAge: (map['maxAge'] as num?)?.toInt() ?? 12,
      isPublic: map['isPublic'] as bool? ?? false,
      createdAt: millis != null
          ? DateTime.fromMillisecondsSinceEpoch(millis)
          : DateTime.now(),
    );
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
        .map((doc) => ClassMember.fromMap(doc.data(), doc.id))
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
        .map((doc) => TeacherClass.fromMap(doc.data(), doc.id))
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
    // Called on every student dashboard load — a stalled gRPC channel here
    // (no timeout, no try/catch) would otherwise hang the caller forever
    // instead of falling back to "no classroom challenges today".
    try {
      final results = <ClassMember>[];

      final byStudentId = await _db
          .collectionGroup('members')
          .where('studentId', isEqualTo: studentId)
          .get()
          .timeout(const Duration(seconds: 8));
      results.addAll(
        byStudentId.docs
            .map((doc) => ClassMember.fromMap(doc.data(), doc.id)),
      );

      if (results.isEmpty) {
        final byChildProfileId = await _db
            .collectionGroup('members')
            .where('childProfileId', isEqualTo: studentId)
            .get()
            .timeout(const Duration(seconds: 8));
        results.addAll(
          byChildProfileId.docs
              .map((doc) => ClassMember.fromMap(doc.data(), doc.id)),
        );
      }

      return results;
    } catch (e) {
      return [];
    }
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

    await docRef.set(teacherClass.toMap());
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
        .map((doc) => TeacherClass.fromMap(doc.data(), doc.id))
        .where((teacherClass) => teacherClass.maxAge >= childAge)
        .toList();
  }

  @override
  Future<bool> isEnrolled({
    required String classId,
    required String childProfileId,
  }) async {
    // A member doc that doesn't exist yet is only readable by
    // firestore.rules once the caller already has a relationship to it
    // (owning teacher, linked parent, or the member themself) — checking
    // enrollment in a class you're not part of correctly comes back
    // permission-denied rather than a clean `exists: false`. That's the
    // intended behavior of the rule, not a bug to route around there; "not
    // enrolled" is the right answer for this check either way.
    try {
      final doc = await _db
          .collection('classes')
          .doc(classId)
          .collection('members')
          .doc(childProfileId)
          .get();
      return doc.exists;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') return false;
      rethrow;
    }
  }

  @override
  Future<void> deleteClass(String classId) async {
    final classRef = _classes.doc(classId);

    // Deleting only the class doc would leave its `members` and
    // `challenges` subcollections behind — orphaned docs a student/parent
    // could still read (e.g. a "phantom enrollment"). Firestore has no
    // recursive delete for client SDKs, so gather every subdocument first
    // and remove it before the class itself.
    final memberDocs = await classRef.collection('members').get();
    final challengeDocs = await classRef.collection('challenges').get();

    final refsToDelete = [
      ...memberDocs.docs.map((d) => d.reference),
      ...challengeDocs.docs.map((d) => d.reference),
    ];

    // A WriteBatch caps out at 500 operations. Reserve one for the final
    // class-doc delete and chunk the rest well under that ceiling — in
    // practice a classroom never gets close to this, but a paged delete
    // costs nothing and avoids a silent failure if it ever does.
    const chunkSize = 400;
    for (var i = 0; i < refsToDelete.length; i += chunkSize) {
      final chunk = refsToDelete.skip(i).take(chunkSize);
      final batch = _db.batch();
      for (final ref in chunk) {
        batch.delete(ref);
      }
      await batch.commit();
    }

    await classRef.delete();
  }

  @override
  Future<void> removeMember({
    required String classId,
    required String memberId,
  }) async {
    final classRef = _classes.doc(classId);
    final memberRef = classRef.collection('members').doc(memberId);

    await _db.runTransaction((tx) async {
      final memberSnap = await tx.get(memberRef);
      if (!memberSnap.exists) return;

      tx.delete(memberRef);
      tx.update(classRef, {'studentCount': FieldValue.increment(-1)});
    });
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
    if (_uid == null) throw StateError('Not authenticated');

    // Same reasoning as findByCode: the caller doesn't own `classId` (it's
    // someone else's class), and the member-doc write also needs to read
    // that class's name/subject/teacherUid to denormalize onto the new
    // member — none of which the client can do anymore once
    // classes/{classId} read is restricted to the owning teacher (or
    // public classes). The Cloud Function runs the identical transaction
    // via the Admin SDK.
    final callable = _functions.httpsCallable('joinClassByCode');
    await callable.call<Map<String, dynamic>>({
      'classId': classId,
      'displayName': displayName,
      'email': email,
      'role': role,
      'studentId': studentId,
      'childProfileId': childProfileId,
      'parentUid': parentUid,
      'age': age,
      'focusSubject': focusSubject,
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
    // Uniqueness has to be checked across *every* class, not just the
    // caller's own — something the client can no longer read once
    // classes/{classId} read is restricted to `isPublic == true ||
    // teacherUid == uid`. The Cloud Function runs the same scan via the
    // Admin SDK.
    final callable = _functions.httpsCallable('generateUniqueJoinCode');
    final result = await callable.call<Map<String, dynamic>>();
    return result.data['code'] as String;
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

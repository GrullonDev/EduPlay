// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:edu_play/features/practice_session/models/practice_session.dart';

abstract class PracticeSessionsDatasource {
  Future<List<PracticeSession>> getAllSessions();

  Future<List<PracticeSession>> getActiveSessions();

  Stream<List<PracticeSession>> watchCompletedSessions();

  Stream<List<PracticeSession>> watchActiveSessions();

  Future<List<PracticeSession>> getActiveSessionsByChildId(
    String childProfileId,
  );

  Stream<List<PracticeSession>> watchAllSessionsByChild(String childProfileId);

  Future<PracticeSession?> findByPin(String pin);

  Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  });

  Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  });

  Future<void> endSession(String sessionId);

  Future<void> deleteSession(String sessionId);
}

class FirestorePracticeSessionsDatasource
    implements PracticeSessionsDatasource {
  FirestorePracticeSessionsDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('practice_sessions');

  PracticeSession _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    final raw = data['createdAt'];
    if (raw is Timestamp) {
      data['createdAt'] = raw.toDate().toIso8601String();
    } else if (raw == null) {
      data['createdAt'] = DateTime.now().toIso8601String();
    }
    data['id'] = doc.id;
    return PracticeSession.fromJson(data);
  }

  @override
  Future<List<PracticeSession>> getAllSessions() async {
    final uid = _uid;
    if (uid == null) return [];
    // Called on every student dashboard load (via progress recommendations)
    // — guard against a stalled gRPC channel hanging the caller forever.
    try {
      final snap = await _col
          .where('parentUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 8));
      return snap.docs.map(_fromDoc).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PracticeSession>> getActiveSessions() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _col
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<PracticeSession>> watchCompletedSessions() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Stream<List<PracticeSession>> watchActiveSessions() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<List<PracticeSession>> getActiveSessionsByChildId(
    String childProfileId,
  ) async {
    final snap = await _col
        .where('childProfileId', isEqualTo: childProfileId)
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Stream<List<PracticeSession>> watchAllSessionsByChild(String childProfileId) {
    return _col
        .where('childProfileId', isEqualTo: childProfileId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  @override
  Future<PracticeSession?> findByPin(String pin) async {
    final snap = await _col
        .where('pin', isEqualTo: pin)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromDoc(snap.docs.first);
  }

  @override
  Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  }) async {
    String pin;
    do {
      pin = PracticeSession.generatePin();
      final existing = await _col
          .where('pin', isEqualTo: pin)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) break;
    } while (true);

    final docRef = _col.doc();
    final now = DateTime.now();
    final session = PracticeSession(
      id: docRef.id,
      childProfileId: childProfileId,
      childName: childName,
      pin: pin,
      assignedGameIds: assignedGameIds,
      createdAt: now,
    );

    await docRef.set({
      ...session.toJson(),
      'parentUid': _uid,
      'createdAt': now.toIso8601String(),
    });

    return session;
  }

  @override
  Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  }) async {
    await _col.doc(sessionId).update({
      'completedGameIds': FieldValue.arrayUnion([gameId]),
      'scoreMap.$gameId': score,
    });
  }

  @override
  Future<void> endSession(String sessionId) async {
    await _col.doc(sessionId).update({'isActive': false});
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await _col.doc(sessionId).delete();
  }
}

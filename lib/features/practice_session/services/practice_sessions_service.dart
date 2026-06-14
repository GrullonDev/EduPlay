import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/features/practice_session/models/practice_session.dart';

/// Firestore-backed service for practice sessions.
///
/// Schema: top-level collection `practice_sessions/{sessionId}`
/// Each document carries a `parentUid` field so the parent can query their
/// own sessions, and children can look up sessions by PIN without needing
/// to be authenticated (they only supply the 6-digit PIN).
///
/// Firestore composite indexes required (create once in Firebase console):
///   • practice_sessions: parentUid ASC + isActive ASC
///   • practice_sessions: pin ASC    + isActive ASC
class PracticeSessionsService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;
  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('practice_sessions');

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts a Firestore document to a [PracticeSession].
  /// Handles the case where `createdAt` may be a Firestore [Timestamp].
  static PracticeSession _fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    final raw = data['createdAt'];
    if (raw is Timestamp) {
      data['createdAt'] = raw.toDate().toIso8601String();
    } else if (raw == null) {
      data['createdAt'] = DateTime.now().toIso8601String();
    }
    data['id'] = doc.id; // canonical id = Firestore document id
    return PracticeSession.fromJson(data);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<List<PracticeSession>> getAllSessions() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _col
        .where('parentUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  static Future<List<PracticeSession>> getActiveSessions() async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _col
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  /// Real-time stream of this parent's active sessions.
  /// Use with [StreamBuilder] in the dashboard for live score updates.
  static Stream<List<PracticeSession>> watchActiveSessions() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _col
        .where('parentUid', isEqualTo: uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  /// Looks up a session by 6-digit PIN — called from the child entry page.
  /// Does NOT require authentication.
  static Future<PracticeSession?> findByPin(String pin) async {
    final snap = await _col
        .where('pin', isEqualTo: pin)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return _fromDoc(snap.docs.first);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<PracticeSession> createSession({
    required String childProfileId,
    required String childName,
    required List<String> assignedGameIds,
  }) async {
    // Pick a PIN that isn't already active
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

  /// Called by the kiosk when the child finishes a game.
  /// Atomically appends the game to the completed list and records the score.
  static Future<void> recordGameCompletion(
    String sessionId,
    String gameId, {
    int score = 100,
  }) async {
    await _col.doc(sessionId).update({
      'completedGameIds': FieldValue.arrayUnion([gameId]),
      'scoreMap.$gameId': score,
    });
  }

  /// Marks a session inactive (parent taps "End").
  static Future<void> endSession(String sessionId) async {
    await _col.doc(sessionId).update({'isActive': false});
  }

  static Future<void> deleteSession(String sessionId) async {
    await _col.doc(sessionId).delete();
  }
}

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:edu_play/features/friends/models/friend_identity.dart';
import 'package:edu_play/features/friends/models/friend_request.dart';

/// Firestore-backed friends/connections for students, parents and teachers.
///
/// Uses two top-level collections:
///  - `friend_codes/{code}` — a short shareable code → owner identity, so
///    users can add each other without a public directory search.
///  - `friend_requests/{id}` — pending/accepted/rejected connections between
///    two identities, keyed by a `participantUids` array for querying.
class FriendsService {
  const FriendsService._();

  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _codes =>
      _db.collection('friend_codes');

  static CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection('friend_requests');

  static const _codeChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  static String _generateCode() {
    final rng = Random();
    return List.generate(6, (_) => _codeChars[rng.nextInt(_codeChars.length)])
        .join();
  }

  /// Returns the existing friend code for [me], or creates a new one.
  static Future<String> getOrCreateMyCode(FriendIdentity me) async {
    final existing = await _codes
        .where('ownerUid', isEqualTo: me.uid)
        .where('childId', isEqualTo: me.childId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return existing.docs.first.id;
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      final code = _generateCode();
      final doc = _codes.doc(code);
      final snap = await doc.get();
      if (snap.exists) continue;
      await doc.set({
        'ownerUid': me.uid,
        'childId': me.childId,
        'role': me.role,
        'displayName': me.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return code;
    }
    throw Exception('No se pudo generar un código de amigo. Intenta de nuevo.');
  }

  /// Sends a friend request from [me] to whoever owns [code].
  static Future<void> sendRequestByCode({
    required FriendIdentity me,
    required String code,
  }) async {
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw Exception('Ingresa un código de amigo.');
    }

    final doc = await _codes.doc(normalized).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      throw Exception('Código no encontrado. Verifícalo con tu amigo.');
    }

    final toUid = data['ownerUid'] as String;
    final toChildId = data['childId'] as String?;
    final toRole = data['role'] as String? ?? 'parent';
    final toName = data['displayName'] as String? ?? 'Usuario';
    final toKey = FriendIdentity.keyFor(
      uid: toUid,
      role: toRole,
      childId: toChildId,
    );

    if (toKey == me.key) {
      throw Exception('No puedes agregarte a ti mismo.');
    }

    final mine =
        await _requests.where('participantUids', arrayContains: me.uid).get();
    final alreadyConnected = mine.docs.map((d) {
      return FriendRequestModel.fromMap(d.data(), d.id);
    }).any((r) {
      final involvesUs = (r.fromKey == me.key || r.toKey == me.key) &&
          (r.fromKey == toKey || r.toKey == toKey);
      return involvesUs && (r.status == 'pending' || r.status == 'accepted');
    });
    if (alreadyConnected) {
      throw Exception('Ya existe una solicitud o amistad con este código.');
    }

    final request = FriendRequestModel(
      id: '',
      fromUid: me.uid,
      fromChildId: me.childId,
      fromRole: me.role,
      fromName: me.name,
      toUid: toUid,
      toChildId: toChildId,
      toRole: toRole,
      toName: toName,
      status: 'pending',
      createdAt: DateTime.now(),
      viaCode: normalized,
    );
    await _requests.add(request.toMap());
  }

  /// Pending requests sent *to* [me].
  static Stream<List<FriendRequestModel>> watchIncomingRequests(
    FriendIdentity me,
  ) {
    return _requests
        .where('participantUids', arrayContains: me.uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => FriendRequestModel.fromMap(d.data(), d.id))
          .where((r) => r.status == 'pending' && r.toKey == me.key)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Accepted connections involving [me].
  static Stream<List<FriendRequestModel>> watchFriends(FriendIdentity me) {
    return _requests
        .where('participantUids', arrayContains: me.uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => FriendRequestModel.fromMap(d.data(), d.id))
          .where((r) =>
              r.status == 'accepted' && (r.fromKey == me.key || r.toKey == me.key))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  static Future<void> respondToRequest(
    String requestId, {
    required bool accept,
  }) async {
    await _requests.doc(requestId).update({
      'status': accept ? 'accepted' : 'rejected',
      'respondedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Removes a connection or cancels/dismisses a request.
  static Future<void> removeRequest(String requestId) async {
    await _requests.doc(requestId).delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

abstract class ChildProfilesDatasource {
  Future<List<ChildProfile>> getProfiles();

  Future<ChildProfile?> findByPin(String pin);

  Future<ChildProfile?> findByPinGlobal(String pin);

  Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  });

  Future<void> deleteProfile(String id, {String? pin});

  Future<void> updateProfile(ChildProfile updated);

  Future<String> getParentName();

  Future<void> setParentName(String name);
}

/// Firestore-backed persistence for child profiles.
///
/// Schema:
/// `parents/{uid}/child_profiles/{profileId}` stores parent-scoped profiles.
/// `child_pins/{pin}` is a global PIN index so children can resolve their
/// profile without knowing the parent's UID.
class FirestoreChildProfilesDatasource implements ChildProfilesDatasource {
  FirestoreChildProfilesDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> _profilesRef(String uid) =>
      _firestore.collection('parents').doc(uid).collection('child_profiles');

  CollectionReference<Map<String, dynamic>> get _pinsRef =>
      _firestore.collection('child_pins');

  @override
  Future<List<ChildProfile>> getProfiles() async {
    final uid = _uid;
    if (uid == null) return [];

    final snapshot = await _profilesRef(uid).get();
    return snapshot.docs
        .map((doc) => ChildProfile.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<ChildProfile?> findByPin(String pin) async {
    final uid = _uid;
    if (uid == null) return null;

    final snapshot =
        await _profilesRef(uid).where('pin', isEqualTo: pin).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return ChildProfile.fromJson(snapshot.docs.first.data());
  }

  @override
  Future<ChildProfile?> findByPinGlobal(String pin) async {
    // Let failures (offline, permission-denied) propagate instead of
    // masquerading as "PIN not found" — callers need to tell a transient
    // error apart from a genuinely unknown PIN so they don't forget a valid
    // child session over a network blip.
    // Timeout: a stalled gRPC channel right after a fresh anonymous sign-in
    // can leave this Future pending forever instead of throwing, which would
    // otherwise hang the caller's loading state indefinitely.
    final doc =
        await _pinsRef.doc(pin).get().timeout(const Duration(seconds: 8));
    if (!doc.exists) return null;
    return ChildProfile.fromJson(doc.data()!);
  }

  @override
  Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  }) async {
    final uid = _uid;

    String pin;
    final usedPins = (await getProfiles()).map((p) => p.pin).toSet();
    do {
      pin = ChildProfile.generatePin();
    } while (usedPins.contains(pin));

    final docRef = uid != null
        ? _profilesRef(uid).doc()
        : _firestore.collection('_tmp').doc();

    final profile = ChildProfile(
      id: docRef.id,
      name: name,
      age: age,
      level: 1,
      pin: pin,
      focusSubject: focusSubject,
      levelProgress: 0.0,
      avatarColorHex: ChildProfile.avatarColorForIndex(existingCount),
    );

    if (uid != null) {
      final data = profile.toJson();
      await _profilesRef(uid).doc(docRef.id).set(data);
      await _pinsRef.doc(pin).set({...data, 'parentUid': uid});
      await _firestore.collection('students').doc(docRef.id).set({
        'name': name,
        'age': age,
        'avatar': 'lion',
        'points': 0,
        'streak': 0,
        'lastPlayedDate': null,
        'childProfileId': docRef.id,
        'focusSubject': focusSubject,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return profile;
  }

  @override
  Future<void> deleteProfile(String id, {String? pin}) async {
    final uid = _uid;
    if (uid == null) return;

    await _profilesRef(uid).doc(id).delete();
    if (pin != null) {
      await _pinsRef.doc(pin).delete();
    }
  }

  @override
  Future<void> updateProfile(ChildProfile updated) async {
    final uid = _uid;
    if (uid == null) return;

    final data = updated.toJson();
    await _profilesRef(uid).doc(updated.id).update(data);
    await _pinsRef.doc(updated.pin).update({...data, 'parentUid': uid});
    await _firestore.collection('students').doc(updated.id).set({
      'name': updated.name,
      'age': updated.age,
      'childProfileId': updated.id,
      'focusSubject': updated.focusSubject,
    }, SetOptions(merge: true));
  }

  @override
  Future<String> getParentName() async {
    final uid = _uid;
    if (uid == null) return 'MamÃ¡';

    final doc = await _firestore.collection('parents').doc(uid).get();
    if (!doc.exists) return 'MamÃ¡';
    return (doc.data()?['firstName'] as String?) ?? 'MamÃ¡';
  }

  @override
  Future<void> setParentName(String name) async {
    final uid = _uid;
    if (uid == null) return;

    await _firestore.collection('parents').doc(uid).update({'firstName': name});
  }
}

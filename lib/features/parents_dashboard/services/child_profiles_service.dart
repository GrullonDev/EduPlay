import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

/// Firestore-backed persistence for child profiles.
///
/// Schema: `parents/{uid}/child_profiles/{profileId}`
///
/// Falls back gracefully when the user is not authenticated (returns empty
/// lists / no-ops), so pages that call these methods before login won't crash.
class ChildProfilesService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _profilesRef(String uid) =>
      _db.collection('parents').doc(uid).collection('child_profiles');

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<List<ChildProfile>> getProfiles() async {
    final uid = _uid;
    if (uid == null) return [];
    final snapshot = await _profilesRef(uid).get();
    return snapshot.docs
        .map((doc) => ChildProfile.fromJson(doc.data()))
        .toList();
  }

  static Future<ChildProfile?> findByPin(String pin) async {
    final uid = _uid;
    if (uid == null) return null;
    final snapshot = await _profilesRef(uid)
        .where('pin', isEqualTo: pin)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return ChildProfile.fromJson(snapshot.docs.first.data());
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  }) async {
    final uid = _uid;
    // Generate a PIN that's unique among this parent's profiles
    String pin;
    final usedPins = (await getProfiles()).map((p) => p.pin).toSet();
    do {
      pin = ChildProfile.generatePin();
    } while (usedPins.contains(pin));

    final docRef = uid != null
        ? _profilesRef(uid).doc()
        : _db.collection('_tmp').doc(); // fallback id (should never happen)

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
      await _profilesRef(uid).doc(docRef.id).set(profile.toJson());
    }
    return profile;
  }

  static Future<void> deleteProfile(String id) async {
    final uid = _uid;
    if (uid == null) return;
    await _profilesRef(uid).doc(id).delete();
  }

  static Future<void> updateProfile(ChildProfile updated) async {
    final uid = _uid;
    if (uid == null) return;
    await _profilesRef(uid).doc(updated.id).update(updated.toJson());
  }

  // ── Parent display name ───────────────────────────────────────────────────

  static Future<String> getParentName() async {
    final uid = _uid;
    if (uid == null) return 'Mamá';
    final doc = await _db.collection('parents').doc(uid).get();
    if (!doc.exists) return 'Mamá';
    return (doc.data()?['firstName'] as String?) ?? 'Mamá';
  }

  static Future<void> setParentName(String name) async {
    final uid = _uid;
    if (uid == null) return;
    await _db.collection('parents').doc(uid).update({'firstName': name});
  }
}

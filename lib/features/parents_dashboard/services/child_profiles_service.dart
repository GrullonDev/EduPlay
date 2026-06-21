import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

/// Firestore-backed persistence for child profiles.
///
/// Schema:
///   `parents/{uid}/child_profiles/{profileId}` — parent-scoped profiles.
///   `child_pins/{pin}`                          — global PIN index so children
///       can look up their profile without knowing the parent's UID.
///
/// The global index mirrors every profile field plus a `parentUid` field.
///
/// Required Firestore security rules for child_pins:
///   match /child_pins/{pin} {
///     allow read:  if request.auth != null;          // anonymous auth is fine
///     allow write: if request.auth.uid == request.resource.data.parentUid
///                  || request.auth.uid == resource.data.parentUid;
///   }
///
/// Falls back gracefully when the user is not authenticated (returns empty
/// lists / no-ops), so pages that call these methods before login won't crash.
class ChildProfilesService {
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static CollectionReference<Map<String, dynamic>> _profilesRef(String uid) =>
      _db.collection('parents').doc(uid).collection('child_profiles');

  /// Top-level collection: PIN → profile data + parentUid.
  /// Allows children to resolve their profile without parent auth.
  static CollectionReference<Map<String, dynamic>> get _pinsRef =>
      _db.collection('child_pins');

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<List<ChildProfile>> getProfiles() async {
    final uid = _uid;
    if (uid == null) return [];
    final snapshot = await _profilesRef(uid).get();
    return snapshot.docs
        .map((doc) => ChildProfile.fromJson(doc.data()))
        .toList();
  }

  /// Look up a child profile by PIN using the parent-scoped collection.
  /// Requires the parent to be authenticated. Used by [ChildPinPage] on the
  /// parent's own device.
  static Future<ChildProfile?> findByPin(String pin) async {
    final uid = _uid;
    if (uid == null) return null;
    final snapshot =
        await _profilesRef(uid).where('pin', isEqualTo: pin).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return ChildProfile.fromJson(snapshot.docs.first.data());
  }

  /// Look up a child profile by PIN from the global [child_pins] index.
  ///
  /// Does **not** require the caller to be a parent — any authenticated user
  /// (including anonymous) can read from [child_pins]. Used by [ChildPortalPage]
  /// when the child opens the shared link on their own device.
  static Future<ChildProfile?> findByPinGlobal(String pin) async {
    try {
      final doc = await _pinsRef.doc(pin).get();
      if (!doc.exists) return null;
      return ChildProfile.fromJson(doc.data()!);
    } catch (_) {
      return null;
    }
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
      final data = profile.toJson();
      // Write to parent-scoped collection
      await _profilesRef(uid).doc(docRef.id).set(data);
      // Mirror to global PIN index so children can resolve without parent auth
      await _pinsRef.doc(pin).set({...data, 'parentUid': uid});
    }
    return profile;
  }

  /// Deletes a profile by ID and removes its entry from the global PIN index.
  /// Pass [pin] (from the profile object) so the index document can be cleaned up.
  static Future<void> deleteProfile(String id, {String? pin}) async {
    final uid = _uid;
    if (uid == null) return;
    await _profilesRef(uid).doc(id).delete();
    if (pin != null) {
      await _pinsRef.doc(pin).delete();
    }
  }

  static Future<void> updateProfile(ChildProfile updated) async {
    final uid = _uid;
    if (uid == null) return;
    final data = updated.toJson();
    await _profilesRef(uid).doc(updated.id).update(data);
    // Keep global index in sync
    await _pinsRef.doc(updated.pin).update({...data, 'parentUid': uid});
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

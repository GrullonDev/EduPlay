import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/settings/domain/entities/notification_preferences.dart';
import 'package:edu_play/features/settings/domain/entities/parent_settings_profile.dart';

abstract class SettingsDatasource {
  Future<ParentSettingsProfile?> getParentProfile();

  Future<void> updateParentProfile({
    required String firstName,
    required String lastName,
    required String age,
  });

  Future<NotificationPreferences> getNotificationPreferences();

  Future<void> updateNotificationPreferences(NotificationPreferences prefs);
}

class FirestoreSettingsDatasource implements SettingsDatasource {
  FirestoreSettingsDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _parentDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('parents').doc(uid);
  }

  @override
  Future<ParentSettingsProfile?> getParentProfile() async {
    final ref = _parentDoc;
    if (ref == null) return null;

    final doc = await ref.get();
    final data = doc.data() ?? {};
    return ParentSettingsProfile(
      firstName: (data['firstName'] as String?) ?? '',
      lastName: (data['lastName'] as String?) ?? '',
      email: (data['email'] as String?) ?? _auth.currentUser?.email ?? '',
      age: (data['age'] as String?) ?? '',
    );
  }

  @override
  Future<void> updateParentProfile({
    required String firstName,
    required String lastName,
    required String age,
  }) async {
    final ref = _parentDoc;
    if (ref == null) return;

    await ref.update({
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
    });
  }

  @override
  Future<NotificationPreferences> getNotificationPreferences() async {
    final ref = _parentDoc;
    if (ref == null) return const NotificationPreferences();

    final doc = await ref.get();
    final prefs = (doc.data()?['notificationPrefs'] as Map<String, dynamic>?) ??
        <String, dynamic>{};
    return NotificationPreferences.fromMap(prefs);
  }

  @override
  Future<void> updateNotificationPreferences(
      NotificationPreferences prefs) async {
    final ref = _parentDoc;
    if (ref == null) return;

    await ref.update({'notificationPrefs': prefs.toMap()});
  }
}

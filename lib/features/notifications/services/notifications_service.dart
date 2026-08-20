// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:edu_play/features/notifications/models/app_notification.dart';

class NotificationsService {
  const NotificationsService._();

  static FirebaseFirestore? _firestoreForTest;
  static FirebaseAuth? _authForTest;

  static FirebaseFirestore get _db =>
      _firestoreForTest ?? FirebaseFirestore.instance;
  static FirebaseAuth get _auth => _authForTest ?? FirebaseAuth.instance;

  @visibleForTesting
  static void useInstancesForTest({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) {
    _firestoreForTest = firestore;
    _authForTest = auth;
  }

  static CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection('notifications');

  static Stream<List<AppNotification>> watchMine({String? childId}) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const <AppNotification>[]);

    return _notifications
        .where('recipientUid', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final items = snap.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .where((n) => childId == null || n.recipientChildId == childId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  static Future<void> markRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'read': true});
  }

  static Future<void> markAllRead({String? childId}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snap = await _notifications
        .where('recipientUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      final data = doc.data();
      if (childId != null && data['recipientChildId'] != childId) continue;
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  /// Sends a message from a teacher to the parent of each given student,
  /// landing in that parent's existing notification bell. [students] entries
  /// must carry 'parentUid', 'classId' and 'memberId' (as built by
  /// TeacherDashboardBloc's roster) — these are cross-checked server-side
  /// against the class roster so a teacher can only message parents of
  /// students actually in one of their own classes.
  static Future<int> sendTeacherMessageToClass({
    required List<Map<String, dynamic>> students,
    required String senderName,
    required String title,
    required String body,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 0;

    final batch = _db.batch();
    var count = 0;
    for (final student in students) {
      final parentUid = student['parentUid'] as String?;
      final classId = student['classId'] as String?;
      final memberId = student['memberId'] as String?;
      if (parentUid == null || parentUid.isEmpty) continue;
      if (classId == null || classId.isEmpty) continue;
      if (memberId == null || memberId.isEmpty) continue;

      batch.set(_notifications.doc(), {
        'recipientUid': parentUid,
        'recipientRole': 'parent',
        'senderUid': uid,
        'senderRole': 'teacher',
        'senderName': senderName,
        'type': 'teacher_message',
        'title': title,
        'body': body,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'classId': classId,
        'memberId': memberId,
      });
      count++;
    }

    if (count > 0) await batch.commit();
    return count;
  }
}

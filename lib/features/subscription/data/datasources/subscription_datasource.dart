import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/subscription/models/subscription.dart';

abstract class SubscriptionDatasource {
  Future<Subscription> getSubscription();

  Future<Subscription> getSubscriptionForUser(String uid);

  Stream<Subscription> watchSubscription();

  Future<void> initSubscription(String uid);

  Future<void> incrementSessionCount();
}

class FirestoreSubscriptionDatasource implements SubscriptionDatasource {
  FirestoreSubscriptionDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('subscriptions').doc(uid);
  }

  @override
  Future<Subscription> getSubscription() async {
    final uid = _uid;
    if (uid == null) return Subscription.freeTier();
    return getSubscriptionForUser(uid);
  }

  @override
  Future<Subscription> getSubscriptionForUser(String uid) async {
    final snap = await _db.collection('subscriptions').doc(uid).get();
    if (!snap.exists) return Subscription.freeTier();
    return Subscription.fromMap(snap.data()!);
  }

  @override
  Stream<Subscription> watchSubscription() {
    final ref = _doc;
    if (ref == null) return Stream.value(Subscription.freeTier());
    return ref.snapshots().map(
          (snap) => snap.exists
              ? Subscription.fromMap(snap.data()!)
              : Subscription.freeTier(),
        );
  }

  @override
  Future<void> initSubscription(String uid) async {
    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await _db.collection('subscriptions').doc(uid).set({
      'tier': 'free',
      'sessionsThisMonth': 0,
      'monthYear': monthYear,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> incrementSessionCount() async {
    final ref = _doc;
    if (ref == null) return;

    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final snap = await ref.get();
    if (!snap.exists) return;

    final storedMonth = (snap.data()?['monthYear'] as String?) ?? '';

    if (storedMonth != currentMonth) {
      await ref.update({
        'sessionsThisMonth': 1,
        'monthYear': currentMonth,
      });
    } else {
      await ref.update({
        'sessionsThisMonth': FieldValue.increment(1),
      });
    }
  }
}

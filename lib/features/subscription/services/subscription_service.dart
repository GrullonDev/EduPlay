import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/subscription/models/subscription.dart';

/// Manages subscription tier and free-tier usage counters in Firestore.
///
/// Firestore path: `subscriptions/{uid}`
///
/// Fields:
///   tier               – 'free' | 'pro'
///   sessionsThisMonth  – int, resets when [monthYear] changes
///   monthYear          – 'YYYY-MM', used to detect month roll-over
///   createdAt          – server timestamp (set once at registration)
class SubscriptionService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? get _doc {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('subscriptions').doc(uid);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Returns the current subscription, defaulting to free tier if no doc exists.
  static Future<Subscription> getSubscription() async {
    final ref = _doc;
    if (ref == null) return Subscription.freeTier();

    final snap = await ref.get();
    if (!snap.exists) return Subscription.freeTier();

    return Subscription.fromMap(snap.data()!);
  }

  /// Stream version — used by Settings page to react to changes.
  static Stream<Subscription> watchSubscription() {
    final ref = _doc;
    if (ref == null) return Stream.value(Subscription.freeTier());
    return ref.snapshots().map((snap) =>
        snap.exists ? Subscription.fromMap(snap.data()!) : Subscription.freeTier());
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Called once at parent registration to seed the subscription document.
  static Future<void> initSubscription(String uid) async {
    final now = DateTime.now();
    final monthYear =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await _db.collection('subscriptions').doc(uid).set({
      'tier': 'free',
      'sessionsThisMonth': 0,
      'monthYear': monthYear,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Increments the monthly session counter.  Resets the counter automatically
  /// if the stored [monthYear] is behind the current month.
  static Future<void> incrementSessionCount() async {
    final ref = _doc;
    if (ref == null) return;

    final now = DateTime.now();
    final currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final snap = await ref.get();
    if (!snap.exists) return;

    final storedMonth = (snap.data()?['monthYear'] as String?) ?? '';

    if (storedMonth != currentMonth) {
      // Month rolled over — reset counter.
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

  // ── Limit checks ──────────────────────────────────────────────────────────

  /// Returns true if the user can create another child profile.
  /// Pro users are always allowed. Free users are limited to [Subscription.freeChildLimit].
  static Future<bool> canAddChild(int currentChildCount) async {
    final sub = await getSubscription();
    if (sub.isPro) return true;
    return currentChildCount < Subscription.freeChildLimit;
  }

  /// Returns true if the user can create another practice session this month.
  static Future<bool> canCreateSession() async {
    final sub = await getSubscription();
    if (sub.isPro) return true;

    final now = DateTime.now();
    final currentMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Reset check: if month changed, count is effectively 0.
    if (sub.monthYear != currentMonth) return true;

    return sub.sessionsThisMonth < Subscription.freeSessionLimit;
  }
}

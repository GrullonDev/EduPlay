// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';

abstract class AdminDashboardDatasource {
  Future<PlatformStats?> loadStats();
  Future<bool> setAdminRoleByEmail({
    required String email,
    required bool granting,
  });
}

class FirestoreAdminDashboardDatasource implements AdminDashboardDatasource {
  FirestoreAdminDashboardDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<PlatformStats?> loadStats() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final parentSnap =
        await _firestore.collection('parents').doc(user.uid).get();
    if (parentSnap.data()?['role'] != 'admin') return null;

    final results = await Future.wait([
      _firestore.collection('parents').count().get(),
      _firestore.collection('practice_sessions').count().get(),
      _firestore.collection('classes').count().get(),
      _firestore
          .collection('subscriptions')
          .where('tier', isEqualTo: 'pro')
          .count()
          .get(),
    ]);

    final parentsSnap = await _firestore.collection('parents').get();
    var childCount = 0;
    for (final doc in parentsSnap.docs) {
      final childSnap =
          await doc.reference.collection('child_profiles').count().get();
      childCount += childSnap.count ?? 0;
    }

    return PlatformStats(
      totalParents: results[0].count ?? 0,
      totalSessions: results[1].count ?? 0,
      totalClasses: results[2].count ?? 0,
      proSubscribers: results[3].count ?? 0,
      totalChildren: childCount,
    );
  }

  /// Dead by design: `firestore.rules` now blocks any client update to
  /// `role` on `parents/{uid}` (previously any signed-in parent could grant
  /// themselves admin by writing that field directly, e.g. from a browser
  /// console). This call will always throw permission-denied. Granting
  /// admin today means editing the field directly in the Firebase Console
  /// (which uses the Admin SDK and bypasses rules) — there is intentionally
  /// no in-app path until a properly-authorized server-side one (e.g. a
  /// callable Cloud Function restricted to existing admins) replaces it.
  @override
  Future<bool> setAdminRoleByEmail({
    required String email,
    required bool granting,
  }) async {
    final snap = await _firestore
        .collection('parents')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return false;
    await snap.docs.first.reference.update({
      'role': granting ? 'admin' : 'parent',
    });
    return true;
  }
}

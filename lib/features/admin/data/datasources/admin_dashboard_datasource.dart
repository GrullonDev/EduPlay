// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
import 'package:edu_play/features/admin/domain/entities/platform_stats.dart';
import 'package:edu_play/features/teacher_dashboard/domain/entities/teacher_class.dart';

abstract class AdminDashboardDatasource {
  Future<PlatformStats?> loadStats();
  Future<List<TeacherClass>> listAllClasses();
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

  @override
  Future<List<TeacherClass>> listAllClasses() async {
    final snap = await _firestore
        .collection('classes')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs
        .map((doc) => TeacherClass.fromMap(doc.data(), doc.id))
        .toList();
  }
}

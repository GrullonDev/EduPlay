import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/parents_dashboard/models/parent_quick_controls.dart';

abstract class ParentDashboardDatasource {
  Future<ParentQuickControls> getQuickControls();

  Future<void> saveQuickControls(ParentQuickControls controls);
}

class FirestoreParentDashboardDatasource implements ParentDashboardDatasource {
  FirestoreParentDashboardDatasource({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _parentRef(String uid) {
    return _firestore.collection('parents').doc(uid);
  }

  @override
  Future<ParentQuickControls> getQuickControls() async {
    final uid = _uid;
    if (uid == null) return const ParentQuickControls();

    final doc = await _parentRef(uid).get();
    return ParentQuickControls.fromJson(doc.data() ?? {});
  }

  @override
  Future<void> saveQuickControls(ParentQuickControls controls) async {
    final uid = _uid;
    if (uid == null) return;

    await _parentRef(uid).set(controls.toJson(), SetOptions(merge: true));
  }
}

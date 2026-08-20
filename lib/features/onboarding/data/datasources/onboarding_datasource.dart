// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class OnboardingDatasource {
  Future<bool> shouldShowForCurrentParent();
  Future<void> markCurrentParentComplete();
}

class FirestoreOnboardingDatasource implements OnboardingDatasource {
  FirestoreOnboardingDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<bool> shouldShowForCurrentParent() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore.collection('parents').doc(uid).get();
    return !(doc.data()?['onboardingComplete'] as bool? ?? false);
  }

  @override
  Future<void> markCurrentParentComplete() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore
        .collection('parents')
        .doc(uid)
        .update({'onboardingComplete': true});
  }
}

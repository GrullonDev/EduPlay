import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/settings/domain/entities/account_security_info.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';

abstract class AccountSecurityDatasource {
  AccountSecurityInfo? getCurrentAccount();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();

  Future<void> deleteAccount({required String password});
}

class FirebaseAccountSecurityDatasource implements AccountSecurityDatasource {
  FirebaseAccountSecurityDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get _user => _auth.currentUser;

  @override
  AccountSecurityInfo? getCurrentAccount() {
    final user = _user;
    if (user == null) return null;

    final providers = user.providerData.map((p) => p.providerId).toList();
    final providerLabel = providers.contains('google.com')
        ? 'Google'
        : providers.contains('microsoft.com')
            ? 'Microsoft'
            : 'Correo electronico';

    return AccountSecurityInfo(
      email: user.email ?? '',
      providerLabel: providerLabel,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AccountSecurityException(e.code, e.message);
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    final user = _requireUser();
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;
      final profilesSnap = await _firestore
          .collection('parents')
          .doc(uid)
          .collection('child_profiles')
          .get();
      for (final doc in profilesSnap.docs) {
        final pin = doc.data()['pin'] as String?;
        if (pin != null) {
          try {
            await _firestore.collection('child_pins').doc(pin).delete();
          } catch (_) {}
        }
        await doc.reference.delete();
      }

      final sessionsSnap = await _firestore
          .collection('practice_sessions')
          .where('parentUid', isEqualTo: uid)
          .get();
      for (final doc in sessionsSnap.docs) {
        await doc.reference.delete();
      }

      final challengesSnap = await _firestore
          .collection('parents')
          .doc(uid)
          .collection('challenges')
          .get();
      for (final doc in challengesSnap.docs) {
        await doc.reference.delete();
      }

      await _firestore.collection('parents').doc(uid).delete();
      await _firestore.collection('subscriptions').doc(uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AccountSecurityException(e.code, e.message);
    }
  }

  User _requireUser() {
    final user = _user;
    if (user == null) {
      throw const AccountSecurityException('no-current-user');
    }
    return user;
  }
}

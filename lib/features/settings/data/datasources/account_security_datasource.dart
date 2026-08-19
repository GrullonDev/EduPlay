import 'dart:math';

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

  Future<String?> getGuardianEmailOnFile();

  Future<void> requestDeletionWithGuardianConsent({required String password});
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
        // The child's actual gameplay record (points, streak, per-game
        // score history) lives in a separate top-level `students/{id}`
        // doc, keyed by the same profile id — deleting only the profile
        // left this orphaned, which meant a parent deleting their account
        // didn't actually erase their children's data.
        try {
          final studentDoc = _firestore.collection('students').doc(doc.id);
          final scoresSnap = await studentDoc.collection('scores').get();
          for (final scoreDoc in scoresSnap.docs) {
            await scoreDoc.reference.delete();
          }
          await studentDoc.delete();
        } catch (_) {}
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
      // No-op for a parent account (doc never existed); actually deletes the
      // role marker for an independent student calling this same method.
      await _firestore.collection('independent_students').doc(uid).delete();
      await _firestore.collection('subscriptions').doc(uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AccountSecurityException(e.code, e.message);
    }
  }

  @override
  Future<String?> getGuardianEmailOnFile() async {
    final uid = _user?.uid;
    if (uid == null) return null;
    final doc =
        await _firestore.collection('independent_students').doc(uid).get();
    final email = doc.data()?['guardianEmail'] as String?;
    return (email == null || email.isEmpty) ? null : email;
  }

  @override
  Future<void> requestDeletionWithGuardianConsent({
    required String password,
  }) async {
    final user = _requireUser();
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;
      final studentDoc =
          await _firestore.collection('independent_students').doc(uid).get();
      final guardianEmail = studentDoc.data()?['guardianEmail'] as String?;
      if (guardianEmail == null || guardianEmail.isEmpty) {
        throw const AccountSecurityException('no-guardian-email');
      }

      await _firestore.collection('deletion_requests').add({
        'uid': uid,
        'studentName': studentDoc.data()?['name'] ?? 'Estudiante',
        'guardianEmail': guardianEmail,
        'status': 'pending',
        'token': _generateToken(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw AccountSecurityException(e.code, e.message);
    }
  }

  /// A 128-bit random hex token embedded in the guardian's approve/deny
  /// email links — required (alongside the request id) before the Cloud
  /// Function that resolves the request will act on it, so the link can't
  /// be guessed from the request id alone.
  String _generateToken() {
    final random = Random.secure();
    return List.generate(32, (_) => random.nextInt(16).toRadixString(16))
        .join();
  }

  User _requireUser() {
    final user = _user;
    if (user == null) {
      throw const AccountSecurityException('no-current-user');
    }
    return user;
  }
}

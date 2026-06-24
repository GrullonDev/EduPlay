import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/features/subscription/services/subscription_service.dart';

abstract class AuthDatasource {
  Future<User?> registerParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required List<String> children,
  });

  Future<User?> loginParent({
    required String email,
    required String password,
  });

  Future<bool> isChildRegistered(String name);
  Future<void> registerChild(String name, String age);

  Future<void> logout();

  User? getCurrentUser();
}

class ImplAuthDatasource implements AuthDatasource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<User?> registerParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required List<String> children,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('parents').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'age': age,
          'children': children,
          'role': 'parent', // used by AuthGate to route back after reload
          'onboardingComplete':
              false, // triggers wizard on first dashboard visit
          'notificationPrefs': {
            'emailSessionComplete': true,
            'emailWeeklyDigest': true,
            'emailTips': false,
            'emailNewFeatures': true,
          },
        });
        // Seed subscription document (free tier).
        await SubscriptionService.initSubscription(user.uid);
        // Send verification email immediately after account creation.
        // Deliverability note: Firebase sends from noreply@<project>.firebaseapp.com.
        // For better inbox placement, configure a custom sender domain in
        // Firebase Console → Authentication → Templates → Customize action URL.
        await user.sendEmailVerification();
      }

      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error: $e');
      return null;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  @override
  Future<bool> isChildRegistered(String name) async {
    final QuerySnapshot result = await _firestore
        .collection('parents')
        .where('children', arrayContains: name)
        .get();

    return result.docs.isNotEmpty;
  }

  @override
  Future<void> registerChild(String name, String age) async {
    await _firestore.collection('children').add({
      'name': name,
      'age': age,
    });
  }

  @override
  Future<User?> loginParent({
    required String email,
    required String password,
  }) async {
    // Do NOT catch FirebaseAuthException here — rethrow it so the caller
    // can differentiate error codes (wrong-password, user-not-found, etc.)
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException {
      rethrow; // let LoginBloc handle specific codes
    } catch (e) {
      debugPrint('loginParent unexpected error: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}

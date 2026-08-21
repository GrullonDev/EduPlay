// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /// Self-registration for a teen (15+) who does not have a parent account.
  /// Creates a Firebase user and an `independent_students/{uid}` role doc —
  /// distinct from `parents/{uid}` so [AuthGate] routes them to their own
  /// student dashboard instead of a parent dashboard. The gameplay child
  /// profile (PIN, avatar, etc.) is created separately by the caller via
  /// `ChildProfilesService.addProfile`, reusing the same mechanism parents
  /// use to add a child.
  Future<User?> registerIndependentStudent({
    required String email,
    required String password,
    required String name,
    required int age,
    String? guardianEmail,
  });

  Future<bool> isChildRegistered(String name);
  Future<void> registerChild(String name, String age);

  Future<void> logout();

  User? getCurrentUser();
  String? getCurrentUserUid();
  String? getCurrentUserEmail();
  String? getCurrentUserDisplayName();
  bool isCurrentUserAnonymous();
  bool isCurrentUserEmailVerified();
  Future<void> reloadCurrentUser();
  Future<void> sendCurrentUserEmailVerification();
  Future<bool> ensureAnonymousAuth({Duration timeout});
  Future<void> setSessionPersistence({required bool rememberSession});
  Future<void> sendPasswordResetEmail(String email);
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
        await _initSubscription(user.uid);
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
  Future<User?> registerIndependentStudent({
    required String email,
    required String password,
    required String name,
    required int age,
    String? guardianEmail,
  }) async {
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection('independent_students').doc(user.uid).set({
          'name': name,
          'email': email,
          'age': age,
          'role': 'independent_student', // used by AuthGate to route back after reload
          // Optional, self-reported — the only way an independent student
          // (no parent account on file) can be offered a parental-consent
          // step before deleting their own account. Absent means account
          // deletion is immediate/self-serve, same as before.
          if (guardianEmail != null && guardianEmail.isNotEmpty)
            'guardianEmail': guardianEmail,
          'onboardingComplete': false,
          'notificationPrefs': {
            'emailSessionComplete': true,
            'emailWeeklyDigest': true,
            'emailTips': false,
            'emailNewFeatures': true,
          },
        });
        await _initSubscription(user.uid);
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

  Future<void> _initSubscription(String uid) async {
    final now = DateTime.now();
    final monthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    await _firestore.collection('subscriptions').doc(uid).set({
      'tier': 'free',
      'sessionsThisMonth': 0,
      'monthYear': monthYear,
      'createdAt': FieldValue.serverTimestamp(),
    });
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
      // Sign out any existing session (e.g. an anonymous guest session from
      // the child portal) before signing in with credentials. Without this,
      // Firebase does not reliably replace an active anonymous session and the
      // auth state may not update correctly.
      await _firebaseAuth.signOut();

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

  @override
  String? getCurrentUserUid() => _firebaseAuth.currentUser?.uid;

  @override
  String? getCurrentUserEmail() => _firebaseAuth.currentUser?.email;

  @override
  String? getCurrentUserDisplayName() => _firebaseAuth.currentUser?.displayName;

  @override
  bool isCurrentUserAnonymous() =>
      _firebaseAuth.currentUser?.isAnonymous ?? false;

  @override
  bool isCurrentUserEmailVerified() =>
      _firebaseAuth.currentUser?.emailVerified ?? false;

  @override
  Future<void> reloadCurrentUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  @override
  Future<void> sendCurrentUserEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }

  @override
  Future<bool> ensureAnonymousAuth(
      {Duration timeout = const Duration(seconds: 8)}) async {
    if (_firebaseAuth.currentUser != null) return true;
    // A single transient failure (brief connectivity blip, cold start) would
    // otherwise be treated as a hard sign-in failure and drop the child into
    // guest mode. Retry once before giving up.
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        await _firebaseAuth.signInAnonymously().timeout(timeout);
        return true;
      } catch (e) {
        debugPrint('ensureAnonymousAuth attempt $attempt failed: $e');
        if (attempt == 0) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    return false;
  }

  @override
  Future<void> setSessionPersistence({required bool rememberSession}) {
    return _firebaseAuth.setPersistence(
      rememberSession ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
        });
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
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error: $e');
      return null;
    } catch (e) {
      debugPrint('Error: $e');
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

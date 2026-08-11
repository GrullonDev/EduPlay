import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class TeacherRegistrationDatasource {
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String schoolName,
  });
}

class FirebaseTeacherRegistrationDatasource
    implements TeacherRegistrationDatasource {
  FirebaseTeacherRegistrationDatasource({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> registerTeacher({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String schoolName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('No user returned');

    await _firestore.collection('teachers').doc(user.uid).set({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'schoolName': schoolName,
      'role': 'teacher',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await user.sendEmailVerification();
  }
}

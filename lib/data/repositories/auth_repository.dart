import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/data/datasources/auth_datasource.dart';

abstract class AuthRepository {
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

class ImplAuthRepository implements AuthRepository {
  final AuthDatasource _authDatasource;

  ImplAuthRepository({
    required AuthDatasource authDatasource,
  }) : _authDatasource = authDatasource;

  @override
  Future<User?> registerParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required List<String> children,
  }) {
    return _authDatasource.registerParent(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      age: age,
      children: children,
    );
  }

  Future<bool> isChildRegistered(String name) async {
    return await _authDatasource.isChildRegistered(name);
  }

  Future<void> registerChild(String name, String age) async {
    await _authDatasource.registerChild(name, age);
  }

  @override
  Future<User?> loginParent({
    required String email,
    required String password,
  }) {
    return _authDatasource.loginParent(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return _authDatasource.logout();
  }

  @override
  User? getCurrentUser() {
    return _authDatasource.getCurrentUser();
  }
}

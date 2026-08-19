// Package imports:
import 'package:firebase_auth/firebase_auth.dart';

// Project imports:
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

class ImplAuthRepository implements AuthRepository {
  ImplAuthRepository({
    required AuthDatasource authDatasource,
  }) : _authDatasource = authDatasource;
  final AuthDatasource _authDatasource;

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

  @override
  Future<User?> registerIndependentStudent({
    required String email,
    required String password,
    required String name,
    required int age,
    String? guardianEmail,
  }) {
    return _authDatasource.registerIndependentStudent(
      email: email,
      password: password,
      name: name,
      age: age,
      guardianEmail: guardianEmail,
    );
  }

  @override
  Future<bool> isChildRegistered(String name) async {
    return await _authDatasource.isChildRegistered(name);
  }

  @override
  Future<void> registerChild(String name, String age) async {
    await _authDatasource.registerChild(name, age);
  }

  @override
  Future<User?> loginParent({
    required String email,
    required String password,
  }) async {
    // Let FirebaseAuthException propagate so LoginBloc can show specific messages.
    return _authDatasource.loginParent(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return _authDatasource.logout();
  }

  @override
  User? getCurrentUser() {
    return _authDatasource.getCurrentUser();
  }

  @override
  String? getCurrentUserUid() => _authDatasource.getCurrentUserUid();

  @override
  String? getCurrentUserEmail() => _authDatasource.getCurrentUserEmail();

  @override
  String? getCurrentUserDisplayName() =>
      _authDatasource.getCurrentUserDisplayName();

  @override
  bool isCurrentUserAnonymous() => _authDatasource.isCurrentUserAnonymous();

  @override
  bool isCurrentUserEmailVerified() =>
      _authDatasource.isCurrentUserEmailVerified();

  @override
  Future<void> reloadCurrentUser() => _authDatasource.reloadCurrentUser();

  @override
  Future<void> sendCurrentUserEmailVerification() =>
      _authDatasource.sendCurrentUserEmailVerification();

  @override
  Future<bool> ensureAnonymousAuth({
    Duration timeout = const Duration(seconds: 8),
  }) {
    return _authDatasource.ensureAnonymousAuth(timeout: timeout);
  }

  @override
  Future<void> setSessionPersistence({required bool rememberSession}) {
    return _authDatasource.setSessionPersistence(
      rememberSession: rememberSession,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _authDatasource.sendPasswordResetEmail(email);
  }
}

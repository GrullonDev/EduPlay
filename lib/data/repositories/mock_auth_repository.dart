import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  // In-memory storage mock
  final Set<String> _registeredChildren = {};
  User? _currentUser;

  @override
  Future<User?> registerParent({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String age,
    required List<String> children,
  }) async {
    // Return a mock user
    _currentUser = MockUser(uid: 'mock_uid_$email', email: email);
    return _currentUser;
  }

  @override
  Future<User?> loginParent({
    required String email,
    required String password,
  }) async {
    // "Success" for any login attemp for now
    _currentUser = MockUser(uid: 'mock_uid_$email', email: email);
    return _currentUser;
  }

  @override
  Future<bool> isChildRegistered(String name) async {
    return _registeredChildren.contains(name);
  }

  @override
  Future<void> registerChild(String name, String age) async {
    _registeredChildren.add(name);
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  User? getCurrentUser() {
    return _currentUser;
  }
}

// Simple Mock User to satisfy the return type.
// We depend on Mockito or just create a minimal implementation if Mockito isn't in dependencies?
// Mockito is NOT in pubspec.yaml. I will create a minimal stub instead.
class MockUser implements User {
  MockUser({required this.uid, required this.email});

  @override
  final String uid;

  @override
  final String? email;

  // Implement required overrides with dummy data/errors for unused features
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

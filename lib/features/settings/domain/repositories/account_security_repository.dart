import 'package:edu_play/features/settings/domain/entities/account_security_info.dart';

class AccountSecurityException implements Exception {
  const AccountSecurityException(this.code, [this.message]);

  final String code;
  final String? message;
}

abstract class AccountSecurityRepository {
  AccountSecurityInfo? getCurrentAccount();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();

  Future<void> deleteAccount({required String password});
}

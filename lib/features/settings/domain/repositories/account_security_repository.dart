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

  /// The parent/guardian email an independent student optionally left on
  /// file at registration — null for parents (they have no guardian above
  /// them) and for independent students who skipped the field.
  Future<String?> getGuardianEmailOnFile();

  /// For an independent student who *does* have a guardian email on file:
  /// creates a pending deletion request instead of deleting immediately.
  /// A Cloud Function emails the guardian an approve/deny link; the account
  /// is only actually deleted if they approve. Still requires re-auth via
  /// [password] so a stranger with a stolen session can't spam requests.
  Future<void> requestDeletionWithGuardianConsent({required String password});
}

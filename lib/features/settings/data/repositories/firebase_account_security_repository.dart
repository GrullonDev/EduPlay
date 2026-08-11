import 'package:edu_play/features/settings/data/datasources/account_security_datasource.dart';
import 'package:edu_play/features/settings/domain/entities/account_security_info.dart';
import 'package:edu_play/features/settings/domain/repositories/account_security_repository.dart';

class FirebaseAccountSecurityRepository implements AccountSecurityRepository {
  const FirebaseAccountSecurityRepository({required this.datasource});

  final AccountSecurityDatasource datasource;

  @override
  AccountSecurityInfo? getCurrentAccount() {
    return datasource.getCurrentAccount();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return datasource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> signOut() {
    return datasource.signOut();
  }

  @override
  Future<void> deleteAccount({required String password}) {
    return datasource.deleteAccount(password: password);
  }
}

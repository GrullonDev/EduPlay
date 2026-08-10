class AccountSecurityInfo {
  const AccountSecurityInfo({
    required this.email,
    required this.providerLabel,
    required this.creationTime,
    required this.lastSignInTime,
    required this.emailVerified,
  });

  final String email;
  final String providerLabel;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;
  final bool emailVerified;
}

/// Represents a parent's subscription tier and usage for the current month.
class Subscription {
  factory Subscription.fromMap(Map<String, dynamic> map) => Subscription(
        tier: (map['tier'] as String?) ?? 'free',
        sessionsThisMonth: (map['sessionsThisMonth'] as int?) ?? 0,
        monthYear: (map['monthYear'] as String?) ?? '',
      );
  const Subscription({
    required this.tier,
    required this.sessionsThisMonth,
    required this.monthYear,
  });

  /// 'free' or 'pro'
  final String tier;

  /// Number of practice sessions created in [monthYear].
  final int sessionsThisMonth;

  /// ISO month string e.g. '2026-06'. Resets counter when month changes.
  final String monthYear;

  bool get isPro => tier == 'pro';

  // ── Free-tier limits ──────────────────────────────────────────────────────

  /// Maximum child profiles on the free plan.
  static const int freeChildLimit = 1;

  /// Maximum practice sessions per month on the free plan.
  static const int freeSessionLimit = 5;

  bool get childLimitReached =>
      !isPro; // checked separately against Firestore count
  bool get sessionLimitReached =>
      !isPro && sessionsThisMonth >= freeSessionLimit;

  static Subscription freeTier() => Subscription(
        tier: 'free',
        sessionsThisMonth: 0,
        monthYear: _currentMonthYear(),
      );

  static String _currentMonthYear() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }
}

/// How often [ParentQuickControls.spendLimitAmount] resets.
enum SpendLimitPeriod {
  daily,
  weekly;

  int get windowDays => this == SpendLimitPeriod.daily ? 1 : 7;

  static SpendLimitPeriod fromName(String? name) => SpendLimitPeriod.values
      .firstWhere((p) => p.name == name, orElse: () => SpendLimitPeriod.daily);
}

class ParentQuickControls {
  const ParentQuickControls({
    this.bedtimeEnabled = true,
    this.dailyLimitMinutes = 120,
    this.bedtimeHour = 20,
    this.requirePurchaseApproval = false,
    this.spendLimitEnabled = false,
    this.spendLimitAmount = 200,
    this.spendLimitPeriod = SpendLimitPeriod.weekly,
  });

  factory ParentQuickControls.fromJson(Map<String, dynamic> json) {
    return ParentQuickControls(
      bedtimeEnabled: json['bedtimeEnabled'] as bool? ?? true,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int? ?? 120,
      bedtimeHour: json['bedtimeHour'] as int? ?? 20,
      requirePurchaseApproval:
          json['requirePurchaseApproval'] as bool? ?? false,
      spendLimitEnabled: json['spendLimitEnabled'] as bool? ?? false,
      spendLimitAmount: (json['spendLimitAmount'] as num?)?.toInt() ?? 200,
      spendLimitPeriod:
          SpendLimitPeriod.fromName(json['spendLimitPeriod'] as String?),
    );
  }

  final bool bedtimeEnabled;
  final int dailyLimitMinutes;
  final int bedtimeHour;

  /// When true, a child's Tienda purchases are held as a pending request
  /// (see `StudentDatasource.requestPurchase`) instead of being completed
  /// immediately, until a parent approves them from the Parent Dashboard.
  final bool requirePurchaseApproval;

  /// When true, a child may not spend more than [spendLimitAmount] points
  /// per [spendLimitPeriod] — checked against the rolling sum of
  /// `PurchaseTransaction` entries in that window (see
  /// `StudentRepository.getSpentInWindow`).
  final bool spendLimitEnabled;
  final int spendLimitAmount;
  final SpendLimitPeriod spendLimitPeriod;

  Map<String, dynamic> toJson() {
    return {
      'bedtimeEnabled': bedtimeEnabled,
      'dailyLimitMinutes': dailyLimitMinutes,
      'bedtimeHour': bedtimeHour,
      'requirePurchaseApproval': requirePurchaseApproval,
      'spendLimitEnabled': spendLimitEnabled,
      'spendLimitAmount': spendLimitAmount,
      'spendLimitPeriod': spendLimitPeriod.name,
    };
  }

  ParentQuickControls copyWith({
    bool? bedtimeEnabled,
    int? dailyLimitMinutes,
    int? bedtimeHour,
    bool? requirePurchaseApproval,
    bool? spendLimitEnabled,
    int? spendLimitAmount,
    SpendLimitPeriod? spendLimitPeriod,
  }) {
    return ParentQuickControls(
      bedtimeEnabled: bedtimeEnabled ?? this.bedtimeEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
      requirePurchaseApproval:
          requirePurchaseApproval ?? this.requirePurchaseApproval,
      spendLimitEnabled: spendLimitEnabled ?? this.spendLimitEnabled,
      spendLimitAmount: spendLimitAmount ?? this.spendLimitAmount,
      spendLimitPeriod: spendLimitPeriod ?? this.spendLimitPeriod,
    );
  }
}

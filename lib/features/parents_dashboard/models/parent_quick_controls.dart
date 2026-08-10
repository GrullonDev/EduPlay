class ParentQuickControls {
  const ParentQuickControls({
    this.bedtimeEnabled = true,
    this.dailyLimitMinutes = 120,
    this.bedtimeHour = 20,
  });

  final bool bedtimeEnabled;
  final int dailyLimitMinutes;
  final int bedtimeHour;

  factory ParentQuickControls.fromJson(Map<String, dynamic> json) {
    return ParentQuickControls(
      bedtimeEnabled: json['bedtimeEnabled'] as bool? ?? true,
      dailyLimitMinutes: json['dailyLimitMinutes'] as int? ?? 120,
      bedtimeHour: json['bedtimeHour'] as int? ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedtimeEnabled': bedtimeEnabled,
      'dailyLimitMinutes': dailyLimitMinutes,
      'bedtimeHour': bedtimeHour,
    };
  }

  ParentQuickControls copyWith({
    bool? bedtimeEnabled,
    int? dailyLimitMinutes,
    int? bedtimeHour,
  }) {
    return ParentQuickControls(
      bedtimeEnabled: bedtimeEnabled ?? this.bedtimeEnabled,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      bedtimeHour: bedtimeHour ?? this.bedtimeHour,
    );
  }
}

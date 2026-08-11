class NotificationPreferences {
  const NotificationPreferences({
    this.emailSessionComplete = true,
    this.emailWeeklyDigest = true,
    this.emailTips = false,
    this.emailNewFeatures = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      emailSessionComplete: (map['emailSessionComplete'] as bool?) ?? true,
      emailWeeklyDigest: (map['emailWeeklyDigest'] as bool?) ?? true,
      emailTips: (map['emailTips'] as bool?) ?? false,
      emailNewFeatures: (map['emailNewFeatures'] as bool?) ?? true,
    );
  }

  final bool emailSessionComplete;
  final bool emailWeeklyDigest;
  final bool emailTips;
  final bool emailNewFeatures;

  Map<String, dynamic> toMap() {
    return {
      'emailSessionComplete': emailSessionComplete,
      'emailWeeklyDigest': emailWeeklyDigest,
      'emailTips': emailTips,
      'emailNewFeatures': emailNewFeatures,
    };
  }
}

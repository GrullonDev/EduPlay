// Project imports:
import 'package:edu_play/features/settings/domain/entities/notification_preferences.dart';
import 'package:edu_play/features/settings/domain/entities/parent_settings_profile.dart';

abstract class SettingsRepository {
  Future<ParentSettingsProfile?> getParentProfile();

  Future<void> updateParentProfile({
    required String firstName,
    required String lastName,
    required String age,
  });

  Future<NotificationPreferences> getNotificationPreferences();

  Future<void> updateNotificationPreferences(NotificationPreferences prefs);
}

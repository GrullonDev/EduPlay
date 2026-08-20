// Project imports:
import 'package:edu_play/features/settings/data/datasources/settings_datasource.dart';
import 'package:edu_play/features/settings/domain/entities/notification_preferences.dart';
import 'package:edu_play/features/settings/domain/entities/parent_settings_profile.dart';
import 'package:edu_play/features/settings/domain/repositories/settings_repository.dart';

class FirestoreSettingsRepository implements SettingsRepository {
  const FirestoreSettingsRepository({required this.datasource});

  final SettingsDatasource datasource;

  @override
  Future<ParentSettingsProfile?> getParentProfile() {
    return datasource.getParentProfile();
  }

  @override
  Future<void> updateParentProfile({
    required String firstName,
    required String lastName,
    required String age,
  }) {
    return datasource.updateParentProfile(
      firstName: firstName,
      lastName: lastName,
      age: age,
    );
  }

  @override
  Future<NotificationPreferences> getNotificationPreferences() {
    return datasource.getNotificationPreferences();
  }

  @override
  Future<void> updateNotificationPreferences(NotificationPreferences prefs) {
    return datasource.updateNotificationPreferences(prefs);
  }
}

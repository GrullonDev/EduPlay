// Project imports:
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

abstract class ChildProfilesRepository {
  Future<List<ChildProfile>> getProfiles();

  Future<ChildProfile?> findByPin(String pin);

  Future<ChildProfile?> findByPinGlobal(String pin);

  Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  });

  Future<void> deleteProfile(String id, {String? pin});

  Future<void> updateProfile(ChildProfile updated);

  Future<String> getParentName();

  Future<void> setParentName(String name);
}

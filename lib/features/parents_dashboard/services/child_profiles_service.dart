import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';
import 'package:edu_play/utils/injection_container.dart';

/// Compatibility facade for existing screens.
///
/// New code should depend on [ChildProfilesRepository] directly through
/// dependency injection. This wrapper keeps the current static API stable while
/// screens are migrated incrementally.
class ChildProfilesService {
  static ChildProfilesRepository get _repository =>
      sl<ChildProfilesRepository>();

  static Future<List<ChildProfile>> getProfiles() {
    return _repository.getProfiles();
  }

  static Future<ChildProfile?> findByPin(String pin) {
    return _repository.findByPin(pin);
  }

  static Future<ChildProfile?> findByPinGlobal(String pin) {
    return _repository.findByPinGlobal(pin);
  }

  static Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  }) {
    return _repository.addProfile(
      name: name,
      age: age,
      focusSubject: focusSubject,
      existingCount: existingCount,
    );
  }

  static Future<void> deleteProfile(String id, {String? pin}) {
    return _repository.deleteProfile(id, pin: pin);
  }

  static Future<void> updateProfile(ChildProfile updated) {
    return _repository.updateProfile(updated);
  }

  static Future<String> getParentName() {
    return _repository.getParentName();
  }

  static Future<void> setParentName(String name) {
    return _repository.setParentName(name);
  }
}

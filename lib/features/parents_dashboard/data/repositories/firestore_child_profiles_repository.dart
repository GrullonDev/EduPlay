// Project imports:
import 'package:edu_play/features/parents_dashboard/data/datasources/child_profiles_datasource.dart';
import 'package:edu_play/features/parents_dashboard/domain/repositories/child_profiles_repository.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

class FirestoreChildProfilesRepository implements ChildProfilesRepository {
  FirestoreChildProfilesRepository({
    required ChildProfilesDatasource datasource,
  }) : _datasource = datasource;

  final ChildProfilesDatasource _datasource;

  @override
  Future<List<ChildProfile>> getProfiles() {
    return _datasource.getProfiles();
  }

  @override
  Future<ChildProfile?> findByPin(String pin) {
    return _datasource.findByPin(pin);
  }

  @override
  Future<ChildProfile?> findByPinGlobal(String pin) {
    return _datasource.findByPinGlobal(pin);
  }

  @override
  Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  }) {
    return _datasource.addProfile(
      name: name,
      age: age,
      focusSubject: focusSubject,
      existingCount: existingCount,
    );
  }

  @override
  Future<void> deleteProfile(String id, {String? pin}) {
    return _datasource.deleteProfile(id, pin: pin);
  }

  @override
  Future<void> updateProfile(ChildProfile updated) {
    return _datasource.updateProfile(updated);
  }

  @override
  Future<String> getParentName() {
    return _datasource.getParentName();
  }

  @override
  Future<void> setParentName(String name) {
    return _datasource.setParentName(name);
  }
}

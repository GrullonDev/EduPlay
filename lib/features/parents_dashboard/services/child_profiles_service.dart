import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edu_play/features/parents_dashboard/models/child_profile.dart';

/// Local persistence for child profiles using SharedPreferences.
/// No backend required — all data stays on the device.
class ChildProfilesService {
  static const _kProfilesKey = 'eduplay_child_profiles';
  static const _kParentNameKey = 'eduplay_parent_name';

  // ── Read ──────────────────────────────────────────────────────────────────

  static Future<List<ChildProfile>> getProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProfilesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ChildProfile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ChildProfile?> findByPin(String pin) async {
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((p) => p.pin == pin);
    } catch (_) {
      return null;
    }
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> _saveProfiles(List<ChildProfile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProfilesKey,
      jsonEncode(profiles.map((p) => p.toJson()).toList()),
    );
  }

  static Future<ChildProfile> addProfile({
    required String name,
    required int age,
    required String focusSubject,
    required int existingCount,
  }) async {
    final profiles = await getProfiles();

    // Ensure PIN is unique
    String pin;
    final usedPins = profiles.map((p) => p.pin).toSet();
    do {
      pin = ChildProfile.generatePin();
    } while (usedPins.contains(pin));

    final profile = ChildProfile(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      age: age,
      level: 1,
      pin: pin,
      focusSubject: focusSubject,
      levelProgress: 0.0,
      avatarColorHex:
          ChildProfile.avatarColorForIndex(existingCount),
    );

    profiles.add(profile);
    await _saveProfiles(profiles);
    return profile;
  }

  static Future<void> deleteProfile(String id) async {
    final profiles = await getProfiles();
    profiles.removeWhere((p) => p.id == id);
    await _saveProfiles(profiles);
  }

  static Future<void> updateProfile(ChildProfile updated) async {
    final profiles = await getProfiles();
    final idx = profiles.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      profiles[idx] = updated;
      await _saveProfiles(profiles);
    }
  }

  // ── Parent name ───────────────────────────────────────────────────────────

  static Future<String> getParentName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kParentNameKey) ?? 'Mamá';
  }

  static Future<void> setParentName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kParentNameKey, name);
  }
}

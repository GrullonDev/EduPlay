import 'package:shared_preferences/shared_preferences.dart';

/// Local XP / points store for guest children.
///
/// Points are persisted to [SharedPreferences] so they survive app restarts.
/// When a child links their profile with a PIN, these points merge into their
/// Firestore profile and this key is cleared.
class PointsService {
  static const _kKey = 'edu_play_guest_points';

  /// Returns the locally stored guest points (default 0).
  static Future<int> getPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kKey) ?? 0;
  }

  /// Adds [delta] to the current guest points.
  static Future<int> addPoints(int delta) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kKey) ?? 0;
    final updated = (current + delta).clamp(0, 999999);
    await prefs.setInt(_kKey, updated);
    return updated;
  }

  /// Overwrites the guest points with [value].
  static Future<void> setPoints(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kKey, value.clamp(0, 999999));
  }

  /// Resets guest points to zero (call when child links a PIN profile).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kKey);
  }
}

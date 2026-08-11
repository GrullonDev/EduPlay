import 'package:shared_preferences/shared_preferences.dart';

abstract class LevelProgressDatasource {
  Future<int> getLastCelebratedLevel(String key);

  Future<void> setLastCelebratedLevel(String key, int level);
}

/// SharedPreferences-backed persistence, one int per child/guest key.
class LevelProgressLocalDatasource implements LevelProgressDatasource {
  static String _prefKey(String key) => 'level_progress_$key';

  @override
  Future<int> getLastCelebratedLevel(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKey(key)) ?? 0;
  }

  @override
  Future<void> setLastCelebratedLevel(String key, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey(key), level);
  }
}

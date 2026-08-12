/// Tracks the last level a child's level-up celebration was shown for, so
/// the dashboard can show it exactly once per level gained.
abstract class LevelProgressRepository {
  /// Returns 0 if no level has ever been recorded for [key].
  Future<int> getLastCelebratedLevel(String key);

  Future<void> setLastCelebratedLevel(String key, int level);
}

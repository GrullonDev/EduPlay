import 'package:edu_play/features/sticker_album/data/datasources/level_progress_datasource.dart';
import 'package:edu_play/features/sticker_album/domain/repositories/level_progress_repository.dart';

class LocalLevelProgressRepository implements LevelProgressRepository {
  LocalLevelProgressRepository({required LevelProgressDatasource datasource})
      : _datasource = datasource;

  final LevelProgressDatasource _datasource;

  @override
  Future<int> getLastCelebratedLevel(String key) {
    return _datasource.getLastCelebratedLevel(key);
  }

  @override
  Future<void> setLastCelebratedLevel(String key, int level) {
    return _datasource.setLastCelebratedLevel(key, level);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

class StickerRepository {
  static const String _key = 'unlocked_stickers';

  Future<List<String>> getUnlockedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> unlockSticker(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = prefs.getStringList(_key) ?? [];
    if (!unlocked.contains(id)) {
      unlocked.add(id);
      await prefs.setStringList(_key, unlocked);
    }
  }

  Future<bool> isUnlocked(String id) async {
    final unlocked = await getUnlockedStickers();
    return unlocked.contains(id);
  }
}

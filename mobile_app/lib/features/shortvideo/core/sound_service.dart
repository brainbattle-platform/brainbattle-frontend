import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage sound/music state (local)
class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  static const String _kRecentSoundsKey = 'shorts_recent_sounds';

  /// Add to recent sounds
  Future<void> addRecent(String soundId, String soundName) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentSoundsKey) ?? [];
    
    // Format: "soundId|soundName"
    final entry = '$soundId|$soundName';
    list.remove(entry);
    list.insert(0, entry);
    if (list.length > 20) list.removeLast();
    
    await prefs.setStringList(_kRecentSoundsKey, list);
  }

  /// Get recent sounds
  Future<List<Map<String, String>>> getRecentSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentSoundsKey) ?? [];
    
    return list.map((entry) {
      final parts = entry.split('|');
      return {
        'id': parts[0],
        'name': parts.length > 1 ? parts[1] : parts[0],
      };
    }).toList();
  }
}


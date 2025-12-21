import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage save/favorite state (local mock)
class SaveService {
  static final SaveService instance = SaveService._();
  SaveService._();

  static const String _kSavePrefix = 'shorts_save_';

  /// Check if video is saved
  Future<bool> isSaved(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_kSavePrefix$videoId') ?? false;
  }

  /// Toggle save state
  Future<bool> toggleSave(String videoId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await isSaved(videoId);
    final newState = !current;
    await prefs.setBool('$_kSavePrefix$videoId', newState);
    return newState;
  }
}


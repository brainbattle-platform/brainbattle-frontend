import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage mute state for short videos
class MuteService {
  static final MuteService instance = MuteService._();
  MuteService._();

  static const String _kMutedKey = 'shorts_muted';

  /// Get current mute state (default: false = unmuted)
  Future<bool> isMuted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kMutedKey) ?? false;
  }

  /// Set mute state
  Future<void> setMuted(bool muted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kMutedKey, muted);
  }

  /// Toggle mute state
  Future<bool> toggle() async {
    final current = await isMuted();
    final newState = !current;
    await setMuted(newState);
    return newState;
  }
}


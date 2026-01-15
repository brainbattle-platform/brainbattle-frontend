import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user session (userId storage)
class UserSession {
  static final UserSession instance = UserSession._();
  UserSession._();

  static const String _kUserId = 'user_session.user_id';

  /// Save userId to SharedPreferences
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, userId);
  }

  /// Get current userId from SharedPreferences
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  /// Clear user session
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final userId = await getUserId();
    return userId != null && userId.isNotEmpty;
  }
}


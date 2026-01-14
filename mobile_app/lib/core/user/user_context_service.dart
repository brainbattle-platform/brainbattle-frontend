import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage current user ID for API requests
/// This is a temporary solution until full auth is implemented.
/// 
/// Stores user ID in SharedPreferences and provides it for API headers.
/// Defaults to "user_1" if not set.
class UserContextService {
  static final UserContextService instance = UserContextService._();
  UserContextService._();

  static const String _userIdKey = 'current_user_id';
  static const String _defaultUserId = 'user_1';

  String? _cachedUserId;

  /// Get current user ID
  /// Returns "user_1", "user_2", etc.
  Future<String> getUserId() async {
    if (_cachedUserId != null) {
      return _cachedUserId!;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey) ?? _defaultUserId;
    _cachedUserId = userId;
    return userId;
  }

  /// Set current user ID
  /// Use this to switch between users for demo/testing
  Future<void> setUserId(String userId) async {
    // Validate format: should be "user_1", "user_2", etc.
    if (!userId.startsWith('user_')) {
      throw ArgumentError('User ID must start with "user_" (e.g., "user_1", "user_2")');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    _cachedUserId = userId;
  }

  /// Get user ID synchronously (from cache)
  /// Returns default if not cached yet
  String getUserIdSync() {
    return _cachedUserId ?? _defaultUserId;
  }

  /// Reset to default user
  Future<void> resetToDefault() async {
    await setUserId(_defaultUserId);
  }

  /// Get default user ID
  String getDefaultUserId() => _defaultUserId;
}


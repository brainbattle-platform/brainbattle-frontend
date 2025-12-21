import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage follow state (local mock)
class FollowService {
  static final FollowService instance = FollowService._();
  FollowService._();

  static const String _kFollowPrefix = 'shorts_follow_';

  /// Check if following a user
  Future<bool> isFollowing(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_kFollowPrefix$userId') ?? false;
  }

  /// Toggle follow state
  Future<bool> toggleFollow(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await isFollowing(userId);
    final newState = !current;
    await prefs.setBool('$_kFollowPrefix$userId', newState);
    return newState;
  }
}


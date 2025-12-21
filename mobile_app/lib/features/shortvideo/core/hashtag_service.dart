import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage hashtag follow state (local)
class HashtagService {
  static final HashtagService instance = HashtagService._();
  HashtagService._();

  static const String _kFollowedHashtagsKey = 'shorts_followed_hashtags';
  static const String _kRecentHashtagsKey = 'shorts_recent_hashtags';

  /// Check if following a hashtag
  Future<bool> isFollowing(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kFollowedHashtagsKey) ?? [];
    return list.contains(tag.toLowerCase());
  }

  /// Toggle follow state
  Future<bool> toggleFollow(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kFollowedHashtagsKey) ?? [];
    final tagLower = tag.toLowerCase();
    final following = list.contains(tagLower);
    
    if (following) {
      list.remove(tagLower);
    } else {
      list.add(tagLower);
    }
    
    await prefs.setStringList(_kFollowedHashtagsKey, list);
    return !following;
  }

  /// Get followed hashtags
  Future<List<String>> getFollowedHashtags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kFollowedHashtagsKey) ?? [];
  }

  /// Add to recent hashtags
  Future<void> addRecent(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kRecentHashtagsKey) ?? [];
    final tagLower = tag.toLowerCase();
    
    list.remove(tagLower);
    list.insert(0, tagLower);
    if (list.length > 20) list.removeLast();
    
    await prefs.setStringList(_kRecentHashtagsKey, list);
  }

  /// Get recent hashtags
  Future<List<String>> getRecentHashtags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kRecentHashtagsKey) ?? [];
  }
}


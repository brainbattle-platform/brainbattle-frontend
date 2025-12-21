import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'video_post_model.dart';
import '../data/shortvideo_model.dart';

/// Local store for video posts (works without backend)
class LocalShortsStore {
  static final LocalShortsStore instance = LocalShortsStore._();
  LocalShortsStore._();

  static const String _kPostsKey = 'shorts_local_posts';
  static const String _kBlockedUsersKey = 'shorts_blocked_users';
  static const String _kHiddenVideosKey = 'shorts_hidden_videos';
  static const String _kReportsKey = 'shorts_reports';

  List<VideoPost> _posts = [];
  Set<String> _blockedUsers = {};
  Set<String> _hiddenVideos = {};
  List<Map<String, dynamic>> _reports = [];

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _load();
    _initialized = true;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load posts
    final postsJson = prefs.getString(_kPostsKey);
    if (postsJson != null) {
      final List<dynamic> data = jsonDecode(postsJson);
      _posts = data.map((e) => VideoPost.fromJson(e as Map<String, dynamic>)).toList();
    }

    // Load blocked users
    final blockedJson = prefs.getString(_kBlockedUsersKey);
    if (blockedJson != null) {
      _blockedUsers = (jsonDecode(blockedJson) as List).cast<String>().toSet();
    }

    // Load hidden videos
    final hiddenJson = prefs.getString(_kHiddenVideosKey);
    if (hiddenJson != null) {
      _hiddenVideos = (jsonDecode(hiddenJson) as List).cast<String>().toSet();
    }

    // Load reports
    final reportsJson = prefs.getString(_kReportsKey);
    if (reportsJson != null) {
      _reports = (jsonDecode(reportsJson) as List).cast<Map<String, dynamic>>();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPostsKey, jsonEncode(_posts.map((p) => p.toJson()).toList()));
    await prefs.setString(_kBlockedUsersKey, jsonEncode(_blockedUsers.toList()));
    await prefs.setString(_kHiddenVideosKey, jsonEncode(_hiddenVideos.toList()));
    await prefs.setString(_kReportsKey, jsonEncode(_reports));
  }

  /// Add a new post
  Future<void> addPost(VideoPost post) async {
    await init();
    _posts.insert(0, post); // Add to beginning
    await _save();
  }

  /// Get all posts (for feed)
  Future<List<ShortVideo>> listFeedPosts({String? currentUserId}) async {
    await init();
    
    // Filter out blocked users and hidden videos
    final filtered = _posts.where((post) {
      if (_blockedUsers.contains(post.creatorId)) return false;
      if (_hiddenVideos.contains(post.id)) return false;
      if (post.privacy == PrivacyLevel.private && post.creatorId != currentUserId) {
        return false;
      }
      return true;
    }).toList();

    // Convert to ShortVideo model
    return filtered.map((post) {
      // Check if video file exists
      final file = File(post.videoPath);
      if (!file.existsSync()) return null;

      return ShortVideo(
        id: post.id,
        videoUrl: post.videoPath, // Local file path
        thumbnailUrl: post.coverPath ?? post.videoPath, // Use cover or video as thumb
        author: post.creatorId,
        caption: post.caption,
        music: post.musicName ?? 'BrainBattle Mix',
        likes: 0,
        comments: 0,
        liked: false,
      );
    }).whereType<ShortVideo>().toList();
  }

  /// Get posts by creator
  Future<List<ShortVideo>> listMyPosts(String creatorId) async {
    await init();
    final myPosts = _posts.where((p) => p.creatorId == creatorId).toList();
    
    return myPosts.map((post) {
      final file = File(post.videoPath);
      if (!file.existsSync()) return null;

      return ShortVideo(
        id: post.id,
        videoUrl: post.videoPath,
        thumbnailUrl: post.coverPath ?? post.videoPath,
        author: post.creatorId,
        caption: post.caption,
        music: post.musicName ?? 'BrainBattle Mix',
        likes: 0,
        comments: 0,
        liked: false,
      );
    }).whereType<ShortVideo>().toList();
  }

  /// Block a user
  Future<void> blockUser(String userId) async {
    await init();
    _blockedUsers.add(userId);
    await _save();
  }

  /// Unblock a user
  Future<void> unblockUser(String userId) async {
    await init();
    _blockedUsers.remove(userId);
    await _save();
  }

  /// Hide a video
  Future<void> hideVideo(String videoId) async {
    await init();
    _hiddenVideos.add(videoId);
    await _save();
  }

  /// Report a video/user
  Future<void> addReport({
    required String videoId,
    required String reason,
    String? userId,
  }) async {
    await init();
    _reports.add({
      'videoId': videoId,
      'userId': userId,
      'reason': reason,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await _save();
  }

  /// Get blocked users
  Set<String> getBlockedUsers() => _blockedUsers;

  /// Get hidden videos
  Set<String> getHiddenVideos() => _hiddenVideos;
}


import 'dart:async';
import '../data/shortvideo_model.dart';
import '../data/discovery_repository.dart';
import '../core/shortvideo_config.dart';
import '../data/shortvideo_service.dart';
import '../data/local_shorts_store.dart';
import '../mock/shorts_mock_data.dart';
import 'package:flutter/foundation.dart';

/// Repository interface for ShortVideo data
abstract class IShortsRepository {
  Future<List<ShortVideo>> getFeed({int page = 1, String? cursor});
  Future<List<ShortVideo>> getProfilePosts(String userId);
  Future<SearchResults> search(String query);
  Future<List<ShortVideo>> getHashtagFeed(String tag);
  Future<List<ShortVideo>> getSoundFeed(String soundId);
  Future<List<NotificationItem>> getInbox();
  Future<TrendingContent> getTrending();
  Future<List<String>> getSuggestions(String prefix);
  
  /// Whether currently using mock data
  ValueNotifier<bool> get isUsingMock;
}

/// Remote repository (real API)
class RemoteShortsRepository implements IShortsRepository {
  final ShortVideoService _videoService = ShortVideoService();
  final LocalShortsStore _localStore = LocalShortsStore.instance;
  final ShortsDiscoveryRepository _discoveryRepo = ShortsDiscoveryRepository();
  final ValueNotifier<bool> _isUsingMock = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isUsingMock => _isUsingMock;

  @override
  Future<List<ShortVideo>> getFeed({int page = 1, String? cursor}) async {
    final remoteData = await _videoService.fetchFeed(page: page);
    final localData = await _localStore.listFeedPosts();
    return [...localData, ...remoteData];
  }

  @override
  Future<List<ShortVideo>> getProfilePosts(String userId) async {
    return await _localStore.listMyPosts(userId);
  }

  @override
  Future<SearchResults> search(String query) async {
    return await _discoveryRepo.search(query);
  }

  @override
  Future<List<ShortVideo>> getHashtagFeed(String tag) async {
    final allVideos = await getFeed();
    final tagLower = tag.toLowerCase().replaceAll('#', '');
    return allVideos.where((v) => v.caption.toLowerCase().contains('#$tagLower')).toList();
  }

  @override
  Future<List<ShortVideo>> getSoundFeed(String soundId) async {
    final allVideos = await getFeed();
    // Match by sound name (simplified)
    return allVideos.where((v) => v.music.toLowerCase().contains(soundId.toLowerCase())).toList();
  }

  @override
  Future<List<NotificationItem>> getInbox() async {
    // TODO: Implement real inbox API
    return [];
  }

  @override
  Future<TrendingContent> getTrending() async {
    return await _discoveryRepo.trending();
  }

  @override
  Future<List<String>> getSuggestions(String prefix) async {
    return await _discoveryRepo.suggestions(prefix);
  }
}

/// Mock repository (demo data)
class MockShortsRepository implements IShortsRepository {
  final ValueNotifier<bool> _isUsingMock = ValueNotifier<bool>(true);

  @override
  ValueNotifier<bool> get isUsingMock => _isUsingMock;

  @override
  Future<List<ShortVideo>> getFeed({int page = 1, String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
    return ShortsMockData.getPosts();
  }

  @override
  Future<List<ShortVideo>> getProfilePosts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ShortsMockData.getPostsByCreator(userId);
  }

  @override
  Future<SearchResults> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ShortsMockData.search(query);
  }

  @override
  Future<List<ShortVideo>> getHashtagFeed(String tag) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ShortsMockData.getPostsByHashtag(tag);
  }

  @override
  Future<List<ShortVideo>> getSoundFeed(String soundId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ShortsMockData.getPostsBySound(soundId);
  }

  @override
  Future<List<NotificationItem>> getInbox() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ShortsMockData.getInbox();
  }

  @override
  Future<TrendingContent> getTrending() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return ShortsMockData.getTrending();
  }

  @override
  Future<List<String>> getSuggestions(String prefix) async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Mock suggestions
    final allHashtags = ShortsMockData.hashtags.map((h) => '#${h.tag}').toList();
    final allCreators = ShortsMockData.creators.map((c) => '@${c.handle}').toList();
    final all = [...allHashtags, ...allCreators];
    final p = prefix.toLowerCase();
    return all.where((s) => s.toLowerCase().contains(p)).take(10).toList();
  }
}

/// Fallback repository (try remote, fallback to mock)
class FallbackShortsRepository implements IShortsRepository {
  final RemoteShortsRepository _remote = RemoteShortsRepository();
  final MockShortsRepository _mock = MockShortsRepository();
  final ValueNotifier<bool> _isUsingMock = ValueNotifier<bool>(false);

  @override
  ValueNotifier<bool> get isUsingMock => _isUsingMock;


  @override
  Future<List<ShortVideo>> getFeed({int page = 1, String? cursor}) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getFeed(page: page);
    }

    try {
      final result = await _remote.getFeed(page: page, cursor: cursor).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.isEmpty) {
        // Empty result, use mock
        _isUsingMock.value = true;
        return await _mock.getFeed(page: page);
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getFeed(page: page);
    }
  }

  @override
  Future<List<ShortVideo>> getProfilePosts(String userId) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getProfilePosts(userId);
    }

    try {
      final result = await _remote.getProfilePosts(userId).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.isEmpty) {
        _isUsingMock.value = true;
        return await _mock.getProfilePosts(userId);
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getProfilePosts(userId);
    }
  }

  @override
  Future<SearchResults> search(String query) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.search(query);
    }

    try {
      final result = await _remote.search(query).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.videos.isEmpty && result.users.isEmpty && result.hashtags.isEmpty) {
        _isUsingMock.value = true;
        return await _mock.search(query);
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.search(query);
    }
  }

  @override
  Future<List<ShortVideo>> getHashtagFeed(String tag) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getHashtagFeed(tag);
    }

    try {
      final result = await _remote.getHashtagFeed(tag).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.isEmpty) {
        _isUsingMock.value = true;
        return await _mock.getHashtagFeed(tag);
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getHashtagFeed(tag);
    }
  }

  @override
  Future<List<ShortVideo>> getSoundFeed(String soundId) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getSoundFeed(soundId);
    }

    try {
      final result = await _remote.getSoundFeed(soundId).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.isEmpty) {
        _isUsingMock.value = true;
        return await _mock.getSoundFeed(soundId);
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getSoundFeed(soundId);
    }
  }

  @override
  Future<List<NotificationItem>> getInbox() async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getInbox();
    }

    try {
      final result = await _remote.getInbox().timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      if (result.isEmpty) {
        _isUsingMock.value = true;
        return await _mock.getInbox();
      }
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getInbox();
    }
  }

  @override
  Future<TrendingContent> getTrending() async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getTrending();
    }

    try {
      final result = await _remote.getTrending().timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getTrending();
    }
  }

  @override
  Future<List<String>> getSuggestions(String prefix) async {
    if (ShortVideoConfig.forceMock) {
      _isUsingMock.value = true;
      return await _mock.getSuggestions(prefix);
    }

    try {
      final result = await _remote.getSuggestions(prefix).timeout(
        Duration(milliseconds: ShortVideoConfig.remoteTimeoutMs),
      );
      _isUsingMock.value = false;
      return result;
    } catch (e) {
      _isUsingMock.value = true;
      return await _mock.getSuggestions(prefix);
    }
  }
}

/// Singleton instance
class ShortsRepository {
  static final ShortsRepository instance = ShortsRepository._();
  ShortsRepository._();

  late final IShortsRepository _repository = FallbackShortsRepository();

  IShortsRepository get repository => _repository;
}


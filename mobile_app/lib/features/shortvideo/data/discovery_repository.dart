import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../data/local_shorts_store.dart';

/// Repository for discovery/search features
class ShortsDiscoveryRepository {
  final ShortVideoService _videoService = ShortVideoService();
  final LocalShortsStore _localStore = LocalShortsStore.instance;

  /// Search across videos, users, hashtags
  Future<SearchResults> search(String query) async {
    // TODO: Replace with real API call
    await Future.delayed(const Duration(milliseconds: 300));

    final allVideos = await _videoService.fetchFeed(page: 1);
    final localVideos = await _localStore.listFeedPosts();

    final allVideosCombined = [...localVideos, ...allVideos];
    final q = query.toLowerCase();

    // Filter videos
    final videos = allVideosCombined.where((v) =>
        v.caption.toLowerCase().contains(q) ||
        v.author.toLowerCase().contains(q)).toList();

    // Mock users
    final users = <String>[];
    for (final video in allVideosCombined) {
      if (video.author.toLowerCase().contains(q) && !users.contains(video.author)) {
        users.add(video.author);
      }
    }

    // Extract hashtags from captions
    final hashtags = <String>[];
    final hashtagRegex = RegExp(r'#(\w+)');
    for (final video in allVideosCombined) {
      final matches = hashtagRegex.allMatches(video.caption);
      for (final match in matches) {
        final tag = match.group(1)!.toLowerCase();
        if (tag.contains(q) && !hashtags.contains(tag)) {
          hashtags.add(tag);
        }
      }
    }

    return SearchResults(
      videos: videos,
      users: users,
      hashtags: hashtags,
    );
  }

  /// Get trending content
  Future<TrendingContent> trending() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final allVideos = await _videoService.fetchFeed(page: 1);
    final localVideos = await _localStore.listFeedPosts();
    final allVideosCombined = [...localVideos, ...allVideos];

    // Extract trending hashtags (mock: most common in captions)
    final hashtagCounts = <String, int>{};
    final hashtagRegex = RegExp(r'#(\w+)');
    for (final video in allVideosCombined) {
      final matches = hashtagRegex.allMatches(video.caption);
      for (final match in matches) {
        final tag = match.group(1)!.toLowerCase();
        hashtagCounts[tag] = (hashtagCounts[tag] ?? 0) + 1;
      }
    }

    final trendingHashtags = hashtagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

    // Mock trending sounds
    final trendingSounds = [
      'BrainBattle Mix',
      'She Share Story',
      'Lofi Study',
    ];

    // Mock trending creators (most videos)
    final creatorCounts = <String, int>{};
    for (final video in allVideosCombined) {
      creatorCounts[video.author] = (creatorCounts[video.author] ?? 0) + 1;
    }
    final trendingCreators = creatorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final creators = trendingCreators.take(5).map((e) => e.key).toList();

    return TrendingContent(
      hashtags: trendingHashtags.map((e) => e.key).toList(),
      sounds: trendingSounds,
      creators: creators,
    );
  }

  /// Get search suggestions
  Future<List<String>> suggestions(String prefix) async {
    if (prefix.trim().isEmpty) return [];

    await Future.delayed(const Duration(milliseconds: 100));

    final allVideos = await _videoService.fetchFeed(page: 1);
    final localVideos = await _localStore.listFeedPosts();
    final allVideosCombined = [...localVideos, ...allVideos];

    final suggestions = <String>{};
    final p = prefix.toLowerCase();

    // Extract hashtags
    final hashtagRegex = RegExp(r'#(\w+)');
    for (final video in allVideosCombined) {
      final matches = hashtagRegex.allMatches(video.caption);
      for (final match in matches) {
        final tag = match.group(1)!;
        if (tag.toLowerCase().startsWith(p)) {
          suggestions.add('#$tag');
        }
      }
      // Authors
      if (video.author.toLowerCase().startsWith(p)) {
        suggestions.add('@${video.author}');
      }
    }

    return suggestions.take(10).toList();
  }
}

class SearchResults {
  final List<ShortVideo> videos;
  final List<String> users;
  final List<String> hashtags;

  SearchResults({
    required this.videos,
    required this.users,
    required this.hashtags,
  });
}

class TrendingContent {
  final List<String> hashtags;
  final List<String> sounds;
  final List<String> creators;

  TrendingContent({
    required this.hashtags,
    required this.sounds,
    required this.creators,
  });
}


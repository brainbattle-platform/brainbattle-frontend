import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shortvideo/data/discovery_repository.dart';
import 'package:mobile_app/features/shortvideo/core/hashtag_service.dart';

void main() {
  test('ShortsDiscoveryRepository search returns results', () async {
    final repo = ShortsDiscoveryRepository();
    final results = await repo.search('test');
    
    expect(results, isNotNull);
    expect(results.videos, isA<List>());
    expect(results.users, isA<List>());
    expect(results.hashtags, isA<List>());
  });

  test('ShortsDiscoveryRepository trending returns content', () async {
    final repo = ShortsDiscoveryRepository();
    final trending = await repo.trending();
    
    expect(trending, isNotNull);
    expect(trending.hashtags, isA<List>());
    expect(trending.sounds, isA<List>());
    expect(trending.creators, isA<List>());
  });

  test('ShortsDiscoveryRepository suggestions returns list', () async {
    final repo = ShortsDiscoveryRepository();
    final suggestions = await repo.suggestions('test');
    
    expect(suggestions, isA<List<String>>());
  });

  test('HashtagService can toggle follow', () async {
    final service = HashtagService.instance;
    final tag = 'testtag';
    
    final initial = await service.isFollowing(tag);
    await service.toggleFollow(tag);
    final after = await service.isFollowing(tag);
    
    expect(after, !initial);
    
    // Toggle back
    await service.toggleFollow(tag);
    final back = await service.isFollowing(tag);
    expect(back, initial);
  });
}


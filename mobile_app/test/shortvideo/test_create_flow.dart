import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shortvideo/data/video_post_model.dart';
import 'package:mobile_app/features/shortvideo/data/local_shorts_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('LocalShortsStore can add and retrieve posts', () async {
    final store = LocalShortsStore.instance;
    await store.init();

    final post = VideoPost(
      id: 'test-1',
      videoPath: '/fake/path/video.mp4',
      coverPath: '/fake/path/cover.jpg',
      caption: 'Test video #test',
      hashtags: ['test'],
      createdAt: DateTime.now(),
      creatorId: 'user1',
    );

    await store.addPost(post);

    final myPosts = await store.listMyPosts('user1');
    expect(myPosts.length, greaterThan(0));
    expect(myPosts.first.id, 'test-1');
  });

  test('LocalShortsStore filters blocked users', () async {
    final store = LocalShortsStore.instance;
    await store.init();

    final post1 = VideoPost(
      id: '1',
      videoPath: '/fake/path/video1.mp4',
      caption: 'Video 1',
      hashtags: [],
      createdAt: DateTime.now(),
      creatorId: 'user1',
    );

    final post2 = VideoPost(
      id: '2',
      videoPath: '/fake/path/video2.mp4',
      caption: 'Video 2',
      hashtags: [],
      createdAt: DateTime.now(),
      creatorId: 'user2',
    );

    await store.addPost(post1);
    await store.addPost(post2);
    await store.blockUser('user2');

    final feedPosts = await store.listFeedPosts();
    // Should not contain videos from blocked user
    expect(feedPosts.any((v) => v.author == 'user2'), isFalse);
  });

  test('LocalShortsStore filters hidden videos', () async {
    final store = LocalShortsStore.instance;
    await store.init();

    final post = VideoPost(
      id: 'hidden-1',
      videoPath: '/fake/path/video.mp4',
      caption: 'Hidden video',
      hashtags: [],
      createdAt: DateTime.now(),
      creatorId: 'user1',
    );

    await store.addPost(post);
    await store.hideVideo('hidden-1');

    final feedPosts = await store.listFeedPosts();
    expect(feedPosts.any((v) => v.id == 'hidden-1'), isFalse);
  });
}


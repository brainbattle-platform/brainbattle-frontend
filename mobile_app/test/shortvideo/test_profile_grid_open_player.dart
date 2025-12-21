import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shortvideo/data/shortvideo_model.dart';
import 'package:mobile_app/features/shortvideo/shortvideo_routes.dart';

void main() {
  test('ShortVideoRoutes.player is defined', () {
    expect(ShortVideoRoutes.player, isNotEmpty);
    expect(ShortVideoRoutes.player, startsWith('/shorts/'));
  });

  test('ShortVideo model can be created', () {
    final video = ShortVideo(
      id: 'test-1',
      videoUrl: 'https://example.com/video.mp4',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      author: 'user1',
      caption: 'Test video #test',
      music: 'Test Sound',
    );

    expect(video.id, 'test-1');
    expect(video.author, 'user1');
    expect(video.caption, contains('#test'));
  });

  test('ShortVideo copyWith works', () {
    final video = ShortVideo(
      id: 'test-1',
      videoUrl: 'https://example.com/video.mp4',
      thumbnailUrl: 'https://example.com/thumb.jpg',
      author: 'user1',
      caption: 'Test',
      music: 'Sound',
      likes: 10,
      liked: false,
    );

    final updated = video.copyWith(liked: true, likes: 11);
    expect(updated.liked, isTrue);
    expect(updated.likes, 11);
    expect(updated.id, video.id);
  });
}


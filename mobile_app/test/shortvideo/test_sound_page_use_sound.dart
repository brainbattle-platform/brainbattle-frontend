import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shortvideo/core/sound_service.dart';
import 'package:mobile_app/features/shortvideo/shortvideo_routes.dart';

void main() {
  test('SoundService can add and retrieve recent sounds', () async {
    final service = SoundService.instance;
    
    await service.addRecent('sound-1', 'Test Sound 1');
    await service.addRecent('sound-2', 'Test Sound 2');
    
    final recent = await service.getRecentSounds();
    expect(recent.length, greaterThanOrEqualTo(2));
    expect(recent.first['id'], 'sound-2'); // Most recent first
    expect(recent.first['name'], 'Test Sound 2');
  });

  test('ShortVideoRoutes.sound is defined', () {
    expect(ShortVideoRoutes.sound, isNotEmpty);
    expect(ShortVideoRoutes.sound, startsWith('/shorts/'));
  });

  test('ShortVideoRoutes.upload is defined', () {
    expect(ShortVideoRoutes.upload, isNotEmpty);
    expect(ShortVideoRoutes.upload, startsWith('/shorts/'));
  });
}


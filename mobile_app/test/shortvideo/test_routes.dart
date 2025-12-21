import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/shortvideo/shortvideo_routes.dart';

void main() {
  test('All routes are defined and non-empty', () {
    expect(ShortVideoRoutes.shell, isNotEmpty);
    expect(ShortVideoRoutes.profile, isNotEmpty);
    expect(ShortVideoRoutes.search, isNotEmpty);
    expect(ShortVideoRoutes.searchResults, isNotEmpty);
    expect(ShortVideoRoutes.hashtag, isNotEmpty);
    expect(ShortVideoRoutes.sound, isNotEmpty);
    expect(ShortVideoRoutes.inbox, isNotEmpty);
    expect(ShortVideoRoutes.upload, isNotEmpty);
    expect(ShortVideoRoutes.editor, isNotEmpty);
    expect(ShortVideoRoutes.post, isNotEmpty);
  });

  test('Routes follow consistent pattern', () {
    expect(ShortVideoRoutes.profile, startsWith('/shorts/'));
    expect(ShortVideoRoutes.search, startsWith('/shorts/'));
    expect(ShortVideoRoutes.inbox, startsWith('/shorts/'));
  });
}


# ShortVideo Mock Data Implementation

## Summary

Đã implement mock data system cho ShortVideo module để tránh loading vô hạn và hỗ trợ chụp screenshot/Figma.

## Files Created/Modified

### Created:
1. `lib/features/shortvideo/core/shortvideo_config.dart` - Config flags
2. `lib/features/shortvideo/mock/shorts_mock_data.dart` - Mock dataset
3. `lib/features/shortvideo/data/shorts_repository.dart` - Repository layer với fallback
4. `lib/features/shortvideo/widgets/demo_banner.dart` - Banner "Demo data"

### Modified:
1. `lib/features/shortvideo/ui/shortvideo_feed_page.dart` - Dùng repository
2. `lib/features/shortvideo/ui/profile_page.dart` - Dùng repository (cần fix syntax)

## Commands

### Force mock mode:
```bash
flutter run --dart-define=FORCE_SHORTS_MOCK=true
```

### Normal mode (with fallback):
```bash
flutter run
```

### Screenshot mode:
```bash
flutter run --dart-define=SCREENSHOT_MODE=true
```

## TODO for Backend Integration

1. Update `RemoteShortsRepository` methods để gọi real API endpoints
2. Map API response format to `ShortVideo` model
3. Handle pagination với cursor/offset
4. Implement real inbox API
5. Add error handling cho network failures

## Notes

- Mock data có 30 videos, 8 creators, 5 sounds, 12 hashtags
- Timeout: 1200ms cho remote calls
- Auto fallback to mock nếu remote fail/timeout/empty
- Banner "Demo data" hiển thị khi đang dùng mock


# Run Guide - Learning API Integration

## Prerequisites

1. **Flutter SDK:** 3.8.1 or higher
2. **Backend Service:** NestJS Learning service running on port 3001
3. **Android Studio / Xcode:** For emulator/simulator

---

## Quick Start

### 1. Clean and Get Dependencies

```bash
cd brainbattle-frontend/mobile_app
flutter clean
flutter pub get
```

### 2. Start Backend Service

Ensure the Learning API is running:
```bash
# In brainbattle-dou directory
npm run start:dev
# Service should be available at http://localhost:3001/api/learning
```

### 3. Run on Android Emulator

```bash
flutter run
```

**Default API URL:** `http://10.0.2.2:3001/api/learning`

### 4. Run on iOS Simulator

```bash
flutter run
```

**Default API URL:** `http://localhost:3001/api/learning`

---

## Custom API URL

### Using --dart-define

**Android Emulator (custom IP):**
```bash
flutter run --dart-define=LEARNING_API_BASE_URL=http://192.168.1.100:3001/api/learning
```

**iOS Simulator (custom IP):**
```bash
flutter run --dart-define=LEARNING_API_BASE_URL=http://192.168.1.100:3001/api/learning
```

**Physical Device:**
```bash
# Replace with your machine's IP address
flutter run --dart-define=LEARNING_API_BASE_URL=http://192.168.1.100:3001/api/learning
```

---

## Debug Logging

HTTP requests/responses are automatically logged in debug builds.

**To see logs:**
```bash
flutter run
# Check console output for [HTTP GET], [HTTP POST], etc.
```

**Example log output:**
```
[HTTP GET] http://10.0.2.2:3001/api/learning/map
[Headers] {Content-Type: application/json, x-user-id: user_1}
[Response 200] http://10.0.2.2:3001/api/learning/map
[Body] {"success":true,"data":{...}}
```

---

## Testing Different Users

The app uses `x-user-id` header automatically. Default is `"user_1"`.

**To change user:**
1. Use `UserContextService` in code:
   ```dart
   await UserContextService.instance.setUserId('user_2');
   ```
2. Or modify `UserContextService` default in code

**Note:** User switching UI can be added later for demo purposes.

---

## Troubleshooting

### Android: Connection Refused

**Problem:** `10.0.2.2` not accessible

**Solutions:**
1. Ensure backend is running on host machine
2. Try using your machine's IP address:
   ```bash
   flutter run --dart-define=LEARNING_API_BASE_URL=http://192.168.1.100:3001/api/learning
   ```
3. Check Android emulator network settings

### iOS: Connection Refused

**Problem:** `localhost` not accessible

**Solutions:**
1. Ensure backend is running
2. Try using `127.0.0.1`:
   ```bash
   flutter run --dart-define=LEARNING_API_BASE_URL=http://127.0.0.1:3001/api/learning
   ```

### No Logs Appearing

**Problem:** HTTP logs not showing

**Solutions:**
1. Ensure running in debug mode (not release)
2. Check Flutter console output
3. Verify `kDebugMode` is true

### API Calls Failing

**Problem:** 404 or connection errors

**Solutions:**
1. Verify backend is running: `curl http://localhost:3001/api/learning/map`
2. Check API URL in logs matches backend
3. Verify `x-user-id` header is being sent (check logs)
4. Check backend CORS settings allow mobile app origin

---

## Build Commands

### Debug Build
```bash
flutter run
```

### Release Build
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

### Build with Custom API URL
```bash
flutter build apk --release --dart-define=LEARNING_API_BASE_URL=http://api.example.com/api/learning
```

---

## Verification Checklist

After running the app:

- [ ] App launches without errors
- [ ] Learning screens render (galaxy map, lessons, etc.)
- [ ] HTTP logs appear in console (debug builds)
- [ ] API calls succeed (check logs for 200 responses)
- [ ] Mock data fallback works if API unavailable
- [ ] User ID header is sent (check logs: `x-user-id: user_1`)

---

## Next Steps

1. **Test API Integration:**
   - Navigate to Learning screens
   - Verify data loads from backend
   - Check logs for successful API calls

2. **Disable Mock Fallback:**
   - Set `useMockFallback: false` in `LearningRepository`
   - Test error handling

3. **Add User Switching:**
   - Create UI to switch between `user_1`, `user_2`, etc.
   - Test multi-user scenarios

4. **Production Prep:**
   - Configure HTTPS
   - Set up proper API URL for production
   - Remove debug logging in release builds


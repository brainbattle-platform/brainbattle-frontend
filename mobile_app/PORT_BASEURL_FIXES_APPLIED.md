# Port/BaseURL Fixes Applied

## Changes Made

### 1. ✅ Fixed `api_base.dart` Emulator Port
**File:** `lib/core/network/api_base.dart:6`
- Changed: `http://10.0.2.2:3000` → `http://10.0.2.2:3001`
- Impact: Modules using `apiBase()` (auth, community) now work on emulator

### 2. ✅ Fixed `ApiConfig.learningBaseUrl` Real Device Support
**File:** `lib/core/api_config.dart:15-24`
- Added emulator detection using `IS_EMULATOR` flag
- Real device now uses LAN IP (default: `10.0.16.6`, override via `--dart-define=LAN_IP=...`)
- Impact: Learning feature can now connect on real Android device

### 3. ✅ Fixed Backend Network Binding
**File:** `brainbattle-dou/src/main.ts:27`
- Changed: `app.listen(3001)` → `app.listen(3001, '0.0.0.0')`
- Impact: Backend now accessible from network (required for real device)

---

## Verification Commands

### Backend
```bash
# Check if backend is listening on all interfaces
netstat -ano | findstr :3001
# Should show: TCP    0.0.0.0:3001    0.0.0.0:0    LISTENING

# Test from PC
curl http://localhost:3001/api/learning/map -H "x-user-id: user_1"

# Test from LAN IP (replace with your IP)
curl http://10.0.16.6:3001/api/learning/map -H "x-user-id: user_1"
```

### Flutter App
```bash
# Emulator (uses 10.0.2.2:3001)
flutter run --dart-define=IS_EMULATOR=true

# Real device (uses LAN IP)
flutter run --dart-define=IS_EMULATOR=false --dart-define=LAN_IP=10.0.16.6

# Or build APK for real device
flutter build apk --dart-define=IS_EMULATOR=false --dart-define=LAN_IP=10.0.16.6
```

---

## Next Steps

1. **Restart backend** to apply `0.0.0.0` binding
2. **Check firewall** allows port 3001 inbound
3. **Test on emulator** - should work immediately
4. **Test on real device** - ensure same WiFi network and correct LAN IP


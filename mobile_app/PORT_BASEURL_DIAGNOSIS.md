# Port/BaseURL Mismatch Diagnosis Report

## A) Backend Port Matrix

### Service: `brainbattle-dou` (NestJS)

| Service | Listen Port | Host Mapped Port | Container Port | Base Path | Bind Address |
|---------|-------------|------------------|----------------|-----------|--------------|
| **brainbattle-dou** | **3001** | **3001** (direct) | N/A (no Docker) | `/api` | **localhost** (default) |

**Configuration:**
- **File:** `brainbattle-dou/src/main.ts:27`
  ```typescript
  await app.listen(3001);
  ```
- **Global Prefix:** `brainbattle-dou/src/main.ts:11`
  ```typescript
  app.setGlobalPrefix('api');
  ```
- **Docker:** No containerization for NestJS service (only PostgreSQL in docker-compose)
- **Bind Address:** Default NestJS behavior binds to `localhost` (127.0.0.1), **NOT** `0.0.0.0`

**Endpoints:**
- Learning API: `http://localhost:3001/api/learning/*`
- Swagger: `http://localhost:3001/api/docs`

---

## B) Frontend URL Matrix

### Device Type → Computed Base URL → Final Endpoint

| Device Type | Config Source | Computed Base URL | Final Endpoint Example | Status |
|-------------|---------------|-------------------|------------------------|--------|
| **Android Emulator** | `api_base.dart` | `http://10.0.2.2:3000` | `http://10.0.2.2:3000/...` | ❌ **WRONG PORT** |
| **Android Emulator** | `ApiConfig.learningBaseUrl` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/map` | ✅ Correct |
| **Android Real Device** | `api_base.dart` | `http://10.0.16.6:3001` | `http://10.0.16.6:3001/...` | ✅ Correct |
| **Android Real Device** | `ApiConfig.learningBaseUrl` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/map` | ❌ **WRONG IP** |
| **iOS Simulator** | `ApiConfig.learningBaseUrl` | `http://localhost:3001/api/learning` | `http://localhost:3001/api/learning/map` | ✅ Correct |

**Configuration Files:**

1. **`lib/core/network/api_base.dart`** (Legacy, used by some modules):
   ```dart
   const String _lanPc = 'http://10.0.16.6:3001';  // ✅ Correct for real device
   const String _emu = 'http://10.0.2.2:3000';      // ❌ WRONG: Should be 3001
   ```

2. **`lib/core/api_config.dart`** (Used by Learning feature):
   ```dart
   // Android emulator: http://10.0.2.2:3001/api/learning  ✅ Correct
   // Android real device: http://10.0.2.2:3001/api/learning  ❌ WRONG: Should use LAN IP
   // iOS: http://localhost:3001/api/learning  ✅ Correct
   ```

**URL Construction:**
- `LearningApiClient` uses `ApiConfig.learningBaseUrl` which already includes `/api/learning`
- `HttpClientWithUser` appends path: `baseUrl + path`
- Example: `http://10.0.2.2:3001/api/learning` + `/map` = `http://10.0.2.2:3001/api/learning/map` ✅

---

## C) Issues Identified

### Issue 1: `api_base.dart` Emulator Port Mismatch
**File:** `lib/core/network/api_base.dart:6`
```dart
const String _emu = 'http://10.0.2.2:3000';  // ❌ Should be 3001
```
**Impact:** Modules using `apiBase()` (e.g., auth, community) will fail on emulator.

### Issue 2: `ApiConfig.learningBaseUrl` Real Device IP Mismatch
**File:** `lib/core/api_config.dart:17`
```dart
if (Platform.isAndroid) {
  return 'http://10.0.2.2:3001/api/learning';  // ❌ 10.0.2.2 only works for emulator
}
```
**Impact:** Learning feature cannot connect on real Android device (10.0.2.2 is emulator-only).

### Issue 3: Backend Binds to localhost Only
**File:** `brainbattle-dou/src/main.ts:27`
```typescript
await app.listen(3001);  // Binds to 127.0.0.1 by default
```
**Impact:** Real device cannot access backend even with correct IP (backend not listening on network interface).

---

## D) Fix Recommendations

### Fix 1: Update `api_base.dart` Emulator Port
**File:** `lib/core/network/api_base.dart:6`
```dart
// Before:
const String _emu = 'http://10.0.2.2:3000';

// After:
const String _emu = 'http://10.0.2.2:3001';
```

### Fix 2: Update `ApiConfig.learningBaseUrl` for Real Android Device
**File:** `lib/core/api_config.dart:15-17`
```dart
// Before:
if (Platform.isAndroid) {
  return 'http://10.0.2.2:3001/api/learning';
}

// After:
if (Platform.isAndroid) {
  // Check if emulator or real device
  const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
  if (isEmulator) {
    return 'http://10.0.2.2:3001/api/learning';
  } else {
    // Real device: use LAN IP (can be overridden via --dart-define)
    const lanIp = String.fromEnvironment('LAN_IP', defaultValue: '10.0.16.6');
    return 'http://$lanIp:3001/api/learning';
  }
}
```

**Alternative (Simpler):** Use `apiBase()` from `api_base.dart`:
```dart
if (Platform.isAndroid) {
  const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
  if (isEmulator) {
    return 'http://10.0.2.2:3001/api/learning';
  } else {
    // Use same logic as api_base.dart
    final base = apiBase(); // Returns http://10.0.16.6:3001
    return '$base/api/learning';
  }
}
```

### Fix 3: Backend Bind to 0.0.0.0 (Required for Real Device Access)
**File:** `brainbattle-dou/src/main.ts:27`
```typescript
// Before:
await app.listen(3001);

// After:
await app.listen(3001, '0.0.0.0');
```

**Why:** `0.0.0.0` makes NestJS listen on all network interfaces, allowing LAN devices to connect.

---

## E) Exact Code Changes

### Change 1: `lib/core/network/api_base.dart`
```dart
// Line 6: Change port from 3000 to 3001
const String _emu = 'http://10.0.2.2:3001';  // Changed from 3000
```

### Change 2: `lib/core/api_config.dart`
```dart
static String get learningBaseUrl {
  const envUrl = String.fromEnvironment('LEARNING_API_BASE_URL');
  if (envUrl.isNotEmpty) {
    return envUrl;
  }
  
  // Platform-specific defaults
  if (Platform.isAndroid) {
    // Check if emulator or real device
    const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
    if (isEmulator) {
      return 'http://10.0.2.2:3001/api/learning';
    } else {
      // Real device: use LAN IP
      const lanIp = String.fromEnvironment('LAN_IP', defaultValue: '10.0.16.6');
      return 'http://$lanIp:3001/api/learning';
    }
  } else if (Platform.isIOS) {
    return 'http://localhost:3001/api/learning';
  } else {
    return 'http://localhost:3001/api/learning';
  }
}
```

### Change 3: `brainbattle-dou/src/main.ts`
```typescript
// Line 27: Add '0.0.0.0' as host
await app.listen(3001, '0.0.0.0');
```

---

## F) Verification Steps

### Step 1: Verify Backend Listening Port
```bash
# On PC (where backend runs)
cd brainbattle-dou

# Check if port 3001 is listening
# Windows:
netstat -ano | findstr :3001

# Linux/Mac:
lsof -i :3001
# or
netstat -tuln | grep 3001

# Expected output should show:
# TCP    0.0.0.0:3001    0.0.0.0:0    LISTENING
```

### Step 2: Verify Backend Bind Address (After Fix 3)
```bash
# Start backend
cd brainbattle-dou
npm run start:dev

# Check logs - should show:
# BrainBattle Duo service is running on http://localhost:3001/api
# (But now listening on 0.0.0.0:3001, accessible from network)
```

### Step 3: Test from PC (localhost)
```bash
# Test health/learning endpoint
curl http://localhost:3001/api/learning/map -H "x-user-id: user_1"

# Expected: JSON response with map data
```

### Step 4: Test from PC (LAN IP)
```bash
# Replace 10.0.16.6 with your actual LAN IP
curl http://10.0.16.6:3001/api/learning/map -H "x-user-id: user_1"

# Before Fix 3: Connection refused (backend only on localhost)
# After Fix 3: Should return JSON response
```

### Step 5: Test from Android Emulator
```bash
# On PC, test emulator access
curl http://10.0.2.2:3001/api/learning/map -H "x-user-id: user_1"

# Expected: JSON response (emulator can access host via 10.0.2.2)
```

### Step 6: Test from Real Android Device
**Prerequisites:**
- Phone and PC on same WiFi network
- PC firewall allows inbound connections on port 3001
- Backend running with Fix 3 applied (listening on 0.0.0.0)

**Steps:**
1. Find PC LAN IP:
   ```bash
   # Windows:
   ipconfig | findstr IPv4
   
   # Linux/Mac:
   ifconfig | grep inet
   ```

2. Update Flutter config with correct LAN IP (or use `--dart-define=LAN_IP=<your-ip>`)

3. Build and install app on phone:
   ```bash
   flutter build apk --dart-define=LAN_IP=10.0.16.6
   # or use Fix 2 with default 10.0.16.6
   ```

4. Test from phone browser (optional):
   ```
   http://10.0.16.6:3001/api/docs
   ```

5. Test from app:
   - Open Learning feature
   - Check console logs for API calls
   - Verify map loads

### Step 7: Firewall Check (Windows)
```powershell
# Allow inbound on port 3001
New-NetFirewallRule -DisplayName "BrainBattle Backend" -Direction Inbound -LocalPort 3001 -Protocol TCP -Action Allow
```

---

## G) Quick Fix Summary

**Minimal changes required:**

1. ✅ **`api_base.dart:6`** - Change `3000` → `3001`
2. ✅ **`api_config.dart:15-17`** - Add real device LAN IP logic
3. ✅ **`main.ts:27`** - Change `listen(3001)` → `listen(3001, '0.0.0.0')`

**Testing:**
- Emulator: Should work after Fix 1
- Real device: Requires all 3 fixes + firewall + same WiFi

**Override for different LAN IP:**
```bash
flutter run --dart-define=LAN_IP=192.168.1.100
```

---

## H) Current vs. Fixed State

| Scenario | Current State | After Fixes |
|----------|---------------|-------------|
| **Emulator (api_base.dart)** | ❌ Port 3000 (wrong) | ✅ Port 3001 |
| **Emulator (ApiConfig)** | ✅ Port 3001 | ✅ Port 3001 |
| **Real Device (api_base.dart)** | ✅ LAN IP 3001 | ✅ LAN IP 3001 |
| **Real Device (ApiConfig)** | ❌ 10.0.2.2 (emulator IP) | ✅ LAN IP 3001 |
| **Backend Network Access** | ❌ localhost only | ✅ 0.0.0.0 (all interfaces) |

---

## I) Additional Notes

1. **Why 10.0.2.2?** Android emulator uses this special IP to access host machine's localhost.

2. **Why 0.0.0.0?** Makes backend accessible from network, not just localhost.

3. **LAN IP Detection:** Could be automated, but using `--dart-define` is simpler for MVP.

4. **Production:** Use environment variables or config service for base URLs.

5. **Security:** Binding to 0.0.0.0 exposes backend to network. For production, use reverse proxy (nginx) or restrict firewall rules.


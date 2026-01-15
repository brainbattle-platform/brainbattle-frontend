# AuthApiService Usage Guide

## Files Created

1. **`lib/features/auth/data/auth_api.dart`** - Dio-based API service
2. **`lib/features/auth/data/models/auth_user.dart`** - AuthUser model
3. **`lib/features/auth/data/services/user_session.dart`** - UserSession service for SharedPreferences

## Files Modified

1. **`lib/features/auth/login/login_repository.dart`** - Updated to use AuthApiService
2. **`lib/features/auth/login/login_controller.dart`** - Updated to use new repository
3. **`lib/features/auth/login/login_page.dart`** - Changed from email to username
4. **`pubspec.yaml`** - Added `dio: ^5.4.0` dependency

## Base URL Configuration

The `AuthApiService` automatically detects the environment:

- **Android Emulator**: `http://10.0.2.2:4001`
- **iOS Simulator**: `http://localhost:4001`
- **Physical Device**: Uses `AUTH_BASE_URL` constant (default: `http://10.0.16.6:4001`)

To change the base URL for physical devices, edit the constant in `auth_api.dart`:

```dart
const String AUTH_BASE_URL = 'http://YOUR_PC_IP:4001';
```

Or use environment variable when running:

```bash
flutter run --dart-define=AUTH_BASE_URL=http://192.168.1.100:4001
```

## Usage in Login Page

The login page has been updated to use username instead of email. The flow is:

1. User enters username and password
2. `LoginController.login()` is called
3. `LoginRepository.login()` calls `AuthApiService.login()`
4. On success, `userId` is saved to `UserSession` (SharedPreferences)
5. User is navigated to MainShell

## Code Snippets

### 1. Direct Usage of AuthApiService

```dart
import 'package:brainbattle/features/auth/data/auth_api.dart';
import 'package:brainbattle/features/auth/data/models/auth_user.dart';
import 'package:brainbattle/features/auth/data/services/user_session.dart';

// Login
final authApi = AuthApiService();
final userSession = UserSession.instance;

try {
  final user = await authApi.login(
    username: 'user1',
    password: '123456',
  );
  
  // Save userId to SharedPreferences
  await userSession.saveUserId(user.id);
  
  print('Logged in: ${user.displayName}');
} catch (e) {
  print('Login failed: $e');
}

// Signup
try {
  final user = await authApi.signup(
    username: 'newuser',
    password: 'password123',
    displayName: 'New User', // Optional
  );
  
  await userSession.saveUserId(user.id);
  
  print('Signed up: ${user.displayName}');
} catch (e) {
  print('Signup failed: $e');
}
```

### 2. Using LoginRepository (Recommended)

```dart
import 'package:brainbattle/features/auth/login/login_repository.dart';
import 'package:brainbattle/features/auth/data/models/auth_user.dart';

final repo = LoginRepository();

try {
  // Login
  final user = await repo.login('user1', '123456');
  print('Logged in: ${user.displayName}');
  
  // Signup
  final newUser = await repo.signup(
    username: 'newuser',
    password: 'password123',
    displayName: 'New User',
  );
  print('Signed up: ${newUser.displayName}');
} catch (e) {
  print('Error: $e');
}
```

### 3. Check if User is Logged In

```dart
import 'package:brainbattle/features/auth/data/services/user_session.dart';

final userSession = UserSession.instance;

// Check login status
final isLoggedIn = await userSession.isLoggedIn();
if (isLoggedIn) {
  final userId = await userSession.getUserId();
  print('User ID: $userId');
} else {
  print('Not logged in');
}

// Clear session (logout)
await userSession.clear();
```

### 4. Using in LoginController (Current Implementation)

```dart
// In login_page.dart
final ok = await _vm.login(_username.text.trim(), _password.text);
if (ok) {
  // Login successful, userId is already saved
  Navigator.of(context).pushReplacementNamed(
    MainShell.routeName,
    arguments: {'initialIndex': 2},
  );
} else {
  // Show error from _vm.error.value
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(_vm.error.value ?? 'Login failed')),
  );
}
```

## Response Format

### Login Response (from auth-service)

```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "username": "user1",
  "displayName": "User 1"
}
```

### Signup Response (from auth-service)

```json
{
  "userId": "123e4567-e89b-12d3-a456-426614174000",
  "username": "newuser",
  "displayName": "New User"
}
```

## Error Handling

The `AuthApiService` throws `DioException` on errors:

- **401 Unauthorized**: "Invalid username or password"
- **400 Bad Request**: Error message from server
- **Network errors**: Connection timeout or network unavailable

Example error handling:

```dart
try {
  final user = await authApi.login(username: 'user1', password: 'wrong');
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    print('Invalid credentials');
  } else {
    print('Error: ${e.error}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

## Testing

### Test Login Endpoint

```bash
curl -X POST http://localhost:4001/auth/simple/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user1", "password": "123456"}'
```

### Test Signup Endpoint

```bash
curl -X POST http://localhost:4001/auth/simple/signup \
  -H "Content-Type: application/json" \
  -d '{"username": "newuser", "password": "123456", "displayName": "New User"}'
```

## Notes

- The `userId` is automatically saved to SharedPreferences on successful login/signup
- The service uses Dio for HTTP requests with proper error handling
- Base URL is automatically configured based on platform
- All responses are parsed into `AuthUser` model


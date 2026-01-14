import 'dart:io';

/// Centralized API configuration
/// Supports platform-specific URLs and --dart-define overrides
class ApiConfig {
  // Base URL for Learning service (NestJS, port 3001)
  // Can be overridden via --dart-define=LEARNING_API_BASE_URL=http://...
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
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return 'http://10.0.2.2:3001/api/learning';
      } else {
        // Real device: use LAN IP (can be overridden via --dart-define=LAN_IP=...)
        const lanIp = String.fromEnvironment('LAN_IP', defaultValue: '10.0.16.6');
        return 'http://$lanIp:3001/api/learning';
      }
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost directly
      return 'http://localhost:3001/api/learning';
    } else {
      // Desktop/web fallback
      return 'http://localhost:3001/api/learning';
    }
  }

  // Base URL for Short-video service (NestJS, port 3003)
  // Can be overridden via --dart-define=SHORT_VIDEO_API_BASE_URL=http://...
  static String get shortVideoBaseUrl {
    const envUrl = String.fromEnvironment('SHORT_VIDEO_API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Platform-specific defaults
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3003/api/short-video';
    } else if (Platform.isIOS) {
      return 'http://localhost:3003/api/short-video';
    } else {
      return 'http://localhost:3003/api/short-video';
    }
  }

  // Legacy: Duo service (deprecated, use learningBaseUrl instead)
  @Deprecated('Use learningBaseUrl instead')
  static String get duoBaseUrl => learningBaseUrl.replaceAll('/learning', '/duo');
}

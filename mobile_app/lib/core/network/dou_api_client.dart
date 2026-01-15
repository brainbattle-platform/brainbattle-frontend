import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../features/auth/data/services/user_session.dart';

/// Base URL configuration for dou-service (learning API)
/// 
/// - Android emulator: http://10.0.2.2:4003
/// - iOS simulator: http://localhost:4003
/// - Device: Use DOU_BASE_URL constant (default: http://10.0.16.6:4003)
const String DOU_BASE_URL = 'http://10.0.16.6:4003'; // Change this to your PC IP for physical devices

String _getDouBaseUrl() {
  // Check environment variable first
  const fromEnv = String.fromEnvironment('DOU_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) {
    return 'http://localhost:4003';
  }

  if (Platform.isAndroid) {
    // Android emulator uses 10.0.2.2 to access host machine
    const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
    return isEmulator ? 'http://10.0.2.2:4003' : DOU_BASE_URL;
  }

  if (Platform.isIOS) {
    // iOS simulator uses localhost
    return 'http://localhost:4003';
  }

  // Default fallback
  return DOU_BASE_URL;
}

/// Dio client for dou-service (learning API)
/// Automatically adds x-user-id header from UserSession
class DouApiClient {
  late final Dio _dio;
  final String _baseUrl;

  DouApiClient() : _baseUrl = _getDouBaseUrl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptor to automatically include x-user-id header
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get userId from UserSession
          final userId = await UserSession.instance.getUserId();
          if (userId != null && userId.isNotEmpty) {
            options.headers['x-user-id'] = userId;
            if (kDebugMode) {
              debugPrint('[DouApiClient] Request: ${options.method} ${options.path}');
              debugPrint('[DouApiClient] Headers: x-user-id=$userId');
            }
          } else {
            if (kDebugMode) {
              debugPrint('[DouApiClient] Warning: No userId found in session');
            }
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint('[DouApiClient] Error: ${error.message}');
            if (error.response != null) {
              debugPrint('[DouApiClient] Status: ${error.response!.statusCode}');
              debugPrint('[DouApiClient] Body: ${error.response!.data}');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get learning map
  Future<Map<String, dynamic>> getMap() async {
    try {
      final response = await _dio.get('/learning/map');
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DouApiClient] getMap error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get lesson modes
  Future<Map<String, dynamic>> getLessonModes(String lessonId) async {
    try {
      final response = await _dio.get('/learning/lessons/$lessonId/modes');
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DouApiClient] getLessonModes error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Start a lesson
  Future<Map<String, dynamic>> startLesson(String lessonId, {String? mode}) async {
    try {
      final response = await _dio.post(
        '/learning/lessons/$lessonId/start',
        data: mode != null ? {'mode': mode} : {},
      );
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DouApiClient] startLesson error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get profile overview
  Future<Map<String, dynamic>> getProfileOverview() async {
    try {
      final response = await _dio.get('/learning/profile/overview');
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DouApiClient] getProfileOverview error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get recent attempts
  Future<Map<String, dynamic>> getRecentAttempts({int limit = 10}) async {
    try {
      final response = await _dio.get('/learning/profile/recent-attempts', queryParameters: {'limit': limit});
      return response.data;
    } on DioException catch (e) {
      if (kDebugMode) {
        debugPrint('[DouApiClient] getRecentAttempts error: ${e.message}');
      }
      rethrow;
    }
  }

  /// Get base URL (for debugging)
  String get baseUrl => _baseUrl;
}


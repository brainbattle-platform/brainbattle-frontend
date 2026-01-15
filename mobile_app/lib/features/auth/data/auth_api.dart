import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'models/auth_user.dart';

/// Base URL configuration for auth service
/// 
/// - Android emulator: http://10.0.2.2:4001
/// - iOS simulator: http://localhost:4001
/// - Device: Use AUTH_BASE_URL constant (default: http://10.0.16.6:4001)
const String AUTH_BASE_URL = 'http://10.0.16.6:4001'; // Change this to your PC IP for physical devices

String _getAuthBaseUrl() {
  // Check environment variable first
  const fromEnv = String.fromEnvironment('AUTH_BASE_URL', defaultValue: '');
  if (fromEnv.isNotEmpty) return fromEnv;

  if (kIsWeb) {
    return 'http://localhost:4001';
  }

  if (Platform.isAndroid) {
    // Android emulator uses 10.0.2.2 to access host machine
    const isEmulator = bool.fromEnvironment('IS_EMULATOR', defaultValue: false);
    return isEmulator ? 'http://10.0.2.2:4001' : AUTH_BASE_URL;
  }

  if (Platform.isIOS) {
    // iOS simulator uses localhost
    return 'http://localhost:4001';
  }

  // Default fallback
  return AUTH_BASE_URL;
}

/// Auth API Service using Dio
class AuthApiService {
  late final Dio _dio;
  final String _baseUrl;

  AuthApiService() : _baseUrl = _getAuthBaseUrl() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add error interceptor for better error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          if (error.response != null) {
            // Server responded with error
            final data = error.response!.data;
            
            String message = 'Request failed';
            if (data is Map<String, dynamic>) {
              message = data['message'] as String? ?? 
                       data['error'] as String? ?? 
                       message;
            } else if (data is String) {
              message = data;
            }

            error = DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: message,
            );
          } else {
            // Network error
            error = DioException(
              requestOptions: error.requestOptions,
              type: DioExceptionType.connectionTimeout,
              error: 'Network error: ${error.message}',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Login with username and password
  /// 
  /// Returns AuthUser on success
  /// Throws DioException on error
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/simple/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle both direct response and wrapped response
        final userData = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        
        return AuthUser.fromJson(userData);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      // Re-throw with better error message
      if (e.response?.statusCode == 401) {
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: DioExceptionType.badResponse,
          error: 'Invalid username or password',
        );
      }
      rethrow;
    }
  }

  /// Sign up with username, password, and optional displayName
  /// 
  /// Returns AuthUser on success
  /// Throws DioException on error
  Future<AuthUser> signup({
    required String username,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/simple/signup',
        data: {
          'username': username,
          'password': password,
          if (displayName != null) 'displayName': displayName,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        // Handle both direct response and wrapped response
        final userData = data is Map<String, dynamic> && data.containsKey('data')
            ? data['data'] as Map<String, dynamic>
            : data as Map<String, dynamic>;
        
        return AuthUser.fromJson(userData);
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Unexpected response status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      // Re-throw with better error message
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        String message = 'Signup failed';
        if (data is Map<String, dynamic>) {
          message = data['message'] as String? ?? 
                   (data['error'] is Map ? (data['error'] as Map)['message'] : null) ??
                   message;
        }
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: DioExceptionType.badResponse,
          error: message,
        );
      }
      rethrow;
    }
  }

  /// Get base URL (for debugging)
  String get baseUrl => _baseUrl;
}


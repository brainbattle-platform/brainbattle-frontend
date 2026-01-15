import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/auth_api.dart';
import '../data/models/auth_user.dart';
import '../data/services/user_session.dart';

class LoginRepository {
  final AuthApiService _api;
  final UserSession _session;

  LoginRepository({
    AuthApiService? api,
    UserSession? session,
  })  : _api = api ?? AuthApiService(),
        _session = session ?? UserSession.instance;

  /// Login with username and password
  /// 
  /// Returns AuthUser on success
  /// Saves userId to UserSession (in-memory) and SharedPreferences (persist)
  /// Throws exception on error
  Future<AuthUser> login(String username, String password) async {
    try {
      final user = await _api.login(username: username, password: password);
      
      // Save userId to UserSession (SharedPreferences for persistence)
      await _session.saveUserId(user.id);
      
      // Log for debugging
      if (kDebugMode) {
        print('[LoginRepository] Login successful, userId saved: ${user.id}');
      }
      
      return user;
    } catch (e) {
      // Re-throw with better error message
      if (e is DioException) {
        throw Exception(e.error?.toString() ?? 'Login failed');
      }
      rethrow;
    }
  }

  /// Sign up with username, password, and optional displayName
  /// 
  /// Returns AuthUser on success
  /// Saves userId to UserSession and SharedPreferences
  /// Throws exception on error
  Future<AuthUser> signup({
    required String username,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await _api.signup(
        username: username,
        password: password,
        displayName: displayName,
      );
      
      // Save userId to UserSession (SharedPreferences)
      await _session.saveUserId(user.id);
      
      return user;
    } catch (e) {
      // Re-throw with better error message
      if (e is DioException) {
        throw Exception(e.error?.toString() ?? 'Signup failed');
      }
      rethrow;
    }
  }
}

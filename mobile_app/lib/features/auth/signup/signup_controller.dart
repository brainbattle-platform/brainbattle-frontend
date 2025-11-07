import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/network/api_base.dart';

final _base = apiBase();

class SignUpController {
  final loading = ValueNotifier<bool>(false);
  final error = ValueNotifier<String?>(null);

  String? get errorMessage => error.value;

  void dispose() {
    loading.dispose();
    error.dispose();
  }

  /// B1: Gửi OTP (đăng ký khởi tạo)
  Future<bool> startRegistration(String email) async {
    loading.value = true;
    error.value = null;
    try {
      final resp = await http.post(
        Uri.parse('$_base/auth/register/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return true;
      }
      error.value = _extractMessage(resp.body).ifEmpty('Failed to send code');
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// B1.1: Gửi lại OTP (tuỳ chọn)
  Future<bool> resendOtp(String email) async {
    loading.value = true;
    error.value = null;
    try {
      // Tuỳ BE: có thể dùng lại /auth/register/start
      final resp = await http.post(
        Uri.parse('$_base/auth/register/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      if (resp.statusCode >= 200 && resp.statusCode < 300) return true;
      error.value = _extractMessage(resp.body).ifEmpty('Cannot resend code');
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// B3: Hoàn tất đăng ký (verify + tạo mật khẩu/displayName)
  Future<bool> completeRegistration({
    required String email,
    required String otp,
    required String password,
    required String displayName,
  }) async {
    loading.value = true;
    error.value = null;
    try {
      final resp = await http.post(
        Uri.parse('$_base/auth/register/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'password': password,
          'displayName': displayName,
        }),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        // Có thể parse token/user ở đây nếu BE trả về
        return true;
      }
      error.value = _extractMessage(resp.body).ifEmpty('Register failed');
      return false;
    } catch (e) {
      error.value = e.toString();
      return false;
    } finally {
      loading.value = false;
    }
  }

  String _extractMessage(String body) {
    try {
      final j = jsonDecode(body);
      if (j is Map && j['message'] != null) {
        final m = j['message'];
        if (m is String) return m;
        if (m is List && m.isNotEmpty) return m.first.toString();
      }
    } catch (_) {}
    return '';
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

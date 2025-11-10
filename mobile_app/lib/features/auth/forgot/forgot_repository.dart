import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gọi đúng 2 endpoint từ BE:
/// - POST /auth/forgot/start    { email }
/// - POST /auth/forgot/verify   { email, otp, newPassword }
class ForgotRepository {
  ForgotRepository({required this.baseUrl});
  /// ví dụ: http://192.168.1.34:3000  (nhớ có http://)
  final String baseUrl;

  Future<(bool ok, String? message)> start(String email) async {
    final uri = Uri.parse('$baseUrl/auth/forgot/start');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );

    if (res.statusCode == 204 || (res.statusCode >= 200 && res.statusCode < 300)) {
      return (true, null);
    }
    try {
      final data = jsonDecode(res.body);
      return (false, data['message']?.toString() ?? 'Start failed');
    } catch (_) {
      return (false, 'Start failed (${res.statusCode})');
    }
  }

  Future<String?> verify({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/auth/forgot/verify');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      }),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return null; // ok
    }
    try {
      final data = jsonDecode(res.body);
      return data['message']?.toString() ?? 'Verify failed';
    } catch (_) {
      return 'Verify failed (${res.statusCode})';
    }
  }
}

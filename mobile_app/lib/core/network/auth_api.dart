import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_base.dart';

class AuthApi {
  final _base = apiBase();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$_base/auth/login');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    try {
      final body = jsonDecode(res.body);
      final msg = body['message'] ?? body['error'] ?? 'Login failed';
      throw Exception(msg);
    } catch (_) {
      throw Exception('Login failed (${res.statusCode})');
    }
  }
}

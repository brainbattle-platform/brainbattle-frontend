// lib/features/community/data/community_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

class CommunityApi {
  final String baseUrlMessaging;
  final String baseUrlCore;
  final String currentUserId;

  CommunityApi({
    required this.baseUrlMessaging,
    required this.baseUrlCore,
    this.currentUserId = 'me', // MVP fallback
  });

  // Messaging service methods
  Future<http.Response> getMessaging(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrlMessaging$path').replace(queryParameters: params);
    final headers = _headers();
    return _send(() => http.get(uri, headers: headers));
  }

  Future<http.Response> postMessaging(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrlMessaging$path');
    final headers = _headers();
    return _send(() => http.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    ));
  }

  // Core service methods
  Future<http.Response> getCore(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrlCore$path').replace(queryParameters: params);
    final headers = _headers();
    return _send(() => http.get(uri, headers: headers));
  }

  Future<http.Response> postCore(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrlCore$path');
    final headers = _headers();
    return _send(() => http.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    ));
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final res = await call();
      if (res.statusCode >= 400) {
        throw ApiException(res.statusCode, _extractError(res.body));
      }
      return res;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      'x-user-id': currentUserId,
    };
  }

  String _extractError(String body) {
    try {
      final json = jsonDecode(body);
      if (json['error'] != null) {
        return json['error']['message'] ?? 'Unknown error';
      }
      return 'HTTP Error';
    } catch (_) {
      return 'HTTP Error';
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

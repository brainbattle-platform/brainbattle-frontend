// lib/features/community/data/community_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

typedef Json = Map<String, dynamic>;

class CommunityApi {
  final String baseUrl;
  final Future<String?> Function()? tokenProvider;
  CommunityApi({required this.baseUrl, this.tokenProvider});

  Future<http.Response> get(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: params);
    final headers = await _headers();                       // await ở đây
    return _send(() => http.get(uri, headers: headers));
  }

  Future<http.Response> post(String path, {Object? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = await _headers();                       // await ở đây
    return _send(() => http.post(
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    ));
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final res = await call();
    // TODO: retry / error mapping nếu cần
    return res;
  }

  Future<Map<String, String>> _headers() async {
    final token = await (tokenProvider?.call());
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }
}

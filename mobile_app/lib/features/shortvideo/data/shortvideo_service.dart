import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/api_config.dart';
import 'package:mobile_app/core/network/http_client_with_user.dart';

import 'shortvideo_model.dart';

class ShortVideoService {
  final HttpClientWithUser _httpClient = HttpClientWithUser(
    baseUrl: ApiConfig.shortVideoBaseUrl,
  );

  Future<List<ShortVideo>> fetchFeed({int page = 1}) async {
    final response = await _httpClient.get(
      '/feed',
      queryParameters: {'page': page.toString(), 'pageSize': '10'},
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load short-video feed: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => ShortVideo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

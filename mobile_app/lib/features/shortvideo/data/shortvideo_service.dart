import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/api_config.dart';

import 'shortvideo_model.dart';

class ShortVideoService {
  Future<List<ShortVideo>> fetchFeed({int page = 1}) async {
    final url = Uri.parse(
      '${ApiConfig.shortVideoBaseUrl}/feed?page=$page&pageSize=10',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load short-video feed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => ShortVideo.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

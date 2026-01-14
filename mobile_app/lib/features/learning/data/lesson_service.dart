import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/api_config.dart';

import 'lesson_model.dart';

/// Legacy lesson service
/// Note: This service uses old API endpoints. Consider migrating to LearningApiClient.
@Deprecated('Use LearningApiClient instead')
class LessonService {
  // tạm mặc định skillId = 11 giống backend
  Future<List<Lesson>> fetchLessons({int skillId = 11}) async {
    // Updated to use learningBaseUrl, but endpoint structure may need updating
    final url =
        Uri.parse('${ApiConfig.learningBaseUrl}/skills/$skillId/lessons');

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception(
          'Failed to load lessons: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

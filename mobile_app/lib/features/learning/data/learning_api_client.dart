import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/api_config.dart';
import '../../../core/network/http_client_with_user.dart';
import '../../../core/utils/json_num.dart';
import '../domain/exercise_model.dart';
import 'unit_model.dart';
import 'lesson_model.dart';
import '../widgets/skill_planet.dart';

/// Result type for nextQuizQuestion
class NextQuestionResult {
  final bool hasQuestion;
  final Map<String, dynamic>? questionData;
  
  NextQuestionResult.finished() : hasQuestion = false, questionData = null;
  NextQuestionResult.withQuestion(this.questionData) : hasQuestion = true;
}

/// API client for learning endpoints
/// Automatically includes x-user-id header in all requests
class LearningApiClient {
  final String baseUrl;
  final HttpClientWithUser _httpClient;

  LearningApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConfig.learningBaseUrl,
        _httpClient = HttpClientWithUser(baseUrl: baseUrl ?? ApiConfig.learningBaseUrl);

  /// Debug logging helper
  void _logApiCall(String method, String path) {
    if (kDebugMode) {
      debugPrint('[Learning API] $method $path');
    }
  }

  /// Get units for a domain
  Future<List<Unit>> getUnits({String domainId = 'english'}) async {
    try {
      final response = await _httpClient.get('/domains/$domainId/units').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load units: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => _unitFromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to mock on error
      rethrow;
    }
  }

  /// Get lessons for a unit
  Future<List<Lesson>> getLessons({required String unitId}) async {
    try {
      final response = await _httpClient.get('/units/$unitId/lessons').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load lessons: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get exercise items for a lesson
  Future<List<ExerciseItem>> getItems({required String lessonId}) async {
    try {
      final response = await _httpClient.get('/lessons/$lessonId/items').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load items: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((e) => _exerciseItemFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Helper: Parse Unit from JSON
  Unit _unitFromJson(Map<String, dynamic> json) {
    final lessons = (json['lessons'] as List<dynamic>?)
            ?.map((e) => Lesson.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return Unit(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      color: _parseColor(json['color']),
      lessons: lessons,
    );
  }

  /// Helper: Parse ExerciseItem from JSON
  ExerciseItem _exerciseItemFromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      id: json['id']?.toString() ?? '',
      type: _parseExerciseType(json['type']),
      skill: _parseSkill(json['skill']),
      question: json['question'] ?? '',
      questionAudio: json['audioUrl'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      explanation: json['explanation'] as String?,
      hint: json['hint'] as String?,
      timeLimit: JsonNum.asIntOr(json['timeLimit'], 0),
    );
  }

  ExerciseType _parseExerciseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'mcq':
      case 'multiple_choice':
        return ExerciseType.mcq;
      case 'fill':
      case 'fill_blank':
        return ExerciseType.fill;
      case 'match':
      case 'matching':
        return ExerciseType.match;
      case 'listen':
      case 'listening':
        return ExerciseType.listen;
      default:
        return ExerciseType.mcq;
    }
  }

  Skill _parseSkill(String? skill) {
    switch (skill?.toLowerCase()) {
      case 'listening':
        return Skill.listening;
      case 'speaking':
        return Skill.speaking;
      case 'reading':
        return Skill.reading;
      case 'writing':
        return Skill.writing;
      default:
        return Skill.reading;
    }
  }

  Color _parseColor(dynamic color) {
    if (color is String) {
      // Parse hex color like "#FF0000"
      final hex = color.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    // Default color
    return const Color(0xFFFFD166);
  }

  // ========== New Learning Service API Methods (from Figma spec) ==========

  /// GET /learning/map - Get learning map (Figma 5.1)
  Future<Map<String, dynamic>> getLearningMap() async {
    _logApiCall('GET', '/map');
    try {
      final response = await _httpClient.get('/map').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load learning map: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper: {success: true, data: {...}}
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/units/{unitId}/skills - Get skills for a unit
  Future<List<Map<String, dynamic>>> getSkillsForUnit(String unitId) async {
    try {
      final response = await _httpClient.get('/units/$unitId/skills').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load skills: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['data'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/skills/{skillId}/modes - Get available modes for a skill (Figma 5.2)
  Future<Map<String, dynamic>> getModesForSkill(String skillId) async {
    _logApiCall('GET', '/skills/$skillId/modes');
    try {
      final response = await _httpClient.get('/skills/$skillId/modes').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load modes: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/lessons/{lessonId} - Get lesson detail (Figma 5.3)
  Future<Map<String, dynamic>> getLessonDetail(String lessonId) async {
    _logApiCall('GET', '/lessons/$lessonId');
    try {
      final response = await _httpClient.get('/lessons/$lessonId').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load lesson: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/lessons/{lessonId}/overview - Get lesson overview (Figma 5.4)
  Future<Map<String, dynamic>> getLessonOverview(String lessonId, {String? mode}) async {
    final path = mode != null 
        ? '/lessons/$lessonId/overview?mode=$mode'
        : '/lessons/$lessonId/overview';
    _logApiCall('GET', path);
    try {
      final response = await _httpClient.get(
        '/lessons/$lessonId/overview',
        queryParameters: mode != null ? {'mode': mode} : null,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load lesson overview: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/lessons/{lessonId}/start - Start a lesson
  Future<Map<String, dynamic>> startLesson(String lessonId, {String? mode}) async {
    _logApiCall('POST', '/lessons/$lessonId/start');
    try {
      final body = mode != null ? {'mode': mode} : {};
      final response = await _httpClient.post(
        '/lessons/$lessonId/start',
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to start lesson: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper: {ok: true, data: {...}, error: null}
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/quiz/start - Start a quiz attempt (Figma 5.5)
  Future<Map<String, dynamic>> startQuiz(String lessonId, {String? mode}) async {
    _logApiCall('POST', '/quiz/start');
    try {
      final body = {
        'lessonId': lessonId,
        if (mode != null) 'mode': mode,
      };
      final response = await _httpClient.post(
        '/quiz/start',
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to start quiz: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/quiz/{attemptId}/question - Get current question
  Future<Map<String, dynamic>> getQuizQuestion(String attemptId) async {
    _logApiCall('GET', '/quiz/$attemptId/question');
    try {
      final response = await _httpClient.get('/quiz/$attemptId/question').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load question: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/quiz/{attemptId}/answer - Submit answer (Figma 5.6)
  Future<Map<String, dynamic>> submitQuizAnswer(String attemptId, dynamic answer) async {
    _logApiCall('POST', '/quiz/$attemptId/answer');
    try {
      final body = {'answer': answer};
      final response = await _httpClient.post(
        '/quiz/$attemptId/answer',
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit answer: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/quiz/{attemptId}/next - Move to next question
  /// Returns NextQuestionResult: finished if no more questions, withQuestion if has next question
  /// Treats 404 with "No more questions" as normal condition (finished), not error
  Future<NextQuestionResult> nextQuizQuestion(String attemptId) async {
    _logApiCall('POST', '/quiz/$attemptId/next');
    try {
      final response = await _httpClient.post('/quiz/$attemptId/next').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      // Handle 404 as "finished" (normal condition, not error)
      if (response.statusCode == 404) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final error = data['error'] as Map<String, dynamic>?;
        final message = error?['message'] as String? ?? '';
        if (message.contains('No more questions') || message.contains('finished') || message.contains('completed')) {
          return NextQuestionResult.finished();
        }
        // Other 404 errors still throw
        throw Exception('Failed to get next question: ${response.statusCode}');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to get next question: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      final questionData = data.containsKey('data') ? data['data'] as Map<String, dynamic> : data;
      
      // Check if response contains a question
      final question = questionData['question'] as Map<String, dynamic>?;
      if (question == null) {
        return NextQuestionResult.finished();
      }
      
      return NextQuestionResult.withQuestion(questionData);
    } catch (e) {
      // Re-throw non-404 errors
      rethrow;
    }
  }

  /// POST /learning/quiz/{attemptId}/finish - Finish quiz
  Future<Map<String, dynamic>> finishQuiz(String attemptId) async {
    _logApiCall('POST', '/quiz/$attemptId/finish');
    try {
      final response = await _httpClient.post('/quiz/$attemptId/finish').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to finish quiz: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/hearts - Get hearts status
  Future<Map<String, dynamic>> getHearts() async {
    _logApiCall('GET', '/hearts');
    try {
      final response = await _httpClient.get('/hearts').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load hearts: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/hearts/consume - Consume a heart
  Future<Map<String, dynamic>> consumeHeart() async {
    _logApiCall('POST', '/hearts/consume');
    try {
      final response = await _httpClient.post('/hearts/consume').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to consume heart: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/hearts/recover - Recover hearts
  Future<Map<String, dynamic>> recoverHearts() async {
    _logApiCall('POST', '/hearts/recover');
    try {
      final response = await _httpClient.post('/hearts/recover').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to recover hearts: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// GET /learning/practice/hub - Get practice hub (Figma 5.8)
  Future<Map<String, dynamic>> getPracticeHub() async {
    _logApiCall('GET', '/practice/hub');
    try {
      final response = await _httpClient.get('/practice/hub').timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load practice hub: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// POST /learning/practice/start - Start practice session
  Future<Map<String, dynamic>> startPractice(String practiceType, {String? targetId}) async {
    _logApiCall('POST', '/practice/start');
    try {
      final body = {
        'practiceType': practiceType,
        if (targetId != null) 'targetId': targetId,
      };
      final response = await _httpClient.post(
        '/practice/start',
        body: body,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to start practice: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // Handle response wrapper
      if (data.containsKey('data')) {
        return data['data'] as Map<String, dynamic>;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }
}


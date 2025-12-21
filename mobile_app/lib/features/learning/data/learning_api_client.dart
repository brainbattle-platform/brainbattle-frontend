import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/api_config.dart';
import '../domain/exercise_model.dart';
import '../domain/domain_model.dart';
import 'unit_model.dart';
import 'lesson_model.dart';
import '../widgets/skill_planet.dart';

/// API client for learning endpoints
class LearningApiClient {
  final String baseUrl;

  LearningApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConfig.duoBaseUrl;

  /// Get units for a domain
  Future<List<Unit>> getUnits({String domainId = 'english'}) async {
    try {
      final url = Uri.parse('$baseUrl/domains/$domainId/units');
      final response = await http.get(url).timeout(
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
      final url = Uri.parse('$baseUrl/units/$unitId/lessons');
      final response = await http.get(url).timeout(
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
      final url = Uri.parse('$baseUrl/lessons/$lessonId/items');
      final response = await http.get(url).timeout(
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
      timeLimit: json['timeLimit'] as int? ?? 0,
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
}


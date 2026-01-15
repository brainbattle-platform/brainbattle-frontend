import 'package:flutter/foundation.dart';
import '../../../core/network/dou_api_client.dart';

/// Repository for learning map data
class LearningMapRepository {
  final DouApiClient _api;

  LearningMapRepository({DouApiClient? api}) : _api = api ?? DouApiClient();

  /// Get learning map
  /// 
  /// Returns map data with units and lessons
  /// Automatically includes x-user-id header via DouApiClient
  Future<Map<String, dynamic>> getMap() async {
    try {
      if (kDebugMode) {
        print('[LearningMapRepository] Fetching learning map...');
      }
      
      final response = await _api.getMap();
      
      if (kDebugMode) {
        print('[LearningMapRepository] Map fetched successfully');
        print('[LearningMapRepository] Response status: ${response['success'] ?? 'N/A'}');
        final data = response['data'] ?? response;
        final units = data['units'] ?? [];
        print('[LearningMapRepository] Units count: ${units.length}');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[LearningMapRepository] Error fetching map: $e');
      }
      rethrow;
    }
  }

  /// Get lesson modes
  Future<Map<String, dynamic>> getLessonModes(String lessonId) async {
    try {
      if (kDebugMode) {
        print('[LearningMapRepository] Fetching lesson modes for: $lessonId');
      }
      
      final response = await _api.getLessonModes(lessonId);
      
      if (kDebugMode) {
        print('[LearningMapRepository] Lesson modes fetched successfully');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[LearningMapRepository] Error fetching lesson modes: $e');
      }
      rethrow;
    }
  }

  /// Start a lesson
  Future<Map<String, dynamic>> startLesson(String lessonId, {String? mode}) async {
    try {
      if (kDebugMode) {
        print('[LearningMapRepository] Starting lesson: $lessonId, mode: $mode');
      }
      
      final response = await _api.startLesson(lessonId, mode: mode);
      
      if (kDebugMode) {
        print('[LearningMapRepository] Lesson started successfully');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[LearningMapRepository] Error starting lesson: $e');
      }
      rethrow;
    }
  }

  /// Get profile overview
  Future<Map<String, dynamic>> getProfileOverview() async {
    try {
      if (kDebugMode) {
        print('[LearningMapRepository] Fetching profile overview...');
      }
      
      final response = await _api.getProfileOverview();
      
      if (kDebugMode) {
        print('[LearningMapRepository] Profile overview fetched successfully');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('[LearningMapRepository] Error fetching profile overview: $e');
      }
      rethrow;
    }
  }
}


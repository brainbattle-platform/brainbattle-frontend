import '../domain/exercise_model.dart';
import '../domain/domain_model.dart';
import 'unit_model.dart';
import 'lesson_model.dart';
import 'learning_api_client.dart';
import 'mock/mock_data.dart';

/// Repository for learning data with fallback to mock
class LearningRepository {
  final LearningApiClient _apiClient;
  final bool useMockFallback;

  LearningRepository({
    LearningApiClient? apiClient,
    this.useMockFallback = true,
  }) : _apiClient = apiClient ?? LearningApiClient();

  /// Get units for a domain (with fallback)
  Future<List<Unit>> getUnits({String domainId = 'english'}) async {
    if (useMockFallback) {
      try {
        return await _apiClient.getUnits(domainId: domainId);
      } catch (e) {
        // Fallback to mock
        final domain = MockLearningData.englishDomain();
        return domain.units;
      }
    } else {
      return await _apiClient.getUnits(domainId: domainId);
    }
  }

  /// Get lessons for a unit (with fallback)
  Future<List<Lesson>> getLessons({required String unitId}) async {
    if (useMockFallback) {
      try {
        return await _apiClient.getLessons(unitId: unitId);
      } catch (e) {
        // Fallback to mock
        final domain = MockLearningData.englishDomain();
        final unit = domain.units.firstWhere(
          (u) => u.id == unitId,
          orElse: () => domain.units.first,
        );
        return unit.lessons;
      }
    } else {
      return await _apiClient.getLessons(unitId: unitId);
    }
  }

  /// Get exercise items for a lesson (with fallback)
  Future<List<ExerciseItem>> getItems({required String lessonId}) async {
    if (useMockFallback) {
      try {
        return await _apiClient.getItems(lessonId: lessonId);
      } catch (e) {
        // Fallback to mock
        return MockLearningData.exercisesForLesson(lessonId);
      }
    } else {
      return await _apiClient.getItems(lessonId: lessonId);
    }
  }
}


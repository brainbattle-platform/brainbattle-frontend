import 'package:shared_preferences/shared_preferences.dart';

enum PlacementLevel {
  beginner,
  intermediate,
  advanced,
}

extension PlacementLevelX on PlacementLevel {
  String get label {
    switch (this) {
      case PlacementLevel.beginner:
        return 'Beginner';
      case PlacementLevel.intermediate:
        return 'Intermediate';
      case PlacementLevel.advanced:
        return 'Advanced';
    }
  }
}

/// Service to manage placement test results
class PlacementService {
  static final PlacementService instance = PlacementService._();
  PlacementService._();

  /// Calculate level from score (0-10)
  static PlacementLevel calculateLevel(int correctCount, int totalQuestions) {
    final score = (correctCount / totalQuestions * 10).round();
    if (score <= 3) {
      return PlacementLevel.beginner;
    } else if (score <= 7) {
      return PlacementLevel.intermediate;
    } else {
      return PlacementLevel.advanced;
    }
  }

  /// Save placement level for a domain
  Future<void> savePlacementLevel(String domainId, PlacementLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('placement_level_$domainId', level.name);
  }

  /// Get placement level for a domain
  Future<PlacementLevel?> getPlacementLevel(String domainId) async {
    final prefs = await SharedPreferences.getInstance();
    final levelStr = prefs.getString('placement_level_$domainId');
    if (levelStr == null) return null;
    
    switch (levelStr) {
      case 'beginner':
        return PlacementLevel.beginner;
      case 'intermediate':
        return PlacementLevel.intermediate;
      case 'advanced':
        return PlacementLevel.advanced;
      default:
        return null;
    }
  }

  /// Get default level (beginner) if no placement done
  Future<PlacementLevel> getPlacementLevelOrDefault(String domainId) async {
    final level = await getPlacementLevel(domainId);
    return level ?? PlacementLevel.beginner;
  }
}


import '../core/placement_service.dart';
import '../data/unit_model.dart';
import '../data/lesson_model.dart';

/// Service to apply unlock logic based on placement level
class UnlockService {
  static final UnlockService instance = UnlockService._();
  UnlockService._();

  /// Apply unlock logic to units based on placement level
  Future<List<Unit>> applyUnlockLogic(List<Unit> units, {String domainId = 'english'}) async {
    final placementLevel = await PlacementService.instance.getPlacementLevelOrDefault(domainId);
    
    return units.asMap().entries.map((entry) {
      final index = entry.key;
      final unit = entry.value;
      
      // Determine which units to unlock based on placement level
      bool shouldUnlockUnit = false;
      switch (placementLevel) {
        case PlacementLevel.beginner:
          shouldUnlockUnit = index == 0; // Only Unit 1
          break;
        case PlacementLevel.intermediate:
          shouldUnlockUnit = index <= 1; // Unit 1-2
          break;
        case PlacementLevel.advanced:
          shouldUnlockUnit = index <= 2; // Unit 1-3 (or all demo units)
          break;
      }
      
      if (!shouldUnlockUnit) {
        // Lock all lessons in this unit
        final lockedLessons = unit.lessons.map((lesson) {
          return Lesson(
            id: lesson.id,
            title: lesson.title,
            description: lesson.description,
            level: lesson.level,
            progress: lesson.progress,
            status: LessonStatus.locked,
          );
        }).toList();
        
        return Unit(
          id: unit.id,
          title: unit.title,
          color: unit.color,
          lessons: lockedLessons,
        );
      }
      
      // Unlock unit - keep lesson statuses as is (or unlock first lesson if all locked)
      final unlockedLessons = unit.lessons.asMap().entries.map((lessonEntry) {
        final lessonIndex = lessonEntry.key;
        final lesson = lessonEntry.value;
        
        // If all lessons are locked, unlock the first one
        if (lesson.status == LessonStatus.locked && lessonIndex == 0) {
          return Lesson(
            id: lesson.id,
            title: lesson.title,
            description: lesson.description,
            level: lesson.level,
            progress: lesson.progress,
            status: LessonStatus.unlocked,
          );
        }
        
        return lesson;
      }).toList();
      
      return Unit(
        id: unit.id,
        title: unit.title,
        color: unit.color,
        lessons: unlockedLessons,
      );
    }).toList();
  }

  /// Get first unlocked unit index (for navigation after placement)
  Future<int> getFirstUnlockedUnitIndex({String domainId = 'english'}) async {
    final placementLevel = await PlacementService.instance.getPlacementLevelOrDefault(domainId);
    switch (placementLevel) {
      case PlacementLevel.beginner:
        return 0; // Unit 1
      case PlacementLevel.intermediate:
        return 0; // Unit 1 (or could be 1 for Unit 2)
      case PlacementLevel.advanced:
        return 0; // Unit 1 (or could be 2 for Unit 3)
    }
  }
}


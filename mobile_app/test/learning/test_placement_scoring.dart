import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/features/learning/core/placement_service.dart';

void main() {
  setUp(() {
    // Clear SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  test('Placement scoring calculates level correctly', () {
    // Test Beginner (0-3)
    expect(
      PlacementService.calculateLevel(2, 10),
      PlacementLevel.beginner,
    );
    expect(
      PlacementService.calculateLevel(3, 10),
      PlacementLevel.beginner,
    );

    // Test Intermediate (4-7)
    expect(
      PlacementService.calculateLevel(4, 10),
      PlacementLevel.intermediate,
    );
    expect(
      PlacementService.calculateLevel(5, 10),
      PlacementLevel.intermediate,
    );
    expect(
      PlacementService.calculateLevel(7, 10),
      PlacementLevel.intermediate,
    );

    // Test Advanced (8-10)
    expect(
      PlacementService.calculateLevel(8, 10),
      PlacementLevel.advanced,
    );
    expect(
      PlacementService.calculateLevel(9, 10),
      PlacementLevel.advanced,
    );
    expect(
      PlacementService.calculateLevel(10, 10),
      PlacementLevel.advanced,
    );
  });

  test('Placement level persistence', () async {
    final service = PlacementService.instance;
    const domainId = 'english';

    // Save level
    await service.savePlacementLevel(domainId, PlacementLevel.intermediate);

    // Retrieve level
    final level = await service.getPlacementLevel(domainId);
    expect(level, PlacementLevel.intermediate);
    expect(level?.label, 'Intermediate');
  });

  test('Placement level default is beginner', () async {
    final service = PlacementService.instance;
    const domainId = 'new_domain';

    // Get default level
    final level = await service.getPlacementLevelOrDefault(domainId);
    expect(level, PlacementLevel.beginner);
    expect(level.label, 'Beginner');
  });

  test('Placement level persisted value exists after save', () async {
    final service = PlacementService.instance;
    const domainId = 'test_domain';

    // Save different levels
    await service.savePlacementLevel(domainId, PlacementLevel.beginner);
    var level = await service.getPlacementLevel(domainId);
    expect(level, PlacementLevel.beginner);

    await service.savePlacementLevel(domainId, PlacementLevel.advanced);
    level = await service.getPlacementLevel(domainId);
    expect(level, PlacementLevel.advanced);
  });
}


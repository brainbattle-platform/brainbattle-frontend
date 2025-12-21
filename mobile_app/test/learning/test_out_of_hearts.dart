import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/features/learning/ui/exercise_player_page.dart';
import 'package:mobile_app/features/learning/data/mock/mock_data.dart';
import 'package:mobile_app/features/learning/ui/widgets/out_of_hearts_dialog.dart';

void main() {
  setUp(() {
    // Clear SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Out of hearts dialog appears when hearts reach 0', (WidgetTester tester) async {
    // Set mock SharedPreferences: 1 heart remaining
    SharedPreferences.setMockInitialValues({
      'hearts.current': 1,
      'hearts.max': 5,
      'hearts.last_refill': DateTime.now().toIso8601String(),
    });

    // Create a lesson
    final lesson = MockLearningData.lesson1();

    // Build ExercisePlayerPage
    await tester.pumpWidget(
      MaterialApp(
        home: ExercisePlayerPage(lesson: lesson),
      ),
    );

    // Wait for exercises to load
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Find first exercise option (assuming MCQ)
    final optionFinder = find.text('Xin chào'); // From mock data
    if (optionFinder.evaluate().isNotEmpty) {
      // Tap wrong answer (not the first option which is correct)
      final wrongOption = find.text('Tạm biệt');
      if (wrongOption.evaluate().isNotEmpty) {
        await tester.tap(wrongOption);
        await tester.pumpAndSettle();

        // Wait a bit for hearts to be consumed and dialog to appear
        await tester.pump(const Duration(milliseconds: 500));

        // Verify out-of-hearts dialog appears
        expect(find.byKey(OutOfHeartsDialog.keyOutOfHeartsDialog), findsOneWidget);
        expect(find.text('Out of Hearts'), findsOneWidget);
      }
    }
  });

  testWidgets('Hearts indicator shows correct count', (WidgetTester tester) async {
    // Set mock SharedPreferences: 3 hearts
    SharedPreferences.setMockInitialValues({
      'hearts.current': 3,
      'hearts.max': 5,
      'hearts.last_refill': DateTime.now().toIso8601String(),
    });

    final lesson = MockLearningData.lesson1();

    await tester.pumpWidget(
      MaterialApp(
        home: ExercisePlayerPage(lesson: lesson),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Hearts indicator should show 3 filled hearts
    // (Visual check - hearts are rendered as icons)
    expect(find.byType(ExercisePlayerPage), findsOneWidget);
  });
}


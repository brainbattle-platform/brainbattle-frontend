import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/learning/ui/galaxy_map_screen.dart';
import 'package:mobile_app/features/learning/ui/unit_detail_page.dart';
import 'package:mobile_app/features/learning/ui/lesson_start_page.dart';
import 'package:mobile_app/features/learning/ui/exercise_player_page.dart';
import 'package:mobile_app/features/learning/ui/lesson_summary_page.dart';
import 'package:mobile_app/features/learning/data/mock/mock_data.dart';
import 'package:mobile_app/features/learning/domain/lesson_summary_model.dart';

void main() {
  testWidgets('Core learning flow: GalaxyMap -> UnitDetail -> LessonStart -> Exercise -> Summary', (WidgetTester tester) async {
    // Setup: Create test data
    final domain = MockLearningData.englishDomain();
    final unit = domain.units.first;
    final lesson = unit.lessons.first;

    // Start with GalaxyMap
    await tester.pumpWidget(
      MaterialApp(
        home: const GalaxyMapScreen(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Assert GalaxyMap is present
    expect(find.byKey(GalaxyMapScreen.keyGalaxyMap), findsOneWidget);
    expect(find.text('Galaxy Map'), findsOneWidget);

    // Navigate to UnitDetail (simulate tap on unit)
    await tester.pumpWidget(
      MaterialApp(
        home: UnitDetailPage(unit: unit),
      ),
    );
    await tester.pumpAndSettle();

    // Assert UnitDetail is present
    expect(find.byKey(UnitDetailPage.keyUnitDetail), findsOneWidget);
    expect(find.text(unit.title), findsOneWidget);

    // Navigate to LessonStart
    await tester.pumpWidget(
      MaterialApp(
        home: LessonStartPage(lesson: lesson),
      ),
    );
    await tester.pumpAndSettle();

    // Assert LessonStart is present
    expect(find.byKey(LessonStartPage.keyLessonStart), findsOneWidget);
    expect(find.text(lesson.title), findsOneWidget);

    // Navigate to ExercisePlayer
    await tester.pumpWidget(
      MaterialApp(
        home: ExercisePlayerPage(lesson: lesson),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Assert ExercisePlayer is present
    expect(find.byKey(ExercisePlayerPage.keyExercisePlayer), findsOneWidget);

    // Navigate to LessonSummary
    final summary = LessonSummary(
      lessonId: lesson.id,
      xpGained: 50,
      accuracy: 0.8,
      timeSpent: 120,
      totalQuestions: 5,
      correctCount: 4,
      wrongCount: 1,
      mistakeIds: ['E1'],
      isCompleted: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LessonSummaryPage(lesson: lesson, summary: summary),
      ),
    );
    await tester.pumpAndSettle();

    // Assert LessonSummary is present
    expect(find.byKey(LessonSummaryPage.keyLessonSummary), findsOneWidget);
    expect(find.text('Lesson Complete'), findsOneWidget);
    expect(find.text('Great job!'), findsOneWidget);
  });
}


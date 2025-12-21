import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../data/mock/mock_data.dart';
import '../domain/exercise_model.dart';
import '../learning_routes.dart';
import 'widgets/exercise_templates/mcq_exercise.dart';
import 'widgets/exercise_templates/fill_blank_exercise.dart';
import 'widgets/exercise_templates/matching_exercise.dart';
import 'widgets/exercise_templates/listening_exercise.dart';

class MistakesReviewPage extends StatefulWidget {
  final Lesson lesson;
  final List<String> mistakeIds;

  const MistakesReviewPage({
    super.key,
    required this.lesson,
    required this.mistakeIds,
  });

  static const routeName = LearningRoutes.mistakesReview;

  @override
  State<MistakesReviewPage> createState() => _MistakesReviewPageState();
}

class _MistakesReviewPageState extends State<MistakesReviewPage> {
  late List<ExerciseItem> _mistakes;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final allExercises = MockLearningData.exercisesForLesson(widget.lesson.id);
    _mistakes = allExercises
        .where((e) => widget.mistakeIds.contains(e.id))
        .toList();
  }

  Widget _buildExercise(ExerciseItem exercise) {
    switch (exercise.type) {
      case ExerciseType.mcq:
        return MCQExercise(
          exercise: exercise,
          onAnswer: (_) {}, // Read-only review
        );
      case ExerciseType.fill:
        return FillBlankExercise(
          exercise: exercise,
          onAnswer: (_) {},
        );
      case ExerciseType.match:
        return MatchingExercise(
          exercise: exercise,
          onAnswer: (_) {},
        );
      case ExerciseType.listen:
        return ListeningExercise(
          exercise: exercise,
          onAnswer: (_) {},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_mistakes.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: const Text('Review Mistakes'),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                'No mistakes to review',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final exercise = _mistakes[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text('Review Mistakes (${_currentIndex + 1}/${_mistakes.length})'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Correct answer highlight
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Correct answer:',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                              Text(
                                exercise.correctAnswer,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (exercise.explanation != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? BBColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explanation:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exercise.explanation!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildExercise(exercise),
                ],
              ),
            ),
          ),
          // Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? BBColors.darkCard : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
            ),
            child: Row(
              children: [
                if (_currentIndex > 0)
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _currentIndex--);
                    },
                    child: const Text('Previous'),
                  ),
                const Spacer(),
                if (_currentIndex < _mistakes.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _currentIndex++);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


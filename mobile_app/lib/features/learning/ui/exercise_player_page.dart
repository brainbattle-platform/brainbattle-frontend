import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../widgets/skill_planet.dart';
import '../domain/exercise_model.dart';
import '../domain/attempt_result_model.dart';
import '../data/mock/mock_data.dart';
import '../learning_routes.dart';
import 'widgets/top_progress_header.dart';
import 'widgets/bottom_feedback_bar.dart';
import 'widgets/explanation_drawer.dart';
import 'widgets/exercise_templates/mcq_exercise.dart';
import 'widgets/exercise_templates/fill_blank_exercise.dart';
import 'widgets/exercise_templates/matching_exercise.dart';
import 'widgets/exercise_templates/listening_exercise.dart';
import 'lesson_summary_page.dart';

class ExercisePlayerPage extends StatefulWidget {
  final Lesson lesson;
  final Skill? skill;

  const ExercisePlayerPage({
    super.key,
    required this.lesson,
    this.skill,
  });

  static const routeName = LearningRoutes.exercisePlayer;

  @override
  State<ExercisePlayerPage> createState() => _ExercisePlayerPageState();
}

class _ExercisePlayerPageState extends State<ExercisePlayerPage> {
  late List<ExerciseItem> _exercises;
  int _currentIndex = 0;
  final Map<String, AttemptResult> _attempts = {};
  FeedbackType _feedback = FeedbackType.none;
  String? _userAnswer;
  bool _showExplanation = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _exercises = MockLearningData.exercisesForLesson(widget.lesson.id);
    _startTime = DateTime.now();
  }

  void _handleAnswer(String answer) {
    final exercise = _exercises[_currentIndex];
    final isCorrect = answer.trim().toLowerCase() ==
        exercise.correctAnswer.trim().toLowerCase();

    setState(() {
      _userAnswer = answer;
      _feedback = isCorrect ? FeedbackType.correct : FeedbackType.wrong;
      _attempts[exercise.id] = AttemptResult(
        exerciseId: exercise.id,
        userAnswer: answer,
        isCorrect: isCorrect,
        timeSpent: 0, // TODO: calculate from start
        attemptedAt: DateTime.now(),
      );
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _feedback = FeedbackType.none;
        _userAnswer = null;
        _showExplanation = false;
      });
    } else {
      // Go to summary
      final totalTime = DateTime.now().difference(_startTime!).inSeconds;
      final correctCount = _attempts.values.where((a) => a.isCorrect).length;
      final wrongCount = _attempts.values.where((a) => !a.isCorrect).length;
      final mistakeIds = _attempts.entries
          .where((e) => !e.value.isCorrect)
          .map((e) => e.key)
          .toList();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LessonSummaryPage(
            lesson: widget.lesson,
            summary: LessonSummary(
              lessonId: widget.lesson.id,
              xpGained: _exercises.length * 10,
              accuracy: correctCount / _exercises.length,
              timeSpent: totalTime,
              totalQuestions: _exercises.length,
              correctCount: correctCount,
              wrongCount: wrongCount,
              mistakeIds: mistakeIds,
              isCompleted: true,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildExercise() {
    final exercise = _exercises[_currentIndex];

    switch (exercise.type) {
      case ExerciseType.mcq:
        return MCQExercise(
          exercise: exercise,
          onAnswer: _handleAnswer,
        );
      case ExerciseType.fill:
        return FillBlankExercise(
          exercise: exercise,
          onAnswer: _handleAnswer,
        );
      case ExerciseType.match:
        return MatchingExercise(
          exercise: exercise,
          onAnswer: _handleAnswer,
        );
      case ExerciseType.listen:
        return ListeningExercise(
          exercise: exercise,
          onAnswer: _handleAnswer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercise = _exercises[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      body: Column(
        children: [
          TopProgressHeader(
            currentIndex: _currentIndex,
            totalCount: _exercises.length,
            onClose: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildExercise(),
            ),
          ),
          // Hint button
          if (exercise.hint != null && _feedback == FeedbackType.none)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: isDark ? BBColors.darkCard : Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hint',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            exercise.hint!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Show hint'),
              ),
            ),
          // Explanation button (after answer)
          if (_feedback != FeedbackType.none && exercise.explanation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() => _showExplanation = !_showExplanation);
                },
                icon: Icon(_showExplanation ? Icons.visibility_off : Icons.info_outline),
                label: Text(_showExplanation ? 'Hide explanation' : 'Show explanation'),
              ),
            ),
          if (_showExplanation && exercise.explanation != null)
            ExplanationDrawer(
              explanation: exercise.explanation!,
              onClose: () => setState(() => _showExplanation = false),
            ),
          BottomFeedbackBar(
            type: _feedback,
            onContinue: _feedback != FeedbackType.none ? _nextQuestion : null,
          ),
        ],
      ),
    );
  }
}


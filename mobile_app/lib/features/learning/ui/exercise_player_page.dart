import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../widgets/skill_planet.dart';
import '../domain/exercise_model.dart';
import '../domain/attempt_result_model.dart';
import '../data/mock/mock_data.dart';
import '../data/learning_repository.dart';
import '../learning_routes.dart';
import 'widgets/top_progress_header.dart';
import 'widgets/bottom_feedback_bar.dart';
import 'widgets/explanation_drawer.dart';
import 'widgets/learning_error_state.dart';
import 'widgets/learning_empty_state.dart';
import 'widgets/exercise_templates/mcq_exercise.dart';
import 'widgets/exercise_templates/fill_blank_exercise.dart';
import 'widgets/exercise_templates/matching_exercise.dart';
import 'widgets/exercise_templates/listening_exercise.dart';
import 'lesson_summary_page.dart';
import '../domain/lesson_summary_model.dart';
import '../core/hearts_service.dart';
import 'widgets/out_of_hearts_dialog.dart';
import 'package:flutter/services.dart';

class ExercisePlayerPage extends StatefulWidget {
  final Lesson lesson;
  final Skill? skill;

  const ExercisePlayerPage({
    super.key,
    required this.lesson,
    this.skill,
  });

  static const routeName = LearningRoutes.exercisePlayer;
  static const keyExercisePlayer = Key('exercise_player_page');

  @override
  State<ExercisePlayerPage> createState() => _ExercisePlayerPageState();
}

class _ExercisePlayerPageState extends State<ExercisePlayerPage> {
  late List<ExerciseItem> _exercises;
  int _currentIndex = 0;
  final Map<String, AttemptResult> _attempts = {};
  FeedbackType _feedback = FeedbackType.none;
  bool _showExplanation = false;
  DateTime? _lessonStartTime;
  final Map<String, DateTime> _exerciseStartTimes = {};
  int _currentLives = 5;
  int _maxLives = 5;
  final HeartsService _heartsService = HeartsService.instance;
  final LearningRepository _repository = LearningRepository();
  bool _loadingExercises = false;
  String? _errorMessage;
  bool _usingOfflineData = false;

  @override
  void initState() {
    super.initState();
    _exercises = [];
    _lessonStartTime = DateTime.now();
    _loadHearts();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _loadingExercises = true;
      _errorMessage = null;
      _usingOfflineData = false;
    });
    try {
      final items = await _repository.getItems(lessonId: widget.lesson.id);
      setState(() {
        _exercises = items;
        _loadingExercises = false;
        if (_exercises.isNotEmpty) {
          _exerciseStartTimes[_exercises[0].id] = DateTime.now();
        }
      });
    } catch (e) {
      // Fallback to mock
      debugPrint('API failed, using mock data: $e');
      setState(() {
        _exercises = MockLearningData.exercisesForLesson(widget.lesson.id);
        _loadingExercises = false;
        _usingOfflineData = true;
        if (_exercises.isNotEmpty) {
          _exerciseStartTimes[_exercises[0].id] = DateTime.now();
        }
      });
    }
  }

  Future<void> _loadHearts() async {
    final current = await _heartsService.getCurrentLives();
    final max = await _heartsService.getMaxLives();
    setState(() {
      _currentLives = current;
      _maxLives = max;
    });
  }

  Future<void> _handleAnswer(String answer) async {
    final exercise = _exercises[_currentIndex];
    final isCorrect = answer.trim().toLowerCase() ==
        exercise.correctAnswer.trim().toLowerCase();

    // Calculate time spent on this exercise
    final exerciseStart = _exerciseStartTimes[exercise.id] ?? DateTime.now();
    final timeSpent = DateTime.now().difference(exerciseStart).inSeconds;

    // Haptic feedback
    if (isCorrect) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.mediumImpact();
      // Consume heart on wrong answer
      final newLives = await _heartsService.consumeHeart();
      setState(() => _currentLives = newLives);
      
      // Check if out of hearts
      if (newLives == 0) {
        final timeUntilRefill = await _heartsService.getTimeUntilNextRefill();
        if (mounted) {
          await OutOfHeartsDialog.show(context, timeUntilNextRefill: timeUntilRefill);
        }
      }
    }

    setState(() {
      _feedback = isCorrect ? FeedbackType.correct : FeedbackType.wrong;
      _attempts[exercise.id] = AttemptResult(
        exerciseId: exercise.id,
        userAnswer: answer,
        isCorrect: isCorrect,
        timeSpent: timeSpent,
        attemptedAt: DateTime.now(),
      );
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _exercises.length - 1) {
      setState(() {
        _currentIndex++;
        _feedback = FeedbackType.none;
        _showExplanation = false;
        // Track start time for next exercise
        final nextExercise = _exercises[_currentIndex];
        _exerciseStartTimes[nextExercise.id] = DateTime.now();
      });
    } else {
      // Go to summary
      final totalTime = DateTime.now().difference(_lessonStartTime!).inSeconds;
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
          onAnswer: (answer) => _handleAnswer(answer),
        );
      case ExerciseType.fill:
        return FillBlankExercise(
          exercise: exercise,
          onAnswer: (answer) => _handleAnswer(answer),
        );
      case ExerciseType.match:
        return MatchingExercise(
          exercise: exercise,
          onAnswer: (answer) => _handleAnswer(answer),
        );
      case ExerciseType.listen:
        return ListeningExercise(
          key: ValueKey(exercise.id), // Force rebuild when exercise changes
          exercise: exercise,
          onAnswer: (answer) => _handleAnswer(answer),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loadingExercises) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _exercises.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningErrorState(
          message: 'Failed to load exercises',
          onRetry: _loadExercises,
        ),
      );
    }

    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningEmptyState(
          message: 'No exercises available',
          actionLabel: 'Go Back',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final exercise = _exercises[_currentIndex];

    return Scaffold(
      key: ExercisePlayerPage.keyExercisePlayer,
      backgroundColor: isDark ? BBColors.darkBg : null,
      body: Column(
        children: [
          if (_usingOfflineData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Using offline data',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          TopProgressHeader(
            currentIndex: _currentIndex,
            totalCount: _exercises.length,
            onClose: () => Navigator.pop(context),
            currentLives: _currentLives,
            maxLives: _maxLives,
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
            onContinue: _feedback != FeedbackType.none
                ? () {
                    HapticFeedback.selectionClick();
                    _nextQuestion();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}


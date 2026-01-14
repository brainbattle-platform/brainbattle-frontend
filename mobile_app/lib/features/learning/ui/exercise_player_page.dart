import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_num.dart';
import '../data/lesson_model.dart';
import '../data/learning_api_client.dart';
import '../widgets/skill_planet.dart';
import '../domain/exercise_model.dart';
import '../domain/attempt_result_model.dart';
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
import 'widgets/out_of_hearts_dialog.dart';

class ExercisePlayerPage extends StatefulWidget {
  final Lesson lesson;
  final Skill? skill;
  final Map<String, dynamic>? sessionData; // Optional: if coming from startLesson

  const ExercisePlayerPage({
    super.key,
    required this.lesson,
    this.skill,
    this.sessionData,
  });

  static const routeName = LearningRoutes.exercisePlayer;
  static const keyExercisePlayer = Key('exercise_player_page');

  @override
  State<ExercisePlayerPage> createState() => _ExercisePlayerPageState();
}

class _ExercisePlayerPageState extends State<ExercisePlayerPage> {
  final _apiClient = LearningApiClient();
  
  // Quiz attempt state
  String? _attemptId;
  Map<String, dynamic>? _currentQuestion;
  int _currentQuestionIndex = 0;
  int _totalQuestions = 0;
  int _heartsRemaining = 5;
  
  // UI state
  FeedbackType _feedback = FeedbackType.none;
  bool _showExplanation = false;
  bool _isInReview = false; // Track if we're showing answer review
  bool _outOfHearts = false; // Track if user is out of hearts
  String? _correctAnswer; // Store correct answer from API
  DateTime? _lessonStartTime;
  final Map<String, AttemptResult> _attempts = {};
  bool _loading = true;
  String? _errorMessage;
  bool _isLoading = false; // Consolidated loading guard (prevents any operation while loading)
  bool _finishRequested = false; // Guard: finish has been requested (set BEFORE calling finish)
  bool _navigatedToResult = false; // Guard: navigation to result screen has occurred
  
  /// Helper to log timestamped events with attemptId
  void _logEvent(String event) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final attemptId = _attemptId ?? 'null';
      debugPrint('[TS $timestamp] $event (attemptId=$attemptId)');
    }
  }

  @override
  void initState() {
    super.initState();
    _lessonStartTime = DateTime.now();
    _logEvent('Quiz screen initState');
    _startQuiz();
  }
  
  @override
  void dispose() {
    _logEvent('Quiz screen dispose()');
    super.dispose();
  }

  /// 5.5: Start quiz attempt
  Future<void> _startQuiz() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // If sessionData provided from startLesson, use it with initial question
      if (widget.sessionData != null) {
        // Use session from startLesson - already has first question
        _attemptId = widget.sessionData!['sessionId'] as String? ?? widget.sessionData!['attemptId'] as String?;
        _totalQuestions = JsonNum.asIntOr(widget.sessionData!['totalQuestions'], 0);
        _currentQuestionIndex = JsonNum.asIntOr(widget.sessionData!['currentQuestionIndex'], 1);
        
        // Use the question from sessionData directly (no extra API call)
        final question = widget.sessionData!['question'] as Map<String, dynamic>?;
        if (question != null) {
          // Format as expected by _questionToExercise: {question: {...}}
          _currentQuestion = {'question': question};
        }
        
        // Load hearts
        await _loadHearts();
        
        setState(() {
          _loading = false;
        });
      } else {
        // 5.5: Call POST /api/learning/quiz/start (fallback if no sessionData)
        final mode = widget.skill?.name.toLowerCase();
        final quizData = await _apiClient.startQuiz(widget.lesson.id, mode: mode);
        _attemptId = quizData['attemptId'] as String?;
        
        if (_attemptId == null) {
          throw Exception('Failed to get attempt ID');
        }
        
        // Load first question
        await _loadCurrentQuestion();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start quiz: ${e.toString()}';
        _loading = false;
      });
    }
  }

  /// 5.5: Get current question
  Future<void> _loadCurrentQuestion() async {
    if (_attemptId == null) return;

    try {
      // 5.5: Call GET /api/learning/quiz/{attemptId}/question
      final questionData = await _apiClient.getQuizQuestion(_attemptId!);
      
      final currentIndex = JsonNum.asIntOr(questionData['currentQuestionIndex'], 1);
      final totalQuestions = JsonNum.asIntOr(questionData['totalQuestions'], 0);
      _logEvent('[Flow] show question $currentIndex/$totalQuestions');
      
      setState(() {
        _currentQuestion = questionData;
        _currentQuestionIndex = currentIndex;
        _totalQuestions = totalQuestions;
        _heartsRemaining = JsonNum.asIntOr(questionData['heartsRemaining'], 5);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load question: ${e.toString()}';
        _loading = false;
      });
    }
  }

  /// 5.6: Submit answer
  Future<void> _handleAnswer(String answer) async {
    if (_attemptId == null || _currentQuestion == null || _isInReview) return;

    try {
      // 5.6: Call POST /api/learning/quiz/{attemptId}/answer
      final result = await _apiClient.submitQuizAnswer(_attemptId!, answer);
      
      final isCorrect = result['isCorrect'] as bool? ?? false;
      final explanation = result['explanation'] as String?;
      final correctAnswer = result['correctAnswer'] as String?;
      final heartsRemaining = JsonNum.asInt(result['heartsRemaining']);
      final outOfHearts = result['outOfHearts'] as bool? ?? false;
      
      // Debug log
      if (kDebugMode) {
        debugPrint('[Answer] isCorrect=$isCorrect, heartsRemaining=$heartsRemaining, outOfHearts=$outOfHearts');
      }
      
      // Update hearts immediately from API response (no separate GET call)
      if (heartsRemaining != null) {
        _heartsRemaining = heartsRemaining;
      }

      // Haptic feedback
      if (isCorrect) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.mediumImpact();
      }

      // Store attempt result
      final questionId = _currentQuestion!['question']?['questionId'] as String? ?? '';
      _attempts[questionId] = AttemptResult(
        exerciseId: questionId,
        userAnswer: answer,
        isCorrect: isCorrect,
        timeSpent: 0, // Could track time if needed
        attemptedAt: DateTime.now(),
      );

      // Update state to show review UI
      setState(() {
        _feedback = isCorrect ? FeedbackType.correct : FeedbackType.wrong;
        _isInReview = true;
        _outOfHearts = outOfHearts;
        _correctAnswer = correctAnswer;
        if (explanation != null) {
          _currentQuestion = {
            ..._currentQuestion!,
            'question': {
              ..._currentQuestion!['question'] as Map<String, dynamic>,
              'explanation': explanation,
            },
          };
        }
      });
      
      _logEvent('[Flow] answer submitted -> REVIEW');
      
      // Show OutOfHearts modal if needed
      if (outOfHearts && mounted) {
        // Get hearts info for dialog (timeUntilNextRefill)
        try {
          final heartsData = await _apiClient.getHearts();
          final regen = heartsData['regen'] as Map<String, dynamic>?;
          final timeUntilNextRefill = JsonNum.asIntOr(regen?['timeUntilNextRefillSeconds'], 
              JsonNum.asIntOr(regen?['secondsPerHeart'], 1800));
          
          if (kDebugMode) {
            debugPrint('[UI] showing OutOfHearts modal');
          }
          
          await OutOfHeartsDialog.show(
            context,
            timeUntilNextRefill: timeUntilNextRefill,
          );
        } catch (e) {
          debugPrint('Failed to load hearts info: $e');
          // Show dialog anyway with default time
          await OutOfHeartsDialog.show(
            context,
            timeUntilNextRefill: 1800,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answer: ${e.toString()}')),
        );
      }
    }
  }

  /// 5.5: Move to next question
  /// 
  /// STATE MACHINE:
  /// - QUESTION: _isInReview = false, showing question options
  /// - REVIEW: _isInReview = true, showing answer feedback
  /// - FINISHED: _finishRequested = true, _navigatedToResult = true
  /// 
  /// TRANSITIONS:
  /// - QUESTION -> REVIEW: User submits answer (_handleAnswer)
  /// - REVIEW -> QUESTION: User taps Next, /next returns question
  /// - REVIEW -> FINISHED: User taps Next, /next returns 404, then /finish called
  /// 
  /// GUARDS:
  /// - _isLoading: Prevents any operation while one is in-flight
  /// - _finishRequested: Prevents calling /next after finish has been requested
  /// - _navigatedToResult: Prevents duplicate navigation
  Future<void> _nextQuestion() async {
    // Guard: prevent duplicate requests
    if (_attemptId == null || !_isInReview || _isLoading || _finishRequested || _navigatedToResult) {
      _logEvent('[Flow] prevented duplicate call: isLoading=$_isLoading, finishRequested=$_finishRequested, navigatedToResult=$_navigatedToResult');
      return;
    }

    _logEvent('[Flow] Next tapped');
    setState(() {
      _isLoading = true;
      _loading = true;
    });

    try {
      // 5.5: Call POST /api/learning/quiz/{attemptId}/next
      final result = await _apiClient.nextQuizQuestion(_attemptId!);
      
      if (result.hasQuestion && result.questionData != null) {
        // Has next question: transition to QUESTION state
        final questionData = result.questionData!;
        final question = questionData['question'] as Map<String, dynamic>?;
        final currentIndex = JsonNum.asInt(questionData['currentQuestionIndex']);
        final totalQuestions = JsonNum.asInt(questionData['totalQuestions']);
        final heartsRemaining = JsonNum.asInt(questionData['heartsRemaining']);
        
        if (question != null) {
          _logEvent('[Flow] next() => got question $currentIndex/$totalQuestions');
          
          // Format question data as expected by _questionToExercise: {question: {...}}
          setState(() {
            _currentQuestion = {'question': question};
            _currentQuestionIndex = currentIndex ?? _currentQuestionIndex + 1;
            _totalQuestions = totalQuestions ?? _totalQuestions;
            if (heartsRemaining != null) {
              _heartsRemaining = heartsRemaining;
            }
            // Reset to QUESTION state
            _feedback = FeedbackType.none;
            _showExplanation = false;
            _isInReview = false;
            _outOfHearts = false;
            _correctAnswer = null;
            _loading = false;
            _isLoading = false;
          });
        } else {
          // Question data exists but no question field: finished
          _logEvent('[Flow] finished detected from 404; calling finish once');
          // CRITICAL: Set _finishRequested BEFORE calling _finishQuiz to prevent race condition
          setState(() {
            _finishRequested = true;
            _isLoading = false;
          });
          await _finishQuiz();
        }
      } else {
        // No question: quiz is finished (404 response)
        _logEvent('[Flow] finished detected from 404; calling finish once');
        // CRITICAL: Set _finishRequested BEFORE calling _finishQuiz to prevent race condition
        setState(() {
          _finishRequested = true;
          _isLoading = false;
        });
        await _finishQuiz();
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load next question: ${e.toString()}')),
        );
      }
    }
  }

  /// 5.9: Finish quiz
  /// 
  /// CALLED FROM: _nextQuestion() when /next returns 404 "No more questions"
  /// 
  /// GUARDS:
  /// - _finishRequested: Already set by _nextQuestion() before calling this
  /// - _navigatedToResult: Prevents duplicate navigation
  /// - _isLoading: Prevents concurrent operations
  /// 
  /// NAVIGATION:
  /// - Only navigates if mounted && !_navigatedToResult
  /// - Sets _navigatedToResult = true before navigation
  Future<void> _finishQuiz() async {
    // Guard: prevent duplicate finish calls
    // Note: _finishRequested is already set by _nextQuestion() before calling this
    if (_attemptId == null || _navigatedToResult || _isLoading) {
      _logEvent('[Flow] prevented duplicate call: navigatedToResult=$_navigatedToResult, isLoading=$_isLoading');
      return;
    }

    _logEvent('[Flow] finish() called');
    setState(() {
      _isLoading = true;
      _loading = true;
    });

    try {
      // 5.9: Call POST /api/learning/quiz/{attemptId}/finish
      final result = await _apiClient.finishQuiz(_attemptId!);
      
      // Handle response structure: may have 'result' wrapper or direct fields
      final resultData = result['result'] as Map<String, dynamic>? ?? result;
      
      // Safe numeric parsing: backend may return int or double for these fields
      final correctCount = JsonNum.asIntOr(resultData['correctCount'], 0);
      final totalQuestions = JsonNum.asIntOr(resultData['totalQuestions'], _totalQuestions);
      final accuracy = JsonNum.asDoubleOr(resultData['accuracy'], 0.0);
      final xpEarned = JsonNum.asIntOr(resultData['xpEarned'], 
          JsonNum.asIntOr(resultData['xpGained'], 0));

      _logEvent('[Flow] finish() parsed OK accuracy=$accuracy xp=$xpEarned');

      // Guard: only navigate once
      if (mounted && !_navigatedToResult) {
        setState(() {
          _navigatedToResult = true; // Set BEFORE navigation to prevent race condition
        });
        
        final totalTime = DateTime.now().difference(_lessonStartTime!).inSeconds;
        final wrongCount = totalQuestions - correctCount;
        final mistakeIds = _attempts.entries
            .where((e) => !e.value.isCorrect)
            .map((e) => e.key)
            .toList();

        // Navigate to summary page
        _logEvent('[Flow] RESULT_SCREEN_PUSHED');
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LessonSummaryPage(
              lesson: widget.lesson,
              summary: LessonSummary(
                lessonId: widget.lesson.id,
                xpGained: xpEarned,
                accuracy: accuracy,
                timeSpent: totalTime,
                totalQuestions: totalQuestions,
                correctCount: correctCount,
                wrongCount: wrongCount,
                mistakeIds: mistakeIds,
                isCompleted: true,
              ),
            ),
          ),
        );
        
        // Refresh learning map after quiz completion to show updated progress
        // This ensures map shows updated progress when user navigates back
        try {
          await _apiClient.getLearningMap();
          _logEvent('[Progress] refreshed map after finish');
        } catch (e) {
          // Non-critical: map will refresh when user navigates back
          _logEvent('[Progress] failed to refresh map: $e');
        }
      } else {
        _logEvent('[Flow] navigation skipped (mounted=$mounted, navigatedToResult=$_navigatedToResult)');
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logEvent('[Flow] finish() error: ${e.toString()}');
      if (mounted) {
        // Show visible error to user and keep them on REVIEW state (do not crash)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to finish quiz: ${e.toString()}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () {
                // Reset flags to allow retry
                setState(() {
                  _finishRequested = false;
                  _isLoading = false;
                  _loading = false;
                });
                _finishQuiz();
              },
            ),
          ),
        );
        setState(() {
          _errorMessage = 'Failed to finish quiz: ${e.toString()}';
          _loading = false;
          _finishRequested = false; // Allow retry on error
          _isLoading = false;
        });
      }
    }
  }

  /// 5.7: Load hearts from API
  Future<void> _loadHearts() async {
    try {
      final heartsData = await _apiClient.getHearts();
      setState(() {
        _heartsRemaining = JsonNum.asIntOr(heartsData['current'], 5);
      });
    } catch (e) {
      debugPrint('Failed to load hearts: $e');
    }
  }

  /// Convert API question to ExerciseItem
  /// Handles schema variations: type (mcq/MCQ), options/choices, hint/hintAvailable
  ExerciseItem? _questionToExercise(Map<String, dynamic> questionData) {
    final question = questionData['question'] as Map<String, dynamic>?;
    if (question == null) return null;

    final questionId = question['questionId'] as String? ?? '';
    final typeStr = question['type'] as String? ?? 'MCQ';
    final prompt = question['prompt'] as String? ?? '';
    // Backend may return "choices" or "options" - handle both
    final options = (question['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        (question['choices'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final explanation = question['explanation'] as String?;
    // Handle hint: may be "hint" string or "hintAvailable" bool
    final hint = question['hint'] as String?;
    final hintAvailable = question['hintAvailable'] as bool? ?? false;
    final finalHint = hint ?? (hintAvailable ? 'Hint available' : null);

    // Determine exercise type
    ExerciseType type;
    switch (typeStr.toUpperCase()) {
      case 'MCQ':
        type = ExerciseType.mcq;
        break;
      case 'MATCH':
        type = ExerciseType.match;
        break;
      case 'FILL_IN':
      case 'FILL':
        type = ExerciseType.fill;
        break;
      default:
        type = ExerciseType.mcq;
    }

    // Determine skill from lesson mode or default
    Skill skill = widget.skill ?? Skill.reading;

    return ExerciseItem(
      id: questionId,
      type: type,
      skill: skill,
      question: prompt,
      options: options,
      correctAnswer: '', // Not provided in question, will be in answer response
      explanation: explanation,
      hint: finalHint,
    );
  }

  Widget _buildExercise() {
    if (_currentQuestion == null) return const SizedBox();

    final exercise = _questionToExercise(_currentQuestion!);
    if (exercise == null) return const SizedBox();

    // Disable answer selection during review
    final onAnswer = _isInReview ? null : (answer) => _handleAnswer(answer);

    switch (exercise.type) {
      case ExerciseType.mcq:
        return MCQExercise(
          exercise: exercise,
          onAnswer: onAnswer,
        );
      case ExerciseType.fill:
        return FillBlankExercise(
          exercise: exercise,
          onAnswer: onAnswer,
        );
      case ExerciseType.match:
        return MatchingExercise(
          exercise: exercise,
          onAnswer: onAnswer,
        );
      case ExerciseType.listen:
        return ListeningExercise(
          key: ValueKey(exercise.id),
          exercise: exercise,
          onAnswer: onAnswer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null && _currentQuestion == null) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningErrorState(
          message: _errorMessage!,
          onRetry: _startQuiz,
        ),
      );
    }

    if (_currentQuestion == null) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningEmptyState(
          message: 'No questions available',
          actionLabel: 'Go Back',
          onAction: () => Navigator.pop(context),
        ),
      );
    }

    final exercise = _questionToExercise(_currentQuestion!);
    if (exercise == null) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        body: const Center(child: Text('Invalid question format')),
      );
    }

    return Scaffold(
      key: ExercisePlayerPage.keyExercisePlayer,
      backgroundColor: isDark ? BBColors.darkBg : null,
      body: SafeArea(
        bottom: true, // Ensure bottom panel respects system gesture bar
        child: Column(
          children: [
            TopProgressHeader(
              currentIndex: _currentQuestionIndex,
              totalCount: _totalQuestions,
              onClose: () => Navigator.pop(context),
              currentLives: _heartsRemaining,
              maxLives: 5, // Could get from API if needed
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildExercise(),
              ),
            ),
            // Hint button (5.10: Use hint from question payload)
            if (exercise.hint != null && !_isInReview)
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
            if (_isInReview && exercise.explanation != null)
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
              Flexible(
                child: SingleChildScrollView(
                  child: ExplanationDrawer(
                    explanation: exercise.explanation!,
                    onClose: () => setState(() => _showExplanation = false),
                  ),
                ),
              ),
            // Bottom feedback bar (answer review panel)
            BottomFeedbackBar(
              type: _feedback,
              message: _isInReview && _correctAnswer != null && _feedback == FeedbackType.wrong
                  ? 'Correct answer: $_correctAnswer'
                  : null,
              // Disable Next button if: not in review, out of hearts, loading, or finish already requested
              // CRITICAL: Never check currentQuestionIndex >= totalQuestions here; let backend decide via 404
              onContinue: _isInReview && !_outOfHearts && !_isLoading && !_finishRequested && !_navigatedToResult
                  ? () {
                      HapticFeedback.selectionClick();
                      _nextQuestion();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

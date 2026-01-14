import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/json_num.dart';
import '../data/lesson_model.dart';
import '../data/learning_api_client.dart';
import '../widgets/skill_planet.dart';
import '../learning_routes.dart';
import 'exercise_player_page.dart';
import 'widgets/learning_error_state.dart';

class LessonStartPage extends StatefulWidget {
  final Lesson lesson;
  final Skill? skill; // Optional: if coming from skill selection

  const LessonStartPage({
    super.key,
    required this.lesson,
    this.skill,
  });

  static const routeName = LearningRoutes.lessonStart;
  static const keyLessonStart = Key('lesson_start_page');

  @override
  State<LessonStartPage> createState() => _LessonStartPageState();
}

class _LessonStartPageState extends State<LessonStartPage> {
  final _apiClient = LearningApiClient();
  Map<String, dynamic>? _overview;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOverview();
  }

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 5.4: Call GET /api/learning/lessons/{lessonId}/overview
      final mode = widget.skill?.name.toLowerCase(); // listening, speaking, reading, writing
      final overview = await _apiClient.getLessonOverview(widget.lesson.id, mode: mode);
      setState(() {
        _overview = overview;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load lesson overview: ${e.toString()}';
        _loading = false;
      });
    }
  }

  Future<void> _startLesson() async {
    try {
      // 5.4: Call POST /api/learning/lessons/{lessonId}/start
      final mode = widget.skill?.name.toLowerCase();
      final result = await _apiClient.startLesson(widget.lesson.id, mode: mode);
      
      // Parse response: {sessionId, lessonId, mode, totalQuestions, question: {...}}
      final sessionId = result['sessionId'] as String?;
      final totalQuestions = JsonNum.asIntOr(result['totalQuestions'], 0);
      final question = result['question'] as Map<String, dynamic>?;
      
      if (sessionId == null || question == null) {
        throw Exception('Invalid response: missing sessionId or question');
      }
      
      // Map backend response to ExercisePlayerPage format
      // Backend uses "choices", UI expects "options"
      final choices = question['choices'] as List<dynamic>?;
      final questionType = question['type'] as String? ?? 'mcq';
      final questionIndex = JsonNum.asIntOr(question['index'], 1);
      
      // Convert choices to options for UI compatibility
      final questionWithOptions = {
        ...question,
        'options': choices?.map((e) => e.toString()).toList() ?? [],
        // Keep choices for backward compatibility if needed
        if (choices != null) 'choices': choices,
      };
      
      // Format question data for ExercisePlayerPage
      // ExercisePlayerPage expects: {question: {...}, currentQuestionIndex, totalQuestions, ...}
      final sessionData = {
        'sessionId': sessionId,
        'attemptId': sessionId, // Map sessionId -> attemptId for compatibility
        'totalQuestions': totalQuestions,
        'currentQuestionIndex': questionIndex,
        'question': questionWithOptions,
        // Include full response for any other fields needed
        ...result,
      };
      
      // Debug logs
      if (kDebugMode) {
        debugPrint('[StartLesson] sessionId=$sessionId, questionId=${question['questionId']}, type=$questionType');
      }
      
      // Navigate to quiz screen immediately with initial question
      if (mounted) {
        if (kDebugMode) {
          debugPrint('[Nav] pushing Quiz screen with sessionId=$sessionId');
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ExercisePlayerPage(
              lesson: widget.lesson,
              skill: widget.skill,
              sessionData: sessionData, // Pass formatted session data
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start lesson: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        key: LessonStartPage.keyLessonStart,
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        key: LessonStartPage.keyLessonStart,
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningErrorState(
          message: _error!,
          onRetry: _loadOverview,
        ),
      );
    }

          // Use API data if available
          final estimatedTime = JsonNum.asIntOr(_overview?['estimatedTimeMinutes'], 3);
          final xpReward = JsonNum.asIntOr(_overview?['xpReward'], 0);
          final totalQuestions = JsonNum.asIntOr(_overview?['totalQuestions'], 5);
          final hearts = _overview?['hearts'] as Map<String, dynamic>?;
          final heartsCurrent = JsonNum.asIntOr(hearts?['current'], 5);
          final heartsMax = JsonNum.asIntOr(hearts?['max'], 5);

    return Scaffold(
      key: LessonStartPage.keyLessonStart,
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text(widget.lesson.title),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Lesson header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.skill != null)
                    Row(
                      children: [
                        Icon(widget.skill!.icon, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          widget.skill!.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  if (widget.skill != null) const SizedBox(height: 12),
                  Text(
                    widget.lesson.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.lesson.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Preview info
            _PreviewCard(
              icon: Icons.timer_outlined,
              label: 'Estimated time',
              value: '$estimatedTime min',
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.stars,
              label: 'XP reward',
              value: '$xpReward XP',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.local_fire_department,
              label: 'Streak protect',
              value: _overview?['streakProtected'] == true ? 'Available' : 'Not available',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.quiz,
              label: 'Questions',
              value: '$totalQuestions questions',
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.favorite,
              label: 'Hearts',
              value: '$heartsCurrent/$heartsMax',
              color: Colors.red,
            ),
            const SizedBox(height: 32),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startLesson,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Lesson',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _PreviewCard({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


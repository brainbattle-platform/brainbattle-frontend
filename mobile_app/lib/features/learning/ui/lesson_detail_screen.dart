import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../data/learning_api_client.dart';
import '../widgets/skill_planet.dart';
import 'lesson_start_page.dart';
import 'widgets/learning_error_state.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final Skill? initialSkill;
  final Object? heroTag;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
    this.initialSkill,
    this.heroTag,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  final _apiClient = LearningApiClient();
  Map<String, dynamic>? _lessonDetail;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLessonDetail();
  }

  Future<void> _loadLessonDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 5.3: Call GET /api/learning/lessons/{lessonId}
      final detail = await _apiClient.getLessonDetail(widget.lesson.id);
      setState(() {
        _lessonDetail = detail;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load lesson details: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_loading) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(
            widget.initialSkill != null
                ? "${widget.lesson.title} • ${widget.initialSkill!.label}"
                : widget.lesson.title,
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: isDark ? BBColors.darkBg : null,
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Colors.transparent,
          foregroundColor: isDark ? Colors.white : null,
        ),
        body: LearningErrorState(
          message: _error!,
          onRetry: _loadLessonDetail,
        ),
      );
    }

    // Use API data if available, fallback to lesson model
    final lessonTitle = _lessonDetail?['lessonTitle'] as String? ?? widget.lesson.title;
    final lessonDescription = _lessonDetail?['description'] as String? ?? widget.lesson.description;
    final level = _lessonDetail?['level'] as String? ?? widget.lesson.level;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text(
          widget.initialSkill != null
              ? "$lessonTitle • ${widget.initialSkill!.label}"
              : lessonTitle,
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.heroTag != null)
              Hero(
                tag: widget.heroTag!,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: widget.initialSkill != null
                          ? Icon(widget.initialSkill!.icon, color: Colors.white)
                          : Text(lessonTitle[0]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lessonTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Text(
              lessonDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Level: $level",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            // Start lesson button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonStartPage(
                        lesson: widget.lesson,
                        skill: widget.initialSkill,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Start Lesson'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

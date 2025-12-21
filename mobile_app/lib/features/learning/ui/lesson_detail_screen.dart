import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../widgets/skill_planet.dart';
import '../learning_routes.dart';
import 'lesson_start_page.dart';

class LessonDetailScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text(
          initialSkill != null
              ? "${lesson.title} • ${initialSkill!.label}"
              : lesson.title,
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (heroTag != null)
              Hero(
                tag: heroTag!,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: initialSkill != null
                          ? Icon(initialSkill!.icon, color: Colors.white)
                          : Text(lesson.title[0]),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      lesson.title,
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
              lesson.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Level: ${lesson.level}",
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
                        lesson: lesson,
                        skill: initialSkill,
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

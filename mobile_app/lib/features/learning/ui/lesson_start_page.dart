import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../data/lesson_model.dart';
import '../widgets/skill_planet.dart';
import '../learning_routes.dart';
import '../data/mock/mock_data.dart';
import 'exercise_player_page.dart';

class LessonStartPage extends StatelessWidget {
  final Lesson lesson;
  final Skill? skill; // Optional: if coming from skill selection

  const LessonStartPage({
    super.key,
    required this.lesson,
    this.skill,
  });

  static const routeName = LearningRoutes.lessonStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final exercises = MockLearningData.exercisesForLesson(lesson.id);
    final estimatedTime = exercises.length * 30; // ~30s per exercise
    final estimatedXP = exercises.length * 10; // 10 XP per exercise

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text(lesson.title),
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
                  if (skill != null)
                    Row(
                      children: [
                        Icon(skill!.icon, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          skill!.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  if (skill != null) const SizedBox(height: 12),
                  Text(
                    lesson.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.description,
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
              value: '${(estimatedTime / 60).ceil()} min',
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.stars,
              label: 'XP reward',
              value: '$estimatedXP XP',
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.local_fire_department,
              label: 'Streak protect',
              value: 'Available',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _PreviewCard(
              icon: Icons.quiz,
              label: 'Questions',
              value: '${exercises.length} exercises',
            ),
            const SizedBox(height: 32),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExercisePlayerPage(
                        lesson: lesson,
                        skill: skill,
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


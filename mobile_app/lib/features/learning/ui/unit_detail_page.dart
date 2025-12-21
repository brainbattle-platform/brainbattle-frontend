import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/unit_model.dart';
import '../data/lesson_model.dart';
import '../widgets/skill_planet.dart';
import '../learning_routes.dart';
import 'lesson_start_page.dart';

class UnitDetailPage extends StatelessWidget {
  final Unit unit;

  const UnitDetailPage({
    super.key,
    required this.unit,
  });

  static const routeName = LearningRoutes.unitDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: Text(unit.title),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unit header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    unit.color.withOpacity(0.2),
                    unit.color.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: unit.color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unit.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Complete all lessons to unlock next unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Skills overview
            Text(
              'Skills in this unit',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: Skill.values.map((skill) {
                return Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: unit.color.withOpacity(0.2),
                        border: Border.all(color: unit.color.withOpacity(0.5)),
                      ),
                      child: Icon(skill.icon, color: unit.color),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      skill.label,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Lessons list
            Text(
              'Lessons',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...unit.lessons.map((lesson) => _LessonTile(
              lesson: lesson,
              unitColor: unit.color,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonStartPage(lesson: lesson),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final Color unitColor;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.unitColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLocked
                      ? Colors.grey.withOpacity(0.2)
                      : isCompleted
                          ? Colors.green.withOpacity(0.2)
                          : unitColor.withOpacity(0.2),
                  border: Border.all(
                    color: isLocked
                        ? Colors.grey.withOpacity(0.5)
                        : isCompleted
                            ? Colors.green
                            : unitColor,
                  ),
                ),
                child: Icon(
                  isLocked
                      ? Icons.lock
                      : isCompleted
                          ? Icons.check_circle
                          : Icons.play_circle_outline,
                  color: isLocked
                      ? Colors.grey
                      : isCompleted
                          ? Colors.green
                          : unitColor,
                ),
              ),
              const SizedBox(width: 16),

              // Lesson info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lesson.progress.clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: isDark ? Colors.white10 : Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isLocked ? Colors.grey : unitColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


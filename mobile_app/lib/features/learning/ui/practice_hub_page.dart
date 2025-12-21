import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/skill_planet.dart';
import '../learning_routes.dart';
import 'lesson_start_page.dart';
import '../data/lesson_model.dart';
import '../data/mock/mock_data.dart';

class PracticeHubPage extends StatelessWidget {
  const PracticeHubPage({super.key});

  static const routeName = LearningRoutes.practiceHub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock weak skills
    final weakSkills = [
      Skill.listening,
      Skill.writing,
    ];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Practice Hub'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                  Text(
                    'Practice Weak Skills',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Focus on areas that need improvement',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Weak skills
            Text(
              'Skills to practice',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...weakSkills.map((skill) => _SkillPracticeCard(
              skill: skill,
              onTap: () {
                // Navigate to practice lesson for this skill
                final lesson = MockLearningData.lesson1();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LessonStartPage(
                      lesson: lesson,
                      skill: skill,
                    ),
                  ),
                );
              },
            )),
            const SizedBox(height: 24),

            // Quick practice
            Text(
              'Quick practice',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _QuickPracticeCard(
              title: 'Review all mistakes',
              icon: Icons.rate_review,
              onTap: () {
                // Navigate to mistakes review
              },
            ),
            const SizedBox(height: 12),
            _QuickPracticeCard(
              title: 'Spaced repetition',
              icon: Icons.refresh,
              onTap: () {
                // Navigate to review queue
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillPracticeCard extends StatelessWidget {
  final Skill skill;
  final VoidCallback onTap;

  const _SkillPracticeCard({
    required this.skill,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Icon(skill.icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Practice this skill',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
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

class _QuickPracticeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickPracticeCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isDark ? BBColors.darkCard : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
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


import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../learning_routes.dart';

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  static const routeName = LearningRoutes.achievements;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock achievements
    final achievements = [
      _Achievement(
        id: '1',
        title: 'First Steps',
        description: 'Complete your first lesson',
        icon: Icons.flag,
        unlocked: true,
      ),
      _Achievement(
        id: '2',
        title: 'Week Warrior',
        description: 'Practice 7 days in a row',
        icon: Icons.local_fire_department,
        unlocked: true,
      ),
      _Achievement(
        id: '3',
        title: 'Perfect Score',
        description: 'Get 100% accuracy in a lesson',
        icon: Icons.stars,
        unlocked: false,
      ),
      _Achievement(
        id: '4',
        title: 'Speed Demon',
        description: 'Complete a lesson in under 5 minutes',
        icon: Icons.speed,
        unlocked: false,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your achievements',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ...achievements.map((achievement) => _AchievementCard(
              achievement: achievement,
            )),
          ],
        ),
      ),
    );
  }
}

class _Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  _Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

class _AchievementCard extends StatelessWidget {
  final _Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: achievement.unlocked
          ? (isDark ? BBColors.darkCard : Colors.white)
          : (isDark ? BBColors.darkCard.withOpacity(0.5) : Colors.white.withOpacity(0.5)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.unlocked
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: achievement.unlocked
                      ? theme.colorScheme.primary
                      : Colors.grey,
                ),
              ),
              child: Icon(
                achievement.icon,
                color: achievement.unlocked
                    ? theme.colorScheme.primary
                    : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: achievement.unlocked
                          ? (isDark ? Colors.white : Colors.black87)
                          : (isDark ? Colors.white38 : Colors.black38),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: achievement.unlocked
                          ? (isDark ? Colors.white70 : Colors.black54)
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
            if (achievement.unlocked)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}


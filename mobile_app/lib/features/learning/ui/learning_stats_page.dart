import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../learning_routes.dart';

class LearningStatsPage extends StatelessWidget {
  const LearningStatsPage({super.key});

  static const routeName = LearningRoutes.learningStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock stats
    final totalXP = 1250;
    final totalLessons = 15;
    final totalTime = 120; // minutes
    final currentStreak = 5;
    final longestStreak = 12;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Learning Stats'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Total XP',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalXP',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatTile(
                  icon: Icons.book,
                  label: 'Lessons',
                  value: '$totalLessons',
                ),
                _StatTile(
                  icon: Icons.timer,
                  label: 'Time',
                  value: '$totalTime min',
                ),
                _StatTile(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '$currentStreak days',
                ),
                _StatTile(
                  icon: Icons.emoji_events,
                  label: 'Longest Streak',
                  value: '$longestStreak days',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}


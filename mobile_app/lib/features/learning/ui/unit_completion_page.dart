import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../data/unit_model.dart';
import '../learning_routes.dart';

class UnitCompletionPage extends StatelessWidget {
  final Unit unit;

  const UnitCompletionPage({
    super.key,
    required this.unit,
  });

  static const routeName = LearningRoutes.unitCompletion;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Crown/Completion icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.3),
                      Colors.orange.withOpacity(0.3),
                    ],
                  ),
                  border: Border.all(color: Colors.amber, width: 3),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unit Complete!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                unit.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? BBColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  children: [
                    _RewardItem(icon: Icons.stars, label: '+200 XP', color: Colors.amber),
                    const SizedBox(height: 12),
                    _RewardItem(icon: Icons.emoji_events, label: 'Unit Badge', color: Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continue Learning'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


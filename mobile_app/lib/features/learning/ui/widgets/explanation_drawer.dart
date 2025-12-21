import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ExplanationDrawer extends StatelessWidget {
  final String explanation;
  final VoidCallback onClose;

  const ExplanationDrawer({
    super.key,
    required this.explanation,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explanation',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            explanation,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


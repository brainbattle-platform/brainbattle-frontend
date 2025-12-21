import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

enum FeedbackType { correct, wrong, none }

class BottomFeedbackBar extends StatelessWidget {
  final FeedbackType type;
  final String? message;
  final VoidCallback? onContinue;

  const BottomFeedbackBar({
    super.key,
    this.type = FeedbackType.none,
    this.message,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (type == FeedbackType.none) {
      return const SizedBox.shrink();
    }

    final isCorrect = type == FeedbackType.correct;
    final color = isCorrect ? Colors.green : Colors.red;
    final icon = isCorrect ? Icons.check_circle : Icons.cancel;
    final defaultMessage = isCorrect ? 'Correct!' : 'Wrong answer';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? defaultMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onContinue != null)
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Continue'),
            ),
        ],
      ),
    );
  }
}


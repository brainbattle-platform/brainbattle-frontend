import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../practice_hub_page.dart';

class OutOfHeartsDialog extends StatelessWidget {
  final int timeUntilNextRefill; // seconds

  static const keyOutOfHeartsDialog = Key('out_of_hearts_dialog');

  const OutOfHeartsDialog({
    super.key,
    required this.timeUntilNextRefill,
  });

  static Future<void> show(BuildContext context, {required int timeUntilNextRefill}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OutOfHeartsDialog(timeUntilNextRefill: timeUntilNextRefill),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '$minutes:${secs.toString().padLeft(2, '0')}';
    }
    return '${secs}s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      key: OutOfHeartsDialog.keyOutOfHeartsDialog,
      backgroundColor: isDark ? BBColors.darkCard : Colors.white,
      title: Row(
        children: [
          const Icon(Icons.favorite_border, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            'Out of Hearts',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'ve run out of hearts!',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          if (timeUntilNextRefill > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Next heart in: ${_formatTime(timeUntilNextRefill)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Wait'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PracticeHubPage(),
              ),
            );
          },
          child: const Text('Practice to earn hearts'),
        ),
        // TODO: Add "Use streak freeze?" button if available
      ],
    );
  }
}


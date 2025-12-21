import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'hearts_indicator.dart';

class TopProgressHeader extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final VoidCallback? onClose;
  final int? currentLives;
  final int? maxLives;

  const TopProgressHeader({
    super.key,
    required this.currentIndex,
    required this.totalCount,
    this.onClose,
    this.currentLives,
    this.maxLives,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = (currentIndex + 1) / totalCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          if (currentLives != null && maxLives != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: HeartsIndicator(
                currentLives: currentLives!,
                maxLives: maxLives!,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentIndex + 1} of $totalCount',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


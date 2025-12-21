import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HeartsIndicator extends StatelessWidget {
  final int currentLives;
  final int maxLives;

  const HeartsIndicator({
    super.key,
    required this.currentLives,
    required this.maxLives,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxLives, (index) {
        final isFilled = index < currentLives;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Icon(
            Icons.favorite,
            size: 20,
            color: isFilled ? Colors.red : (isDark ? Colors.white24 : Colors.black26),
          ),
        );
      }),
    );
  }
}


import 'package:flutter/material.dart';

class ShortsLoadingSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;

  const ShortsLoadingSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white10 : Colors.grey[300]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}


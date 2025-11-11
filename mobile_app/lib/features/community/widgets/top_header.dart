import 'package:flutter/material.dart';

class TopHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions; // ví dụ: search, new, settings
  final EdgeInsetsGeometry padding;

  const TopHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.padding = const EdgeInsets.fromLTRB(16, 8, 12, 12),
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            Text(
              title,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: .2,
              ),
            ),
            const Spacer(),
            ..._spaced(actions),
          ],
        ),
      ),
    );
  }

  List<Widget> _spaced(List<Widget> xs) {
    if (xs.isEmpty) return xs;
    return [
      for (int i = 0; i < xs.length; i++) ...[
        if (i != 0) const SizedBox(width: 8),
        xs[i],
      ]
    ];
  }
}

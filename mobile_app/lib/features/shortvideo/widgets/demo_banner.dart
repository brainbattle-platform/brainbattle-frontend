import 'package:flutter/material.dart';

/// Banner to show when using demo/mock data
class DemoBanner extends StatelessWidget {
  final bool visible;

  const DemoBanner({
    super.key,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'Demo data (offline)',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';

// theme & tokens
import '../../../core/theme/palette.dart';
import '../../../core/theme/tokens.dart';

// widgets nội bộ
import '../../../core/widgets/bb_card.dart';
import '../../../core/widgets/bb_button.dart';


class BattleInviteCard extends StatelessWidget {
  final String title; // e.g., "JLPT N5 – 1v1"
  final String subtitle; // e.g., "Starts in 10 min • Created by @Hana"
  final VoidCallback onJoin;
  final VoidCallback? onDetails;
  const BattleInviteCard({super.key, required this.title, required this.subtitle, required this.onJoin, this.onDetails});

  @override
  Widget build(BuildContext context) {
    return BBCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [BBPalette.pink, BBPalette.purple, BBPalette.pink]),
              boxShadow: BBShadows.neon,
            ),
            child: const Icon(Icons.sports_martial_arts, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: BBPalette.textDim)),
                const SizedBox(height: 12),
                Row(children: [
                  BBButton.primary('Join Now', onPressed: onJoin, icon: Icons.flash_on),
                  const SizedBox(width: 10),
                  BBButton.ghost('Details', onPressed: onDetails, icon: Icons.info_outline),
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
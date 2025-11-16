import 'package:flutter/material.dart';

// theme & tokens
import '../../../core/theme/palette.dart';

// widgets
import '../../../core/widgets/bb_button.dart';
import '../../../core/widgets/bb_card.dart';

class BattleInviteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onJoin;
  final VoidCallback? onDetails;

  const BattleInviteCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onJoin,
    this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    return BBCard(
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1630), Color(0xFF141428)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: Colors.white10),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Battle Icon Circle ---
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE86FFF),
                    Color(0xFF8F5BFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: const Icon(
                Icons.sports_martial_arts_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 14),

            // --- Content ---
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: BBPalette.textDim,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ---- Buttons ----
                  Row(
                    children: [
                      Expanded(
                        child: BBButton.primary(
                          'Join Now',
                          icon: Icons.flash_on_rounded,
                          onPressed: onJoin,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: BBButton.ghost(
                          'Details',
                          icon: Icons.info_outline_rounded,
                          onPressed: onDetails,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

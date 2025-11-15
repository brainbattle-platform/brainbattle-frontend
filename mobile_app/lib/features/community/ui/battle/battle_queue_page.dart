// lib/features/community/battle/battle_queue_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/top_header.dart';
import '../../widgets/card_container.dart';
import '../../widgets/battle_invite_card.dart';

class BattleQueuePage extends StatelessWidget {
  const BattleQueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: TopHeader(title: 'Battle'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList.separated(
              itemCount: 8,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => CardContainer(
                margin: const EdgeInsets.symmetric(vertical: 2),
                child: BattleInviteCard(
                  title: 'Room #$i – IELTS Practice',
                  subtitle: 'Waiting 1/2 • 800 Elo • Created by @Han',
                  onJoin: () {
                    // TODO: call /battle/rooms/:id/request-join
                  },
                  onDetails: () {
                    // TODO: open detail sheet
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
        ],
      ),
    );
  }
}

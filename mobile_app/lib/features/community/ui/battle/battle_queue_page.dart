import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../widgets/top_header.dart';
import '../../widgets/card_container.dart';

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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => CardContainer(
                child: ListTile(
                  leading: const Icon(Icons.sports_martial_arts_rounded, color: Colors.white),
                  title: Text('Room #$i – IELTS Practice', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Waiting 1/2 • 800 Elo', style: TextStyle(color: Colors.white70)),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF3B4C3),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      // TODO: call /battle/rooms/:id/request-join
                    },
                    child: const Text('Request'),
                  ),
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

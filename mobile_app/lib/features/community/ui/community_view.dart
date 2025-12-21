import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'chats/chats_page.dart';
import 'battle/battle_queue_page.dart';
import '../community_routes.dart';

/// Community view widget - embedded in ShortVideoShell
/// This replaces the standalone CommunityShell route
class CommunityView extends StatefulWidget {
  const CommunityView({super.key});

  @override
  State<CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  int _index = 0;
  final _pages = [const ChatsPage(), const BattleQueuePage()];
  static const _accent = Color(0xFFF3B4C3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: _pages[_index],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 60,
              backgroundColor: const Color(0xFF2F2941), // "pill" nổi
              indicatorColor: _accent.withOpacity(0.22),
              iconTheme: MaterialStateProperty.resolveWith((states) {
                final selected = states.contains(MaterialState.selected);
                return IconThemeData(
                  color: selected ? Colors.black : Colors.white70,
                  size: selected ? 26 : 24,
                );
              }),
              labelTextStyle: MaterialStateProperty.resolveWith((states) {
                final selected = states.contains(MaterialState.selected);
                return TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: .2,
                  fontSize: 12,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.chat_bubble_outline_rounded),
                  selectedIcon: Icon(Icons.chat_bubble_rounded),
                  label: 'Chats',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sports_esports_outlined),
                  selectedIcon: Icon(Icons.sports_esports),
                  label: 'Battle',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              backgroundColor: _accent,
              foregroundColor: Colors.black,
              onPressed: _onNewClan,
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('New clan'),
            )
          : null,
    );
  }

  Future<void> _onNewClan() async {
    final result = await Navigator.pushNamed(context, CommunityRoutes.newClan);

    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      Navigator.pushNamed(
        context,
        CommunityRoutes.thread,
        arguments: ThreadArgs(result, title: 'New clan'),
      );
    }
  }
}


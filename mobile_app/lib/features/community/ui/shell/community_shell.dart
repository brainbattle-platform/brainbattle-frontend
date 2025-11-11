import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../chats/chats_page.dart';
import '../battle/battle_queue_page.dart';

class CommunityShell extends StatefulWidget {
  const CommunityShell({super.key});
  static const routeName = '/community';

  @override
  State<CommunityShell> createState() => _CommunityShellState();
}

class _CommunityShellState extends State<CommunityShell> {
  int _index = 0;
  final _pages = const [ChatsPage(), BattleQueuePage()];
  static const _accent = Color(0xFFF3B4C3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: _pages[_index],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 68,
          backgroundColor: const Color(0xFF2A243B),
          indicatorColor: _accent.withOpacity(0.18),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(color: selected ? _accent : Colors.white70, size: selected ? 28 : 26);
          }),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: .2,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
            NavigationDestination(icon: Icon(Icons.sports_esports_outlined), selectedIcon: Icon(Icons.sports_esports), label: 'Battle'),
          ],
        ),
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              backgroundColor: _accent,
              foregroundColor: Colors.black,
              onPressed: () {
                // TODO: tạo group chat
              },
              icon: const Icon(Icons.group_add_rounded),
              label: const Text('New group'),
            )
          : null,
    );
  }
}

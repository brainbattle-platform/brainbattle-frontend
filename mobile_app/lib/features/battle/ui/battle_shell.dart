import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_queue_page.dart';

class BattleShell extends StatelessWidget {
  const BattleShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BBColors.darkBg,
      child: const SafeArea(
        bottom: false,
        child: BattleQueuePage(),
      ),
    );
  }
}

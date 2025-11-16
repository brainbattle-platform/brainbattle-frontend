// lib/features/battle/ui/battle_flow.dart
import 'package:flutter/material.dart';
import '../battle_routes.dart';
import 'package:mobile_app/core/theme/app_theme.dart';

class BattleFlow extends StatelessWidget {
  const BattleFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: BBColors.darkBg,
      child: Navigator(
        initialRoute: BattleRoutes.mode,
        onGenerateRoute: BattleRoutes.onGenerateRoute,
      ),
    );
  }
}

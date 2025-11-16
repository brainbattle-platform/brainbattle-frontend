// lib/features/battle/battle_routes.dart
import 'package:flutter/material.dart';
import 'ui/battle_1v1_entry_page.dart';
import 'ui/battle_3v3_entry_page.dart';
// import các page khác dần dần

class BattleRoutes {
  // root cho flow battle (Navigator riêng)
  static const root = '/battle';

  // nested routes bên trong BattleFlow
  static const mode = '/battle/mode';
  static const v1Entry = '/battle/1v1/entry';
  static const v3Entry = '/battle/3v3/entry';
  static const v1Lobby = '/battle/1v1/lobby';
  static const v3Lobby = '/battle/3v3/lobby';
  static const play = '/battle/play';
  static const result = '/battle/result';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case v1Entry:
        return MaterialPageRoute(
          builder: (_) => const Battle1v1EntryPage(),
          settings: settings,
        );
      case v3Entry:
        return MaterialPageRoute(
          builder: (_) => const Battle3v3EntryPage(),
          settings: settings,
        );
      // v1Lobby, v3Lobby, play, result sẽ thêm sau
    }
    return null;
  }
}

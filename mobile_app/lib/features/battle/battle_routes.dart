// lib/features/battle/battle_routes.dart
import 'package:flutter/material.dart';
import 'ui/battle_queue_page.dart';
import 'ui/battle_1v1_entry_page.dart';
import 'ui/battle_3v3_entry_page.dart';
import 'ui/battle_1v1_lobby_page.dart';
import 'ui/battle_3v3_lobby_page.dart';
import 'ui/battle_play_page.dart';
import 'ui/battle_result_page.dart';

/// Single source of truth for all battle routes
/// All battle navigation should use BattleRoutes constants
class BattleRoutes {
  // Root route for battle flow (nested Navigator)
  static const root = '/battle';

  // Nested routes inside BattleFlow
  static const mode = '/battle/mode';
  static const v1Entry = '/battle/1v1/entry';
  static const v3Entry = '/battle/3v3/entry';
  static const v1Lobby = '/battle/1v1/lobby';
  static const v3Lobby = '/battle/3v3/lobby';
  static const play = '/battle/play';
  static const result = '/battle/result';

  /// Generate routes for nested Navigator in BattleFlow
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mode:
        return MaterialPageRoute(
          builder: (_) => const BattleQueuePage(),
          settings: settings,
        );
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
      case v1Lobby:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => Battle1v1LobbyPage(
              roomCode: args['roomCode'] as String? ?? '',
              battleType: args['battleType'] as String? ?? 'MIXED',
              isHost: args['isHost'] as bool? ?? false,
            ),
            settings: settings,
          );
        }
        return null;
      case v3Lobby:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => Battle3v3LobbyPage(
              roomCode: args['roomCode'] as String? ?? '',
              isHost: args['isHost'] as bool? ?? false,
            ),
            settings: settings,
          );
        }
        return null;
      case play:
        return MaterialPageRoute(
          builder: (_) => const BattlePlayPage(),
          settings: settings,
        );
      case result:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BattleResultPage(
              isWinner: args['isWinner'] as bool? ?? false,
            ),
            settings: settings,
          );
        }
        return MaterialPageRoute(
          builder: (_) => const BattleResultPage(isWinner: false),
          settings: settings,
        );
      default:
        return null;
    }
  }
}

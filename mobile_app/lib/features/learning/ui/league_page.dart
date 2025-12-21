import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../learning_routes.dart';

class LeaguePage extends StatelessWidget {
  const LeaguePage({super.key});

  static const routeName = LearningRoutes.league;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Mock leaderboard
    final leaderboard = [
      _LeaderboardEntry(rank: 1, name: 'Alice', xp: 2450, isMe: false),
      _LeaderboardEntry(rank: 2, name: 'Bob', xp: 2300, isMe: false),
      _LeaderboardEntry(rank: 3, name: 'You', xp: 2150, isMe: true),
      _LeaderboardEntry(rank: 4, name: 'Charlie', xp: 2000, isMe: false),
      _LeaderboardEntry(rank: 5, name: 'Diana', xp: 1850, isMe: false),
    ];

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Weekly League'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // League info
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.primary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Bronze League',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Week ends in 3 days',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Leaderboard
            Text(
              'Leaderboard',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...leaderboard.map((entry) => _LeaderboardRow(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isMe;

  _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    required this.isMe,
  });
}

class _LeaderboardRow extends StatelessWidget {
  final _LeaderboardEntry entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color? rankColor;
    IconData? rankIcon;
    if (entry.rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (entry.rank == 2) {
      rankColor = Colors.grey;
      rankIcon = Icons.emoji_events;
    } else if (entry.rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.emoji_events;
    }

    return Card(
      color: entry.isMe
          ? theme.colorScheme.primary.withOpacity(0.1)
          : (isDark ? BBColors.darkCard : Colors.white),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rankColor?.withOpacity(0.2) ?? Colors.transparent,
                border: rankColor != null
                    ? Border.all(color: rankColor)
                    : null,
              ),
              child: Center(
                child: rankIcon != null
                    ? Icon(rankIcon, color: rankColor, size: 20)
                    : Text(
                        '#${entry.rank}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Text(
                entry.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: entry.isMe ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // XP
            Text(
              '${entry.xp} XP',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


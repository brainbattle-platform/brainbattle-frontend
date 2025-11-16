import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_play_page.dart';

enum BattleRole { listening, reading, writing }

class Battle3v3LobbyPage extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const Battle3v3LobbyPage({
    super.key,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<Battle3v3LobbyPage> createState() => _Battle3v3LobbyPageState();
}

class _Battle3v3LobbyPageState extends State<Battle3v3LobbyPage> {
  final Set<BattleRole> _takenMyTeam = {};
  BattleRole? _myRole = BattleRole.listening;

  @override
  void initState() {
    super.initState();
    _takenMyTeam.add(_myRole!);
  }

  void _pickRole(BattleRole role) {
    if (_takenMyTeam.contains(role) && _myRole != role) return;
    setState(() {
      _takenMyTeam
        ..remove(_myRole)
        ..add(role);
      _myRole = role;
    });
  }

  String roleLabel(BattleRole r) {
    switch (r) {
      case BattleRole.listening:
        return 'Listening';
      case BattleRole.reading:
        return 'Reading';
      case BattleRole.writing:
        return 'Writing';
    }
  }

  // ----------------------------------------------------------------------
  // TEAM PANEL — FIX: only show YOUR role, others always icons or "?"
  // ----------------------------------------------------------------------

  Widget teamPanel(String title, {bool myTeam = false}) {
    final players = myTeam
        ? ['You', 'Teammate', null]   // you + 1 teammate + empty
        : ['Enemy 1', 'Enemy 2', 'Enemy 3']; // enemies

    // Determine role for YOU only
    BattleRole? roleOf(int index) {
      if (myTeam && index == 0) {
        return _myRole; // ONLY YOU
      }
      return null; // teammates do NOT get role from you
    }

    Icon roleIcon(BattleRole? r) {
      if (r == null) {
        return const Icon(Icons.help_outline,
            size: 18, color: Colors.white24);
      }

      IconData icon;
      switch (r) {
        case BattleRole.listening:
          icon = Icons.headphones_rounded;
          break;
        case BattleRole.reading:
          icon = Icons.menu_book_rounded;
          break;
        case BattleRole.writing:
          icon = Icons.edit_note_rounded;
          break;
      }

      return Icon(icon, size: 18, color: Colors.white70);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1630), Color(0xFF141428)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 10),

          for (int i = 0; i < 3; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFF2B1640),
                    child: Icon(Icons.person,
                        size: 16, color: Colors.white70),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      players[i] ?? 'Empty slot',
                      style: TextStyle(
                        color: players[i] == null
                            ? Colors.white24
                            : Colors.white,
                        fontWeight: players[i] == 'You'
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),

                  // 🔥 ONLY YOU has TEXT role
                  if (players[i] == 'You')
                    Text(
                      roleLabel(_myRole!),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    )
                  else
                    // 🔥 Everyone else = ? icon (until real data comes from server)
                    roleIcon(roleOf(i)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------------
  // ROLE CHIP STYLE
  // ----------------------------------------------------------------------

  Widget roleChip(BattleRole role, ThemeData theme) {
    final isSelected = _myRole == role;
    final isTaken = _takenMyTeam.contains(role) && !isSelected;

    final bgColor = isTaken
        ? Colors.white12
        : isSelected
            ? theme.colorScheme.primary
            : const Color(0xFF2B1640);

    final textColor = isTaken
        ? Colors.white38
        : isSelected
            ? Colors.black
            : Colors.white;

    return GestureDetector(
      onTap: isTaken ? null : () => _pickRole(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: bgColor,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.5),
                    blurRadius: 14,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          roleLabel(role),
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // MAIN UI
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: const Text(
          '3v3 Lobby',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ROOM CODE -----------------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1630), Color(0xFF141428)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Text(
                    'Room code:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.roomCode.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Each team has 3 players and each role must be unique.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 16),

            // TEAMS PANEL ---------------------------------------------------
            Expanded(
              child: Row(
                children: [
                  Expanded(child: teamPanel('Team A (Your team)', myTeam: true)),
                  const SizedBox(width: 12),
                  Expanded(child: teamPanel('Team B')),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ROLE PICK -----------------------------------------------------
            Text(
              'Your role: ${roleLabel(_myRole!)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: BattleRole.values
                  .map((r) => roleChip(r, theme))
                  .toList(),
            ),

            const SizedBox(height: 22),

            // BUTTONS -------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Share code',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BattlePlayPage(),
                        ),
                      );
                    },
                    child: Text(
                      widget.isHost ? 'Start battle' : 'Ready',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

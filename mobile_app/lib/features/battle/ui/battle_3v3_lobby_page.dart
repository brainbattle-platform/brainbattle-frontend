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
  // giả lập state: role đã pick trong team mình
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
    // TODO: call API pick role
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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

    Widget teamPanel(String title, {bool myTeam = false}) {
      // giả lập dữ liệu
      final players = myTeam
          ? ['You', 'Teammate', null]
          : ['Enemy 1', 'Enemy 2', 'Enemy 3'];
      final roles = myTeam
          ? [
              _myRole == BattleRole.listening ? 'Listening' : null,
              _takenMyTeam.contains(BattleRole.reading) ? 'Reading' : null,
              _takenMyTeam.contains(BattleRole.writing) ? 'Writing' : null,
            ]
          : ['Listening', 'Reading', 'Writing'];

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141428),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (int i = 0; i < 3; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black.withOpacity(0.15),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF2B1640),
                      child:
                          Icon(Icons.person, size: 14, color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      players[i] ?? 'Empty slot',
                      style: TextStyle(
                        color: players[i] == null
                            ? Colors.white30
                            : Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      roles[i] ?? '-',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    Widget roleChip(BattleRole role) {
      final isSelected = _myRole == role;
      final isTaken = _takenMyTeam.contains(role) && !isSelected;

      final bg = isTaken
          ? Colors.white12
          : (isSelected ? theme.colorScheme.primary : const Color(0xFF2B1640));
      final txt = isTaken
          ? Colors.white38
          : (isSelected ? Colors.black : Colors.white);

      return GestureDetector(
        onTap: isTaken ? null : () => _pickRole(role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: bg,
          ),
          child: Text(
            roleLabel(role),
            style: TextStyle(color: txt, fontSize: 12),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('3v3 Lobby'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                  icon: const Icon(Icons.copy_rounded,
                      size: 18, color: Colors.white60),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Mỗi bên tối đa 3 người, mỗi người giữ một vai trò duy nhất.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: Row(
                children: [
                  Expanded(child: teamPanel('Team A (Your team)', myTeam: true)),
                  const SizedBox(width: 12),
                  Expanded(child: teamPanel('Team B')),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Your role: ${_myRole != null ? roleLabel(_myRole!) : 'None'}',
                style:
                    const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: BattleRole.values.map(roleChip).toList(),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // share code
                    },
                    child: const Text(
                      'Share code',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      // TODO: chỉ allow host + đủ role
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BattlePlayPage(),
                        ),
                      );
                    },
                    child: Text(
                      widget.isHost ? 'Start battle' : 'Ready',
                      style: const TextStyle(fontWeight: FontWeight.w600),
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

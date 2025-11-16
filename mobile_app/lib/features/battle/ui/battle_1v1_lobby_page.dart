import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_play_page.dart';

class Battle1v1LobbyPage extends StatelessWidget {
  final String roomCode;
  final String battleType;
  final bool isHost;

  const Battle1v1LobbyPage({
    super.key,
    required this.roomCode,
    required this.battleType,
    required this.isHost,
  });

  String _battleTypeLabel() {
    switch (battleType) {
      case 'LISTENING':
        return 'Listening battle';
      case 'READING':
        return 'Reading battle';
      case 'WRITING':
        return 'Writing battle';
      case 'MIXED':
        return 'Mixed (Listening + Reading + Writing)';
      default:
        return 'Mode set by host';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget playerSlot(String name,
        {bool me = false, bool waiting = false}) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF151528),
              Color(0xFF10101E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: me ? theme.colorScheme.primary : Colors.white12,
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor:
                  me ? theme.colorScheme.primary : const Color(0xFF2B1640),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                waiting ? 'Waiting for opponent…' : name,
                style: TextStyle(
                  color: waiting ? Colors.white38 : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (me)
              const Text(
                'You',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        title: const Text('1v1 Lobby'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // room code card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFF141428),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Room code',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        roomCode.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.6,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: copy to clipboard
                    },
                    icon: const Icon(
                      Icons.copy_rounded,
                      size: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Share this code so your opponent can join the duel.',
              style: TextStyle(color: Colors.white54, fontSize: 11),
            ),
            const SizedBox(height: 18),

            // players row
            Row(
              children: [
                Expanded(child: playerSlot('You', me: true)),
                const SizedBox(width: 12),
                Expanded(child: playerSlot('', waiting: true)),
              ],
            ),
            const SizedBox(height: 20),

            // battle mode info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1E1632),
                    Color(0xFF151527),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.colorScheme.primary.withOpacity(0.16),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _battleTypeLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Each duel has 10 questions. Scoring and timing are handled by the system.',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // bottom buttons
            if (isHost)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // TODO: only enable when 2 players are ready
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BattlePlayPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Start battle',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    side:
                        const BorderSide(color: Colors.white24, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    // TODO: toggle ready state
                  },
                  child: const Text(
                    'Waiting for host…',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

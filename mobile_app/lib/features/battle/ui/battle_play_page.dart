import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_result_page.dart';

class BattlePlayPage extends StatelessWidget {
  const BattlePlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            const _BattleAppBar(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _BattleHeaderVS(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _ProgressAndTimer(),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: const [
                    _QuestionCard(),
                    SizedBox(height: 12),
                    Expanded(
                      child: _AnswerList(),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ReactionBar(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BattleAppBar extends StatelessWidget {
  const _BattleAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded,
                size: 20, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Text(
            "BrainBattle",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          Row(
            children: const [
              Icon(Icons.wifi, size: 16, color: Colors.greenAccent),
              SizedBox(width: 4),
              Text(
                "23 ms",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BattleHeaderVS extends StatelessWidget {
  const _BattleHeaderVS();

  @override
  Widget build(BuildContext context) {
    TextStyle nameStyle =
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    TextStyle scoreStyle =
        const TextStyle(color: Colors.white70, fontSize: 12);

    Widget playerBox(String name, String score, {bool isMe = false}) {
      return Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
                isMe ? const Color(0xFFE86FFF) : const Color(0xFF8F5BFF),
            child: const CircleAvatar(
              radius: 22,
              backgroundImage:
                  AssetImage('assets/avatar_placeholder.png'),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: nameStyle),
          Text("Score: $score", style: scoreStyle),
        ],
      );
    }

    return Row(
      children: [
        playerBox("You", "1200", isMe: true),
        const Spacer(),
        Column(
          children: const [
            Text(
              "VS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Combo x2",
              style: TextStyle(color: Colors.amber, fontSize: 12),
            )
          ],
        ),
        const Spacer(),
        playerBox("Rival", "1350"),
      ],
    );
  }
}

class _ProgressAndTimer extends StatelessWidget {
  const _ProgressAndTimer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Text(
              "Question 3 / 10",
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Spacer(),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            value: 0.3,
            minHeight: 6,
            backgroundColor: Colors.white10,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(Icons.timer, size: 16, color: Colors.white70),
            SizedBox(width: 4),
            Text("07s left",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2B1640), Color(0xFF17152B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Text(
        "Choose the correct synonym of “brilliant”.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.4,
        ),
      ),
    );
  }
}

class _AnswerList extends StatelessWidget {
  const _AnswerList();

  @override
  Widget build(BuildContext context) {
    final answers = ["Smart", "Shiny", "Broken", "Dark"];

    return Column(
      children: [
        for (final a in answers) ...[
          _AnswerOption(text: a),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final String text;

  const _AnswerOption({required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: handle choose answer
      },
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF141428),
          border:
              Border.all(color: const Color(0xFF3D2A5F), width: 1),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

class _ReactionBar extends StatelessWidget {
  const _ReactionBar();

  @override
  Widget build(BuildContext context) {
    final emojis = ["🔥", "😂", "😱", "👍", "💀"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: emojis
              .map(
                (e) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  child:
                      Text(e, style: const TextStyle(fontSize: 20)),
                ),
              )
              .toList(),
        ),
        TextButton(
          onPressed: () {
            // TODO: mở quick chat
          },
          child: const Text(
            "End battle",
            style:
                TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.white70),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BattleResultPage(
                  isWinner: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

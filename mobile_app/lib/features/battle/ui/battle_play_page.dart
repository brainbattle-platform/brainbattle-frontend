import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'battle_result_page.dart';

class BattlePlayPage extends StatelessWidget {
  const BattlePlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // APP BAR
            const _BattleAppBar(),

            // PLAYER VS PANEL
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: _BattleHeaderVS(),
            ),

            // TIMER + PROGRESS
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _ProgressAndTimer(),
            ),

            const SizedBox(height: 12),

            // QUESTION + ANSWERS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    _QuestionCard(),
                    SizedBox(height: 16),
                    Expanded(child: _AnswerList()),
                  ],
                ),
              ),
            ),

            // REACTIONS
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _ReactionBar(),
            ),
          ],
        ),
      ),
    );
  }
}

//
// APP BAR
//

class _BattleAppBar extends StatelessWidget {
  const _BattleAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B1640),
            Color(0xFF1A132B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          // BACK BUTTON
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // TITLE
          const Text(
            "BrainBattle",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 1.1,
            ),
          ),

          const Spacer(),

          // PING INDICATOR
          Row(
            children: const [
              Icon(Icons.wifi_rounded,
                  color: Colors.greenAccent, size: 16),
              SizedBox(width: 4),
              Text(
                "23 ms",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


//
// PLAYERS VS HEADER
//

class _BattleHeaderVS extends StatelessWidget {
  const _BattleHeaderVS();

  @override
  Widget build(BuildContext context) {
    TextStyle nameStyle =
        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600);
    TextStyle scoreStyle =
        const TextStyle(color: Colors.white60, fontSize: 12);

    Widget playerBox(String name, String score, {bool isMe = false}) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMe
                  ? const LinearGradient(
                      colors: [Color(0xFFE86FFF), Color(0xFF8F5BFF)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF6D4AFF), Color(0xFF4C2AAF)],
                    ),
            ),
            child: const CircleAvatar(
              radius: 26,
              backgroundImage: AssetImage('assets/avatar_placeholder.png'),
            ),
          ),
          const SizedBox(height: 6),
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
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Combo x2",
              style: TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        playerBox("Rival", "1350"),
      ],
    );
  }
}

//
// PROGRESS + TIMER
//

class _ProgressAndTimer extends StatelessWidget {
  const _ProgressAndTimer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: const [
          Text(
            "Question 3 / 10",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Spacer(),
        ]),

        const SizedBox(height: 6),

        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            value: 0.3,
            minHeight: 7,
            backgroundColor: Colors.white12,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          children: const [
            Icon(Icons.timer_rounded, size: 16, color: Colors.white70),
            SizedBox(width: 4),
            Text("07s left",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

//
// QUESTION CARD
//

class _QuestionCard extends StatelessWidget {
  const _QuestionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF271533), Color(0xFF171525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text(
        "Choose the correct synonym of “brilliant”.",
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.45,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

//
// ANSWER OPTIONS
//

class _AnswerList extends StatelessWidget {
  const _AnswerList();

  @override
  Widget build(BuildContext context) {
    final answers = ["Smart", "Shiny", "Broken", "Dark"];

    return Column(
      children: [
        for (final a in answers) ...[
          _AnswerOption(text: a),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AnswerOption extends StatefulWidget {
  final String text;

  const _AnswerOption({required this.text});

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => selected = !selected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1630), Color(0xFF141428)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : const Color(0xFF3D2A5F),
            width: 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          widget.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}

//
// REACTION BAR
//

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
              .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ))
              .toList(),
        ),

        TextButton(
          onPressed: () {},
          child: const Text(
            "End battle",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),

        IconButton(
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white70),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BattleResultPage(isWinner: true),
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BattleResultPage extends StatelessWidget {
  final bool isWinner;

  const BattleResultPage({super.key, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = isWinner ? "Victory!" : "Defeat";
    final titleColor = isWinner
        ? const Color(0xFF6CE5E8)
        : const Color(0xFFFF7D8C);

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      appBar: AppBar(
        backgroundColor: BBColors.darkBg,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ),

      // BODY
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 6),
            const Text(
              "Battle Summary",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 18),

            // SCORE CARD ----------------------------------------------------
            _summaryCard(
              child: Row(
                children: [
                  _scoreColumn("Your score", "1240", highlight: true),
                  const Spacer(),
                  _scoreColumn("Opponent", "1130"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // XP + COINS ----------------------------------------------------
            _summaryCard(
              child: Row(
                children: const [
                  Icon(Icons.stars_rounded,
                      color: Color(0xFFF3B4C3), size: 24),
                  SizedBox(width: 10),
                  Text(
                    "+120 XP",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.monetization_on_rounded,
                      color: Color(0xFFFFEE58), size: 22),
                  SizedBox(width: 6),
                  Text(
                    "+30",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // TIMELINE ------------------------------------------------------
            Expanded(
              child: _summaryCard(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Answer Timeline",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          final correct = index % 3 != 0;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Text(
                                  "Q${index + 1}",
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 12),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: correct ? 1 : 0.25,
                                      minHeight: 6,
                                      backgroundColor: Colors.white10,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        correct
                                            ? const Color(0xFF6CE5E8)
                                            : const Color(0xFFFF7D8C),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Icon(
                                  correct
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: correct
                                      ? const Color(0xFF6CE5E8)
                                      : const Color(0xFFFF7D8C),
                                  size: 18,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BUTTONS -------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Back",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {
                      // TODO: implement rematch
                    },
                    child: const Text(
                      "Rematch",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
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

  // CARD WRAPPER STYLE
  Widget _summaryCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D1630), Color(0xFF141428)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: child,
    );
  }

  // SCORE COLUMN
  Widget _scoreColumn(String label, String score, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          score,
          style: TextStyle(
            color: highlight ? Colors.white : Colors.white70,
            fontSize: highlight ? 20 : 18,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

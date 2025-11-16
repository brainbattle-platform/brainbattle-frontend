import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class BattleResultPage extends StatelessWidget {
  final bool isWinner;

  const BattleResultPage({super.key, required this.isWinner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title = isWinner ? 'Victory!' : 'Defeat';
    final color =
        isWinner ? const Color(0xFF4DD0E1) : const Color(0xFFE57373);

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Colors.white70),
                  onPressed: () => Navigator.of(context).popUntil(
                    (route) => route.isFirst,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Battle summary',
                style:
                    TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 24),
              // điểm
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF141428),
                ),
                child: Row(
                  children: [
                    Column(
                      children: const [
                        Text(
                          'Your score',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '1240',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: const [
                        Text(
                          'Opponent',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '1130',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // xp + coin
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF141428),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.stars_rounded,
                        color: Color(0xFFF3B4C3)),
                    SizedBox(width: 10),
                    Text(
                      '+120 XP',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.monetization_on_rounded,
                        color: Color(0xFFFFEE58)),
                    SizedBox(width: 6),
                    Text(
                      '+30',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // timeline answer (dummy)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: const Color(0xFF141428),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Câu trả lời',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            final correct = index % 3 != 0;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    'Q${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value:
                                          correct ? 1 : 0.2, // fake
                                      minHeight: 4,
                                      backgroundColor: Colors.white10,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        correct
                                            ? const Color(0xFF4DD0E1)
                                            : const Color(0xFFE57373),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    correct
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: correct
                                        ? const Color(0xFF4DD0E1)
                                        : const Color(0xFFE57373),
                                    size: 16,
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
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Back',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        // TODO: rematch / new battle
                      },
                      child: const Text(
                        'Rematch',
                        style:
                            TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

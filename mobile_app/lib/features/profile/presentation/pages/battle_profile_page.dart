import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';

class BattleProfilePage extends StatefulWidget {
  final String userId;

  const BattleProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<BattleProfilePage> createState() => _BattleProfilePageState();
}

class _BattleProfilePageState extends State<BattleProfilePage> {
  final _repository = ProfileRepository();
  BattleStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await _repository.getBattleStats(widget.userId);
      if (mounted) {
        setState(() {
          _stats = stats;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinkColor = const Color(0xFFFF8FAB);

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : Colors.white,
      appBar: AppBar(
        title: const Text('Battle profile'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Failed to load stats'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: Rank badge + rank name
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark ? BBColors.darkCard : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Rank badge (large, 56x56)
                            if (_stats!.rankBadgeAsset != null)
                              Image.asset(
                                _stats!.rankBadgeAsset!,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: pinkColor.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.shield,
                                  size: 32,
                                  color: Color(0xFFFF8FAB),
                                ),
                              ),
                            const SizedBox(height: 16),
                            Text(
                              _stats!.rankName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Stats row
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Total Battles',
                              value: '${_stats!.totalBattles}',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Wins',
                              value: '${_stats!.wins}',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _StatBox(
                              label: 'Losses',
                              value: '${_stats!.losses}',
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatBox(
                              label: 'Win Rate',
                              value: '${(_stats!.winRate * 100).toStringAsFixed(1)}%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Battle history
                      Text(
                        'Battle history',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stats!.recentBattles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          return _BattleHistoryItem(
                            battle: _stats!.recentBattles[index],
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatBox({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayColor = color ?? (isDark ? Colors.white : Colors.black87);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: displayColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _BattleHistoryItem extends StatelessWidget {
  final BattleHistory battle;

  const _BattleHistoryItem({required this.battle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resultColor = battle.won
        ? Colors.green
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: resultColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Result badge (WIN/LOSE)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: resultColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              battle.won ? 'WIN' : 'LOSE',
              style: TextStyle(
                color: resultColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Opponent name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  battle.opponentName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  battle.timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          // Score
          Text(
            battle.score,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: resultColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}


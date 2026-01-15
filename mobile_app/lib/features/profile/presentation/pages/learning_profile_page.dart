import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';
import '../../ui/app_shell.dart';

class LearningProfilePage extends StatefulWidget {
  final String userId;

  const LearningProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<LearningProfilePage> createState() => _LearningProfilePageState();
}

class _LearningProfilePageState extends State<LearningProfilePage> {
  final _repository = ProfileRepository();
  LearningStats? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final stats = await _repository.getLearningStats(widget.userId);
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

  void _onContinueLearning() {
    Navigator.pop(context);
    // Navigate to Learning Map (index 1) in PageView
    AppShell.navigateToPage(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : Colors.white,
      appBar: AppBar(
        title: const Text('Learning profile'),
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
                      // Level + XP progress
                      _StatsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level ${_stats!.level}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _stats!.currentXp / _stats!.nextLevelXp,
                                minHeight: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF8FAB),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_stats!.currentXp} / ${_stats!.nextLevelXp} XP',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Streak days
                      _StatsCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Streak',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_stats!.streakDays} days',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFFF8FAB),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Units completed
                      _StatsCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Units completed',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_stats!.unitsCompleted} / ${_stats!.totalUnits}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.book,
                              color: Color(0xFFFF8FAB),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Planets completed
                      _StatsCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Planets completed',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black54,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_stats!.planetsCompleted}',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.public,
                              color: Color(0xFFFF8FAB),
                              size: 32,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Performance section
                      _StatsCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Performance',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // 2x2 grid
                            Row(
                              children: [
                                Expanded(
                                  child: _PerformanceItem(
                                    label: 'Lessons',
                                    value: '${_stats!.lessonsCompleted}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PerformanceItem(
                                    label: 'Quizzes',
                                    value: '${_stats!.quizzesCompleted}',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _PerformanceItem(
                                    label: 'Avg Score',
                                    value: '${_stats!.avgScore}%',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _PerformanceItem(
                                    label: 'Accuracy',
                                    value: '${(_stats!.accuracy * 100).toStringAsFixed(0)}%',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Recent attempts section
                      Text(
                        'Recent attempts',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: isDark ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ..._stats!.recentAttempts.map((attempt) => _AttemptItem(
                            attempt: attempt,
                          )),
                      const SizedBox(height: 32),
                      // CTA button
                      ElevatedButton(
                        onPressed: _onContinueLearning,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8FAB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue learning',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final Widget child;

  const _StatsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _PerformanceItem extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

class _AttemptItem extends StatelessWidget {
  final LearningAttempt attempt;

  const _AttemptItem({required this.attempt});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinkColor = const Color(0xFFFF8FAB);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? BBColors.darkCard : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Leading icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: pinkColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              attempt.mode == 'QUIZ'
                  ? Icons.quiz
                  : attempt.mode == 'VIDEO'
                      ? Icons.play_circle
                      : Icons.school,
              size: 18,
              color: pinkColor,
            ),
          ),
          const SizedBox(width: 12),
          // Lesson name and mode
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attempt.lessonName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pinkColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        attempt.mode,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: pinkColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      attempt.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Score (if available)
          if (attempt.score != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pinkColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${attempt.score}%',
                style: TextStyle(
                  color: pinkColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


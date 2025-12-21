import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/daily_service.dart';
import '../learning_routes.dart';
import '../core/streak_freeze_service.dart';

class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  static const routeName = LearningRoutes.streak;

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  int _streak = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final mission = await DailyService.instance.fetchToday();
    setState(() {
      _streak = mission.streak;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Streak'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Streak display
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.withOpacity(0.3),
                          Colors.red.withOpacity(0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          size: 64,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_streak',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'day streak',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Streak calendar (stub - simple grid)
                  Text(
                    'This week',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _StreakCalendar(streak: _streak),
                  const SizedBox(height: 24),

                  // Streak freeze
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.ac_unit, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Streak Freeze',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: isDark ? Colors.white : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Available: $_freezeCount',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _showFreezeDialog(context);
                                },
                                child: const Text('Use / Buy'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showFreezeDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? BBColors.darkCard : Colors.white,
        title: const Text('Streak Freeze'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have $_freezeCount streak freeze(s) available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Streak freeze protects your streak if you miss a day.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_freezeCount > 0)
            ElevatedButton(
              onPressed: () {
                // Freeze is automatically consumed when needed
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Freeze will be used automatically if needed')),
                );
              },
              child: const Text('Use'),
            ),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement purchase flow
              _freezeService.addFreezes(1).then((_) {
                _loadStreak();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase stub: +1 freeze')),
                );
              });
            },
            child: const Text('Buy (stub)'),
          ),
        ],
      ),
    );
  }

  void _showFreezeDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? BBColors.darkCard : Colors.white,
        title: const Text('Streak Freeze'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have $_freezeCount streak freeze(s) available.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Streak freeze protects your streak if you miss a day.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          if (_freezeCount > 0)
            ElevatedButton(
              onPressed: () {
                // Freeze is automatically consumed when needed
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Freeze will be used automatically if needed')),
                );
              },
              child: const Text('Use'),
            ),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement purchase flow
              _freezeService.addFreezes(1).then((_) {
                _loadStreak();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Purchase stub: +1 freeze')),
                );
              });
            },
            child: const Text('Buy (stub)'),
          ),
        ],
      ),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  final int streak;

  const _StreakCalendar({required this.streak});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 7,
      itemBuilder: (context, index) {
        final isCompleted = index < streak;
        return Container(
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.orange.withOpacity(0.3)
                : (isDark ? BBColors.darkCard : Colors.white),
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted
                  ? Colors.orange
                  : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                days[index],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              if (isCompleted)
                const Icon(Icons.check, size: 16, color: Colors.orange),
            ],
          ),
        );
      },
    );
  }
}


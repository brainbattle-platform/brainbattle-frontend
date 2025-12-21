import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../learning_routes.dart';

class DailyGoalPickerPage extends StatefulWidget {
  const DailyGoalPickerPage({super.key});

  static const routeName = LearningRoutes.dailyGoalPicker;

  @override
  State<DailyGoalPickerPage> createState() => _DailyGoalPickerPageState();
}

class _DailyGoalPickerPageState extends State<DailyGoalPickerPage> {
  int? _selectedMinutes;

  final List<int> _goalOptions = [5, 10, 15, 20, 30];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : null,
      appBar: AppBar(
        title: const Text('Daily Goal'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How many minutes do you want to practice each day?',
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ..._goalOptions.map((minutes) => _GoalOptionCard(
              minutes: minutes,
              isSelected: _selectedMinutes == minutes,
              onTap: () {
                setState(() => _selectedMinutes = minutes);
              },
            )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedMinutes == null
                    ? null
                    : () {
                        // TODO: Save goal
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Daily goal set to $_selectedMinutes minutes'),
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Set Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOptionCard extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOptionCard({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      color: isSelected
          ? theme.colorScheme.primary.withOpacity(0.2)
          : (isDark ? BBColors.darkCard : Colors.white),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark ? Colors.white10 : Colors.black12),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white30 : Colors.black26),
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Text(
                '$minutes minutes',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


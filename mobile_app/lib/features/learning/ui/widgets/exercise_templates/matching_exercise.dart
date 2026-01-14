import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/exercise_model.dart';

class MatchingExercise extends StatefulWidget {
  final ExerciseItem exercise;
  final Function(String answer)? onAnswer; // Nullable: null means disabled

  const MatchingExercise({
    super.key,
    required this.exercise,
    this.onAnswer,
  });

  @override
  State<MatchingExercise> createState() => _MatchingExerciseState();
}

class _MatchingExerciseState extends State<MatchingExercise> {
  final Map<String, String?> _matches = {}; // left -> right
  final List<String> _leftItems = [];
  final List<String> _rightItems = [];

  @override
  void initState() {
    super.initState();
    // Split options into left and right (assuming even split)
    final half = widget.exercise.options.length ~/ 2;
    _leftItems.addAll(widget.exercise.options.sublist(0, half));
    _rightItems.addAll(widget.exercise.options.sublist(half));
  }

  void _selectMatch(String left, String right) {
    if (widget.onAnswer == null) return; // Disabled during review
    setState(() {
      _matches[left] = right;
      // Build answer string
      final answer = _matches.entries
          .map((e) => '${e.key}-${e.value}')
          .join(',');
      widget.onAnswer!(answer);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? BBColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Text(
            widget.exercise.question,
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Matching area
        Row(
          children: [
            // Left column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _leftItems.map((left) {
                  final matchedRight = _matches[left];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () {
                        // Show bottom sheet to select right item
                        _showMatchSelector(context, left);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: matchedRight != null
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : (isDark ? BBColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: matchedRight != null
                                ? theme.colorScheme.primary
                                : (isDark ? Colors.white10 : Colors.black12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                left,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                            if (matchedRight != null)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 16),
            // Right column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _rightItems.map((right) {
                  final isMatched = _matches.values.contains(right);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isMatched
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : (isDark ? BBColors.darkCard : Colors.white),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isMatched
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white10 : Colors.black12),
                        ),
                      ),
                      child: Text(
                        right,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMatchSelector(BuildContext context, String left) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? BBColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match "$left" with:',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._rightItems.map((right) {
              final isMatched = _matches.values.contains(right);
              return ListTile(
                title: Text(right),
                enabled: !isMatched,
                onTap: () {
                  _selectMatch(left, right);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}


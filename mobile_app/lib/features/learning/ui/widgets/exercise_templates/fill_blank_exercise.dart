import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/exercise_model.dart';

class FillBlankExercise extends StatefulWidget {
  final ExerciseItem exercise;
  final Function(String answer)? onAnswer; // Nullable: null means disabled

  const FillBlankExercise({
    super.key,
    required this.exercise,
    this.onAnswer,
  });

  @override
  State<FillBlankExercise> createState() => _FillBlankExerciseState();
}

class _FillBlankExerciseState extends State<FillBlankExercise> {
  String? _selectedAnswer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question with blank
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

        // Word bank
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.exercise.options.map((option) {
            final isSelected = _selectedAnswer == option;

            return InkWell(
              onTap: widget.onAnswer == null
                  ? null
                  : () {
                      setState(() => _selectedAnswer = option);
                      widget.onAnswer!(option);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isDark ? BBColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white10 : Colors.black12),
                  ),
                ),
                child: Text(
                  option,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


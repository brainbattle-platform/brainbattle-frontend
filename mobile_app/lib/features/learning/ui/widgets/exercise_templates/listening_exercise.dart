import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../domain/exercise_model.dart';

class ListeningExercise extends StatefulWidget {
  final ExerciseItem exercise;
  final Function(String answer) onAnswer;

  const ListeningExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<ListeningExercise> createState() => _ListeningExerciseState();
}

class _ListeningExerciseState extends State<ListeningExercise> {
  String? _selectedAnswer;
  bool _isPlaying = false;

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
          child: Column(
            children: [
              Text(
                widget.exercise.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // Audio player stub
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: () {
                    setState(() => _isPlaying = !_isPlaying);
                    // STUB: No actual audio playback
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Audio playback (stub)',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Options (same as MCQ)
        ...widget.exercise.options.map((option) {
          final isSelected = _selectedAnswer == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedAnswer = option);
                widget.onAnswer(option);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : (isDark ? BBColors.darkCard : Colors.white),
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
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}


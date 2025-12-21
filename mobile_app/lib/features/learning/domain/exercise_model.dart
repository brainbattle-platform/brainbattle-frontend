import '../widgets/skill_planet.dart';

enum ExerciseType {
  mcq,      // Multiple choice
  fill,     // Fill in the blank
  match,    // Matching
  listen,   // Listening
}

class ExerciseItem {
  final String id;
  final ExerciseType type;
  final Skill skill;
  final String question;
  final String? questionAudio; // URL or path (stub for listening)
  final List<String> options; // For MCQ, Fill options, Match pairs
  final String correctAnswer;
  final String? explanation;
  final String? hint;
  final int timeLimit; // seconds (0 = no limit)

  ExerciseItem({
    required this.id,
    required this.type,
    required this.skill,
    required this.question,
    this.questionAudio,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.hint,
    this.timeLimit = 0,
  });
}

class AttemptResult {
  final String exerciseId;
  final String userAnswer;
  final bool isCorrect;
  final int timeSpent; // seconds
  final DateTime attemptedAt;

  AttemptResult({
    required this.exerciseId,
    required this.userAnswer,
    required this.isCorrect,
    required this.timeSpent,
    required this.attemptedAt,
  });
}


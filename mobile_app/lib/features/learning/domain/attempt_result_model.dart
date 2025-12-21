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


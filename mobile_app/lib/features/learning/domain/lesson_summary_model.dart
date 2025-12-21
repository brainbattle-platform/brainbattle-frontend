class LessonSummary {
  final String lessonId;
  final int xpGained;
  final double accuracy; // 0.0 - 1.0
  final int timeSpent; // seconds
  final int totalQuestions;
  final int correctCount;
  final int wrongCount;
  final List<String> mistakeIds; // Exercise IDs that were wrong
  final bool isCompleted;
  final bool streakProtected;

  LessonSummary({
    required this.lessonId,
    required this.xpGained,
    required this.accuracy,
    required this.timeSpent,
    required this.totalQuestions,
    required this.correctCount,
    required this.wrongCount,
    required this.mistakeIds,
    this.isCompleted = false,
    this.streakProtected = false,
  });
}


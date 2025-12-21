/// Single source of truth for all learning routes
/// All learning navigation should use LearningRoutes constants
class LearningRoutes {
  // Main entry
  static const lessons = '/lessons';
  
  // Core learning loop
  static const unitDetail = '/learning/unit/:id';
  static const lessonStart = '/learning/lesson/:id/start';
  static const exercisePlayer = '/learning/exercise/:lessonId';
  static const lessonSummary = '/learning/lesson/:id/summary';
  static const unitCompletion = '/learning/unit/:id/completion';
  
  // Practice & Review
  static const practiceHub = '/learning/practice';
  static const mistakesReview = '/learning/mistakes';
  static const reviewQueue = '/learning/review';
  
  // Progress & Motivation
  static const dailyGoalPicker = '/learning/goal';
  static const streak = '/learning/streak';
  static const league = '/learning/league';
  static const achievements = '/learning/achievements';
  static const learningStats = '/learning/stats';
  static const learningSettings = '/learning/settings';
  
  // Onboarding & Domain
  static const domainSelector = '/learning/domain';
  static const curriculumBrowser = '/learning/curriculum';
  static const placementTest = '/learning/placement-test';
  
  /// Helper to build route with params
  static String unitDetailWithId(String unitId) => unitDetail.replaceAll(':id', unitId);
  static String lessonStartWithId(String lessonId) => lessonStart.replaceAll(':id', lessonId);
  static String exercisePlayerWithId(String lessonId) => exercisePlayer.replaceAll(':lessonId', lessonId);
  static String lessonSummaryWithId(String lessonId) => lessonSummary.replaceAll(':id', lessonId);
  static String unitCompletionWithId(String unitId) => unitCompletion.replaceAll(':id', unitId);
}


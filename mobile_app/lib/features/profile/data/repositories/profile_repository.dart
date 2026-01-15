import '../models/profile_models.dart';

/// Mock repository for profile data
/// TODO: Replace with real API calls
class ProfileRepository {
  static final ProfileRepository _instance = ProfileRepository._internal();
  factory ProfileRepository() => _instance;
  ProfileRepository._internal();

  /// Map rankCode to badge asset path
  /// BRONZE -> assets/badges/rank_bronze.png
  /// SILVER -> assets/badges/rank_silver.png
  /// GOLD   -> assets/badges/rank_gold.png
  /// Fallback to BRONZE if null or unknown
  String _rankBadgeAsset(String? rankCode) {
    final code = (rankCode ?? 'BRONZE').toUpperCase();
    switch (code) {
      case 'BRONZE':
        return 'assets/badges/rank_bronze.png';
      case 'SILVER':
        return 'assets/badges/rank_silver.png';
      case 'GOLD':
        return 'assets/badges/rank_gold.png';
      default:
        return 'assets/badges/rank_bronze.png'; // Fallback
    }
  }

  /// Get basic profile info
  Future<ProfileBasic> getProfile(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final rankCode = 'GOLD';
    return ProfileBasic(
      id: userId,
      username: 'user1',
      displayName: 'User One',
      avatarUrl: 'https://i.pravatar.cc/150?img=${userId.hashCode % 70}',
      bio: 'Learning English through fun and battles! 🚀',
      rankCode: rankCode,
      rankBadgeAsset: _rankBadgeAsset(rankCode),
      followers: 120,
      following: 45,
      totalLikes: 1600,
    );
  }

  /// Get user videos (videos or liked)
  Future<List<VideoPreview>> getUserVideos(
    String userId, {
    required String tab,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock data
    final count = tab == 'videos' ? 12 : 8;
    return List.generate(count, (i) {
      return VideoPreview(
        id: 'video_${userId}_$i',
        thumbnailUrl: null, // Will use placeholder
        viewCount: (i + 1) * 123,
        durationSec: 15 + (i % 30),
        lessonTag: i % 3 == 0 ? 'Grammar' : null,
      );
    });
  }

  /// Get learning statistics
  Future<LearningStats> getLearningStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return LearningStats(
      level: 5,
      currentXp: 1250,
      nextLevelXp: 2000,
      streakDays: 7,
      unitsCompleted: 3,
      totalUnits: 10,
      planetsCompleted: 12,
      lessonsCompleted: 28,
      quizzesCompleted: 45,
      avgScore: 85,
      accuracy: 0.78,
      recentAttempts: [
        LearningAttempt(
          lessonName: 'Present Simple Tense',
          mode: 'QUIZ',
          score: 90,
          timeAgo: '2 hours ago',
        ),
        LearningAttempt(
          lessonName: 'Vocabulary: Food',
          mode: 'PRACTICE',
          score: 85,
          timeAgo: '1 day ago',
        ),
        LearningAttempt(
          lessonName: 'Listening: Daily Conversation',
          mode: 'VIDEO',
          score: null,
          timeAgo: '2 days ago',
        ),
        LearningAttempt(
          lessonName: 'Past Tense Review',
          mode: 'QUIZ',
          score: 92,
          timeAgo: '3 days ago',
        ),
        LearningAttempt(
          lessonName: 'Grammar: Articles',
          mode: 'PRACTICE',
          score: 78,
          timeAgo: '5 days ago',
        ),
      ],
    );
  }

  /// Get battle statistics
  Future<BattleStats> getBattleStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final rankCode = 'GOLD';
    return BattleStats(
      rankName: 'Gold',
      rankBadgeAsset: _rankBadgeAsset(rankCode),
      totalBattles: 45,
      wins: 28,
      losses: 17,
      winRate: 28 / 45,
      recentBattles: [
        BattleHistory(
          opponentName: 'PlayerA',
          won: true,
          score: '10-8',
          timeAgo: '2 hours ago',
        ),
        BattleHistory(
          opponentName: 'PlayerB',
          won: false,
          score: '7-10',
          timeAgo: '1 day ago',
        ),
        BattleHistory(
          opponentName: 'PlayerC',
          won: true,
          score: '10-5',
          timeAgo: '3 days ago',
        ),
        BattleHistory(
          opponentName: 'PlayerD',
          won: true,
          score: '10-6',
          timeAgo: '4 days ago',
        ),
        BattleHistory(
          opponentName: 'PlayerE',
          won: false,
          score: '8-10',
          timeAgo: '5 days ago',
        ),
        BattleHistory(
          opponentName: 'PlayerF',
          won: true,
          score: '10-7',
          timeAgo: '1 week ago',
        ),
        BattleHistory(
          opponentName: 'PlayerG',
          won: true,
          score: '10-4',
          timeAgo: '1 week ago',
        ),
        BattleHistory(
          opponentName: 'PlayerH',
          won: false,
          score: '6-10',
          timeAgo: '2 weeks ago',
        ),
        BattleHistory(
          opponentName: 'PlayerI',
          won: true,
          score: '10-9',
          timeAgo: '2 weeks ago',
        ),
        BattleHistory(
          opponentName: 'PlayerJ',
          won: true,
          score: '10-3',
          timeAgo: '3 weeks ago',
        ),
      ],
    );
  }
}

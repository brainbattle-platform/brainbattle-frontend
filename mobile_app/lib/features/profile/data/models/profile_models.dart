/// Profile data models

class ProfileBasic {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? rankCode;
  final String? rankBadgeAsset;
  final int followers;
  final int following;
  final int totalLikes;

  ProfileBasic({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.rankCode,
    this.rankBadgeAsset,
    required this.followers,
    required this.following,
    required this.totalLikes,
  });
}

class VideoPreview {
  final String id;
  final String? thumbnailUrl;
  final int viewCount;
  final int durationSec;
  final String? lessonTag;

  VideoPreview({
    required this.id,
    this.thumbnailUrl,
    required this.viewCount,
    required this.durationSec,
    this.lessonTag,
  });
}

class LearningStats {
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;
  final int unitsCompleted;
  final int totalUnits;
  final int planetsCompleted;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int avgScore; // 0-100
  final double accuracy; // 0..1
  final List<LearningAttempt> recentAttempts; // max 5

  LearningStats({
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.streakDays,
    required this.unitsCompleted,
    required this.totalUnits,
    required this.planetsCompleted,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
    required this.avgScore,
    required this.accuracy,
    required this.recentAttempts,
  });
}

class LearningAttempt {
  final String lessonName;
  final String mode; // QUIZ/PRACTICE/VIDEO
  final int? score; // nullable, 0-100
  final String timeAgo;

  LearningAttempt({
    required this.lessonName,
    required this.mode,
    this.score,
    required this.timeAgo,
  });
}

class BattleStats {
  final String rankName;
  final String? rankBadgeAsset;
  final int totalBattles;
  final int wins;
  final int losses;
  final double winRate;
  final List<BattleHistory> recentBattles;

  BattleStats({
    required this.rankName,
    this.rankBadgeAsset,
    required this.totalBattles,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.recentBattles,
  });
}

class BattleHistory {
  final String opponentName;
  final bool won; // true = win, false = loss
  final String score; // e.g., "10-8"
  final String timeAgo; // e.g., "2 hours ago"

  BattleHistory({
    required this.opponentName,
    required this.won,
    required this.score,
    required this.timeAgo,
  });
}


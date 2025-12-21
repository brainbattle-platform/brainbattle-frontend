import 'package:shared_preferences/shared_preferences.dart';
import '../core/streak_freeze_service.dart';

class DailyMission {
  final String title;
  final List<String> tasks;
  final DateTime resetAt;     // mốc reset (0h hôm sau)
  final int streak;           // chuỗi ngày
  final bool completedToday;

  DailyMission({
    required this.title,
    required this.tasks,
    required this.resetAt,
    required this.streak,
    required this.completedToday,
  });
}

class DailyService {
  static final DailyService instance = DailyService._();
  DailyService._();

  static const _kLastComplete = 'daily.last_complete';
  static const _kStreak = 'daily.streak';

  Future<DailyMission> fetchToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final resetAt = today.add(const Duration(days: 1)); // 0h hôm sau

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_kLastComplete);
    final lastDate = last != null ? DateTime.tryParse(last) : null;
    int streak = prefs.getInt(_kStreak) ?? 0;

    bool completedToday = lastDate != null &&
        lastDate.year == today.year &&
        lastDate.month == today.month &&
        lastDate.day == today.day;

    // Nếu qua ngày nhưng không hoàn thành hôm qua -> check streak freeze
    if (lastDate != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      final didYesterday = lastDate.year == yesterday.year &&
          lastDate.month == yesterday.month &&
          lastDate.day == yesterday.day;
      if (!didYesterday && !completedToday && lastDate.isBefore(yesterday)) {
        // Check if user has streak freeze
        final freezeService = StreakFreezeService.instance;
        final shouldConsume = await freezeService.shouldConsumeFreeze();
        if (!shouldConsume) {
          streak = 0;
          await prefs.setInt(_kStreak, streak);
        } else {
          // Freeze was consumed, keep streak
          await freezeService.setLastStreakDate(lastDate);
        }
      }
    }

    return DailyMission(
      title: "Daily Mission",
      tasks: const [
        "Làm 1 bài Nghe",
        "Hoàn thành 1 bài Đọc",
        "Ôn 10 từ vựng",
      ],
      resetAt: resetAt,
      streak: streak,
      completedToday: completedToday,
    );
  }

  Future<void> markCompletedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = prefs.getString(_kLastComplete);
    final lastDate = last != null ? DateTime.tryParse(last) : null;
    int streak = prefs.getInt(_kStreak) ?? 0;

    // tăng streak nếu hôm qua xong và hôm nay xong tiếp; nếu lần đầu cũng +1
    if (lastDate != null) {
      final yesterday = today.subtract(const Duration(days: 1));
      final didYesterday = lastDate.year == yesterday.year &&
          lastDate.month == yesterday.month &&
          lastDate.day == yesterday.day;
      final didTodayAlready = lastDate.year == today.year &&
          lastDate.month == today.month &&
          lastDate.day == today.day;
      if (!didTodayAlready) {
        streak = didYesterday ? streak + 1 : 1;
      }
    } else {
      streak = 1;
    }

    await prefs.setString(_kLastComplete, today.toIso8601String());
    await prefs.setInt(_kStreak, streak);
  }
}

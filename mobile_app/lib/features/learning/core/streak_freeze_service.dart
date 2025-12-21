import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage streak freeze items
class StreakFreezeService {
  static final StreakFreezeService instance = StreakFreezeService._();
  StreakFreezeService._();

  static const String _kFreezeCount = 'streak_freeze.count';
  static const String _kLastStreakDate = 'streak_freeze.last_date';

  /// Get current freeze count
  Future<int> getFreezeCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kFreezeCount) ?? 1; // Default 1 for demo
  }

  /// Use one freeze (when user misses a day)
  Future<int> useFreeze() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFreezeCount();
    if (current > 0) {
      final newCount = current - 1;
      await prefs.setInt(_kFreezeCount, newCount);
      return newCount;
    }
    return current;
  }

  /// Add freezes (for testing or purchase stub)
  Future<int> addFreezes(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getFreezeCount();
    final newCount = current + count;
    await prefs.setInt(_kFreezeCount, newCount);
    return newCount;
  }

  /// Check if user has any freezes
  Future<bool> hasFreeze() async {
    final count = await getFreezeCount();
    return count > 0;
  }

  /// Get last streak date (for checking if freeze should be consumed)
  Future<DateTime?> getLastStreakDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_kLastStreakDate);
    if (dateStr == null) return null;
    return DateTime.parse(dateStr);
  }

  /// Set last streak date
  Future<void> setLastStreakDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastStreakDate, date.toIso8601String());
  }

  /// Check if streak should be frozen (user missed a day but has freeze)
  Future<bool> shouldConsumeFreeze() async {
    final lastDate = await getLastStreakDate();
    if (lastDate == null) return false;
    
    final now = DateTime.now();
    final daysSince = now.difference(lastDate).inDays;
    
    // If more than 1 day passed and user has freeze, consume it
    if (daysSince > 1 && await hasFreeze()) {
      await useFreeze();
      return true;
    }
    
    return false;
  }
}


import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage hearts/lives system
class HeartsService {
  static final HeartsService instance = HeartsService._();
  HeartsService._();

  static const String _kCurrentLives = 'hearts.current';
  static const String _kLastRefillAt = 'hearts.last_refill';
  static const String _kMaxLives = 'hearts.max';

  static const int defaultMaxLives = 5;
  static const int refillIntervalMinutes = 30; // 1 heart per 30 minutes

  /// Get current lives count
  Future<int> getCurrentLives() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kCurrentLives) ?? defaultMaxLives;
    final max = prefs.getInt(_kMaxLives) ?? defaultMaxLives;
    
    // Check if we need to refill
    final lastRefill = prefs.getString(_kLastRefillAt);
    if (lastRefill != null) {
      final lastRefillTime = DateTime.parse(lastRefill);
      final now = DateTime.now();
      final minutesSinceRefill = now.difference(lastRefillTime).inMinutes;
      
      if (minutesSinceRefill >= refillIntervalMinutes) {
        final heartsToAdd = (minutesSinceRefill / refillIntervalMinutes).floor();
        final newLives = (current + heartsToAdd).clamp(0, max);
        await prefs.setInt(_kCurrentLives, newLives);
        await prefs.setString(_kLastRefillAt, now.toIso8601String());
        return newLives;
      }
    } else {
      // First time, set last refill to now
      await prefs.setString(_kLastRefillAt, DateTime.now().toIso8601String());
    }
    
    return current;
  }

  /// Get max lives
  Future<int> getMaxLives() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kMaxLives) ?? defaultMaxLives;
  }

  /// Consume one heart (when user answers wrong)
  Future<int> consumeHeart() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getCurrentLives();
    final newLives = (current - 1).clamp(0, await getMaxLives());
    await prefs.setInt(_kCurrentLives, newLives);
    return newLives;
  }

  /// Check if user has any lives left
  Future<bool> hasLives() async {
    final current = await getCurrentLives();
    return current > 0;
  }

  /// Refill hearts to max (for testing or special cases)
  Future<void> refillToMax() async {
    final prefs = await SharedPreferences.getInstance();
    final max = await getMaxLives();
    await prefs.setInt(_kCurrentLives, max);
    await prefs.setString(_kLastRefillAt, DateTime.now().toIso8601String());
  }

  /// Get time until next heart refill (in seconds)
  Future<int> getTimeUntilNextRefill() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRefill = prefs.getString(_kLastRefillAt);
    if (lastRefill == null) return 0;
    
    final lastRefillTime = DateTime.parse(lastRefill);
    final now = DateTime.now();
    final minutesSinceRefill = now.difference(lastRefillTime).inMinutes;
    
    if (minutesSinceRefill >= refillIntervalMinutes) {
      return 0; // Ready to refill
    }
    
    final secondsUntilRefill = (refillIntervalMinutes - minutesSinceRefill) * 60;
    return secondsUntilRefill;
  }
}


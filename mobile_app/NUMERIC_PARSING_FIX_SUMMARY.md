# Numeric JSON Parsing Fix - Summary

## Files Changed

1. ✅ `lib/core/utils/json_num.dart` (NEW)
2. ✅ `lib/features/learning/ui/exercise_player_page.dart`
3. ✅ `lib/features/learning/ui/lesson_start_page.dart`
4. ✅ `lib/features/learning/ui/practice_hub_page.dart`
5. ✅ `lib/features/learning/ui/galaxy_map_screen.dart`
6. ✅ `lib/features/learning/data/learning_api_client.dart`

## Key Model Parsing Changes

### Critical Fix: Quiz Finish Response

**File:** `lib/features/learning/ui/exercise_player_page.dart:387-391`

**Before (CRASHES):**
```dart
final accuracy = resultData['accuracy'] as double? ?? 0.0; // CRASH if backend returns int
final correctCount = resultData['correctCount'] as int? ?? 0;
final totalQuestions = resultData['totalQuestions'] as int? ?? _totalQuestions;
final xpEarned = resultData['xpEarned'] as int? ?? resultData['xpGained'] as int? ?? 0;
```

**After (SAFE):**
```dart
final correctCount = JsonNum.asIntOr(resultData['correctCount'], 0);
final totalQuestions = JsonNum.asIntOr(resultData['totalQuestions'], _totalQuestions);
final accuracy = JsonNum.asDoubleOr(resultData['accuracy'], 0.0); // ✅ FIXED
final xpEarned = JsonNum.asIntOr(resultData['xpEarned'], 
    JsonNum.asIntOr(resultData['xpGained'], 0));
```

### Other Parsing Fixes

**exercise_player_page.dart:**
- `currentQuestionIndex`: `as int?` → `JsonNum.asIntOr()`
- `totalQuestions`: `as int?` → `JsonNum.asIntOr()`
- `heartsRemaining`: `as int?` → `JsonNum.asIntOr()`
- `timeUntilNextRefill`: `as int?` → `JsonNum.asIntOr()`

**lesson_start_page.dart:**
- `totalQuestions`: `as int?` → `JsonNum.asIntOr()`
- `questionIndex`: `as int?` → `JsonNum.asIntOr()`
- `estimatedTimeMinutes`: `as int?` → `JsonNum.asIntOr()`
- `xpReward`: `as int?` → `JsonNum.asIntOr()`
- `heartsCurrent`: `as int?` → `JsonNum.asIntOr()`
- `heartsMax`: `as int?` → `JsonNum.asIntOr()`

**practice_hub_page.dart:**
- `bestScore`: `(as num?)?.toDouble()` → `JsonNum.asDoubleOr()` (normalized)

**galaxy_map_screen.dart:**
- `progressPercent`: `(as num?)?.toDouble()` → `JsonNum.asDoubleOr()` (normalized)

**learning_api_client.dart:**
- `timeLimit`: `as int?` → `JsonNum.asIntOr()`

## Endpoints/Models Updated Checklist

- [x] `POST /quiz/{attemptId}/finish` - `accuracy` (double), `correctCount` (int), `totalQuestions` (int), `xpEarned` (int)
- [x] `GET /api/learning/map` - `progressPercent` (double)
- [x] `GET /api/learning/practice/hub` - `bestScore` (double)
- [x] `GET /quiz/{attemptId}/question` - `currentQuestionIndex` (int), `totalQuestions` (int), `heartsRemaining` (int)
- [x] `GET /lessons/{lessonId}/overview` - `totalQuestions` (int), `estimatedTimeMinutes` (int), `xpReward` (int), `hearts.current` (int), `hearts.max` (int)
- [x] `POST /lessons/{lessonId}/start` - `totalQuestions` (int), `question.index` (int)
- [x] `POST /quiz/{attemptId}/answer` - `heartsRemaining` (int)
- [x] `GET /hearts` - `current` (int)
- [x] Exercise items - `timeLimit` (int)

## Finish Flow Error Handling

**File:** `lib/features/learning/ui/exercise_player_page.dart:450-479`

**Enhanced:**
- Shows SnackBar with error message (5 second duration)
- Provides "Retry" action button
- Keeps user on REVIEW state (does not crash)
- Resets flags: `_finishRequested = false`, `_isLoading = false` to allow retry

**Logs:**
- `[Flow] finish() parsed OK accuracy=<...> xp=<...>` - After successful parsing
- `[Flow] RESULT_SCREEN_PUSHED` - Before navigation (includes attemptId via `_logEvent`)

## Verification

### Expected Log Sequence (Success)
```
[TS ...] [Flow] finished detected from 404; calling finish once (attemptId=attempt-123)
[TS ...] [Flow] finish() called (attemptId=attempt-123)
[TS ...] [Flow] finish() parsed OK accuracy=1.0 xp=50 (attemptId=attempt-123)
[TS ...] [Flow] RESULT_SCREEN_PUSHED (attemptId=attempt-123)
[TS ...] Quiz screen dispose() (attemptId=attempt-123)
```

**No repeated finish() errors, no repeated /next calls.**



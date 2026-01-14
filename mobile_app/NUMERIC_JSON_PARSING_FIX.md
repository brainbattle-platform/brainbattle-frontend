# Numeric JSON Parsing Fix Report

## Problem

Production bug: Finish flow returns 201 from backend but UI does not show final result screen.

**Error:** `type 'int' is not a subtype of type 'double?' in type cast`

**Root Cause:** Backend returns JSON numbers that can be int or double:
- `accuracy: 1` (int) vs `accuracy: 1.0` (double)
- `bestScore: 0.2` (double) vs `bestScore: 1` (int)
- `xpEarned: 50` (int) vs `xpEarned: 50.0` (double)

Direct casts like `as double?` or `as int?` fail when backend returns the opposite type.

## Solution

### A) Created Safe Numeric Parsing Helper

**File:** `lib/core/utils/json_num.dart`

**Helpers:**
- `JsonNum.asDouble(dynamic v)` - Returns `double?`, handles both int and double
- `JsonNum.asInt(dynamic v)` - Returns `int?`, handles both int and double
- `JsonNum.asDoubleOr(dynamic v, double fallback)` - Returns `double` with fallback
- `JsonNum.asIntOr(dynamic v, int fallback)` - Returns `int` with fallback

**Implementation:**
```dart
static double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return null;
}
```

### B) Replaced All Unsafe Casts

**Files Updated:**

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - `accuracy`: `as double?` → `JsonNum.asDoubleOr()`
   - `correctCount`: `as int?` → `JsonNum.asIntOr()`
   - `totalQuestions`: `as int?` → `JsonNum.asIntOr()`
   - `xpEarned`: `as int?` → `JsonNum.asIntOr()`
   - `heartsRemaining`: `as int?` → `JsonNum.asIntOr()`
   - `currentQuestionIndex`: `as int?` → `JsonNum.asIntOr()`
   - `timeUntilNextRefill`: `as int?` → `JsonNum.asIntOr()`

2. ✅ `lib/features/learning/ui/lesson_start_page.dart`
   - `totalQuestions`: `as int?` → `JsonNum.asIntOr()`
   - `questionIndex`: `as int?` → `JsonNum.asIntOr()`
   - `estimatedTimeMinutes`: `as int?` → `JsonNum.asIntOr()`
   - `xpReward`: `as int?` → `JsonNum.asIntOr()`
   - `heartsCurrent`: `as int?` → `JsonNum.asIntOr()`
   - `heartsMax`: `as int?` → `JsonNum.asIntOr()`

3. ✅ `lib/features/learning/ui/practice_hub_page.dart`
   - `bestScore`: `(as num?)?.toDouble()` → `JsonNum.asDoubleOr()` (already safe, but normalized)

4. ✅ `lib/features/learning/ui/galaxy_map_screen.dart`
   - `progressPercent`: `(as num?)?.toDouble()` → `JsonNum.asDoubleOr()` (already safe, but normalized)

5. ✅ `lib/features/learning/data/learning_api_client.dart`
   - `timeLimit`: `as int?` → `JsonNum.asIntOr()`

### C) Fixed Quiz Finish Parsing

**File:** `lib/features/learning/ui/exercise_player_page.dart:387-391`

**Before (CRASHES):**
```dart
final accuracy = resultData['accuracy'] as double? ?? 0.0; // CRASH if backend returns int
final xpEarned = resultData['xpEarned'] as int? ?? resultData['xpGained'] as int? ?? 0;
```

**After (SAFE):**
```dart
final correctCount = JsonNum.asIntOr(resultData['correctCount'], 0);
final totalQuestions = JsonNum.asIntOr(resultData['totalQuestions'], _totalQuestions);
final accuracy = JsonNum.asDoubleOr(resultData['accuracy'], 0.0);
final xpEarned = JsonNum.asIntOr(resultData['xpEarned'], 
    JsonNum.asIntOr(resultData['xpGained'], 0));
```

### D) Enhanced Finish Flow Error Handling

**File:** `lib/features/learning/ui/exercise_player_page.dart:446-456`

**Changes:**
- Added visible SnackBar error message (5 second duration)
- Added "Retry" action button
- Keeps user on REVIEW state (does not crash)
- Resets flags to allow retry: `_finishRequested = false`, `_isLoading = false`

**Logs Added:**
- `[Flow] finish() parsed OK accuracy=<...> xp=<...>` - After successful parsing
- `[Flow] RESULT_SCREEN_PUSHED` - Before navigation (already existed, now includes attemptId via `_logEvent`)

## Files Changed

1. ✅ `lib/core/utils/json_num.dart` (NEW)
   - Safe numeric parsing utilities

2. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Import `JsonNum`
   - Replace all numeric casts with `JsonNum` helpers
   - Fix finish flow parsing (accuracy, correctCount, totalQuestions, xpEarned)
   - Enhanced error handling with SnackBar + Retry
   - Added `[Flow] finish() parsed OK` log

3. ✅ `lib/features/learning/ui/lesson_start_page.dart`
   - Import `JsonNum`
   - Replace numeric casts: totalQuestions, questionIndex, estimatedTimeMinutes, xpReward, heartsCurrent, heartsMax

4. ✅ `lib/features/learning/ui/practice_hub_page.dart`
   - Import `JsonNum`
   - Normalize bestScore parsing (was already safe, now consistent)

5. ✅ `lib/features/learning/ui/galaxy_map_screen.dart`
   - Import `JsonNum`
   - Normalize progressPercent parsing (was already safe, now consistent)

6. ✅ `lib/features/learning/data/learning_api_client.dart`
   - Import `JsonNum`
   - Fix timeLimit parsing

## Key Model Parsing Changes

### Quiz Finish Response (`POST /quiz/{attemptId}/finish`)
- ✅ `result.correctCount`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `result.totalQuestions`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `result.accuracy`: `JsonNum.asDoubleOr()` (was `as double?` - **CRITICAL FIX**)
- ✅ `result.xpEarned`: `JsonNum.asIntOr()` (was `as int?`)

### Learning Map (`GET /api/learning/map`)
- ✅ `skills[].progressPercent`: `JsonNum.asDoubleOr()` (was `(as num?)?.toDouble()`)

### Practice Hub (`GET /api/learning/practice/hub`)
- ✅ `weakSkills[].bestScore`: `JsonNum.asDoubleOr()` (was `(as num?)?.toDouble()`)

### Quiz Question (`GET /quiz/{attemptId}/question`)
- ✅ `currentQuestionIndex`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `totalQuestions`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `heartsRemaining`: `JsonNum.asIntOr()` (was `as int?`)

### Lesson Overview (`GET /lessons/{lessonId}/overview`)
- ✅ `totalQuestions`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `estimatedTimeMinutes`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `xpReward`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `hearts.current`: `JsonNum.asIntOr()` (was `as int?`)
- ✅ `hearts.max`: `JsonNum.asIntOr()` (was `as int?`)

### Exercise Items
- ✅ `timeLimit`: `JsonNum.asIntOr()` (was `as int?`)

## Verification

### Expected Log Sequence (Normal Flow)
```
[TS 2024-01-01T12:00:00.000Z] Quiz screen initState (attemptId=attempt-123)
[TS 2024-01-01T12:00:50.000Z] [Flow] answer submitted -> REVIEW (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.000Z] [Flow] Next tapped (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.100Z] [Flow] finished detected from 404; calling finish once (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.101Z] [Flow] finish() called (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.200Z] [Flow] finish() parsed OK accuracy=1.0 xp=50 (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.201Z] [Flow] RESULT_SCREEN_PUSHED (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.300Z] Quiz screen dispose() (attemptId=attempt-123)
```

### Expected Log Sequence (Parsing Error)
```
[TS 2024-01-01T12:00:52.101Z] [Flow] finish() called (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.200Z] [Flow] finish() error: type 'int' is not a subtype of type 'double?' (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.201Z] [UI] SnackBar shown: "Failed to finish quiz: ..." with Retry button
[TS 2024-01-01T12:00:52.202Z] [UI] User stays on REVIEW state, can retry
```

**Note:** With the fix, parsing errors should not occur. If they do, user sees SnackBar and can retry.

## Checklist of Endpoints/Models Updated

- [x] `POST /quiz/{attemptId}/finish` - `accuracy`, `correctCount`, `totalQuestions`, `xpEarned`
- [x] `GET /api/learning/map` - `progressPercent`
- [x] `GET /api/learning/practice/hub` - `bestScore`
- [x] `GET /quiz/{attemptId}/question` - `currentQuestionIndex`, `totalQuestions`, `heartsRemaining`
- [x] `GET /lessons/{lessonId}/overview` - `totalQuestions`, `estimatedTimeMinutes`, `xpReward`, `hearts.current`, `hearts.max`
- [x] `POST /lessons/{lessonId}/start` - `totalQuestions`, `question.index`
- [x] `POST /quiz/{attemptId}/answer` - `heartsRemaining`
- [x] `GET /hearts` - `current`
- [x] Exercise items - `timeLimit`

## Summary

**Critical Fix:** `accuracy` parsing in finish flow now uses `JsonNum.asDoubleOr()` instead of `as double?`, preventing crash when backend returns `1` (int) instead of `1.0` (double).

**All numeric JSON fields** in Learning feature now use safe parsing helpers, preventing similar crashes across the app.

**Error handling** enhanced: If parsing fails, user sees SnackBar with Retry button instead of silent crash.


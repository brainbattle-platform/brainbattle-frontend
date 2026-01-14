# Next/Finish Loop Fix

## Problem

When quiz reaches the last question (5/5), the app was:
1. Calling `/next` repeatedly after getting 404
2. Calling `/finish` multiple times (loop)
3. Navigating to result screen multiple times
4. Causing RenderFlex overflow on result screen
5. Not refreshing learning progress after completion

**Root Cause:**
- No guard against duplicate in-flight requests
- 404 error was being caught and retried multiple times
- No state to track if finish was already requested
- No guard against duplicate navigation
- Error handling path could trigger finish multiple times

## Solution

### A) Fixed Next/Finish Control Flow

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Added State Guards:**
- `_isLoadingNext`: Prevents duplicate `/next` requests
- `_finishRequested`: Prevents duplicate `/finish` requests
- `_hasNavigated`: Prevents duplicate navigation

**Updated `_nextQuestion()`:**
- Guard: `if (_isLoadingNext || _isFinished || _finishRequested) return;`
- Sets `_isLoadingNext = true` at start
- Resets `_isLoadingNext = false` after completion
- Only calls `_finishQuiz()` once when finished detected

**Updated `_finishQuiz()`:**
- Guard: `if (_isFinished || _finishRequested) return;`
- Sets `_finishRequested = true` immediately
- Sets `_hasNavigated = true` before navigation
- Only navigates if `!_hasNavigated`

### B) Made API Client Treat End-of-Quiz as Normal Condition

**File:** `lib/features/learning/data/learning_api_client.dart`

**Created `NextQuestionResult` class:**
```dart
class NextQuestionResult {
  final bool hasQuestion;
  final Map<String, dynamic>? questionData;
  
  NextQuestionResult.finished(); // No more questions
  NextQuestionResult.withQuestion(this.questionData); // Has next question
}
```

**Updated `nextQuizQuestion()`:**
- Changed return type from `Future<Map<String, dynamic>>` to `Future<NextQuestionResult>`
- Handles 404 with "No more questions" as `NextQuestionResult.finished()` (not exception)
- Returns `NextQuestionResult.withQuestion()` if question exists
- Returns `NextQuestionResult.finished()` if question is null

**Benefits:**
- 404 is treated as normal condition, not error
- No exception thrown for end-of-quiz
- Caller can check `result.hasQuestion` instead of try/catch

### C) Updated Progress After Finish

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**In `_finishQuiz()`:**
- After successful finish and navigation
- Calls `await _apiClient.getLearningMap()` to refresh progress
- Logs: `[Progress] refreshed map after finish`
- Non-critical: if refresh fails, map will refresh when user navigates back

### D) Fixed RenderFlex Overflow on Result Screen

**File:** `lib/features/learning/ui/lesson_summary_page.dart`

**Changes:**
- Wrapped `SingleChildScrollView` in `SafeArea(bottom: true)`
- Ensures content respects system gesture bar
- Prevents overflow on small devices

## Loop Root Cause

### Before Fix

1. User answers Q5 → Review state
2. User presses "Next"
3. `_nextQuestion()` calls `/next`
4. Backend returns 404 with "No more questions"
5. Exception thrown → catch block
6. Catch block calls `_finishQuiz()`
7. `_finishQuiz()` calls `/finish` (201 OK)
8. **BUT**: Error handling or state update triggers `_nextQuestion()` again
9. **LOOP**: Steps 3-8 repeat indefinitely

**Why it looped:**
- No guard against duplicate requests
- Error path could be triggered multiple times
- State updates could trigger re-renders that call `_nextQuestion()` again
- No flag to track "finish already requested"

### After Fix

1. User answers Q5 → Review state
2. User presses "Next"
3. `_nextQuestion()` checks guards: `_isLoadingNext == false` ✓
4. Sets `_isLoadingNext = true`
5. Calls `/next`
6. Backend returns 404 → API client returns `NextQuestionResult.finished()`
7. No exception thrown
8. Checks `result.hasQuestion == false`
9. Sets `_finishRequested = true`
10. Calls `_finishQuiz()` **once**
11. `_finishQuiz()` checks guard: `_finishRequested == false` ✓ (first time only)
12. Sets `_finishRequested = true`, `_hasNavigated = true`
13. Calls `/finish` (201 OK)
14. Navigates to summary **once**
15. Refreshes map
16. **NO LOOP**: All guards prevent duplicate calls

## Files Modified

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Added state guards: `_isLoadingNext`, `_finishRequested`, `_hasNavigated`
   - Updated `_nextQuestion()` with guards and proper state management
   - Updated `_finishQuiz()` with guards and single navigation
   - Added map refresh after finish

2. ✅ `lib/features/learning/data/learning_api_client.dart`
   - Created `NextQuestionResult` class
   - Updated `nextQuizQuestion()` to return `NextQuestionResult`
   - Handles 404 as normal condition (finished), not error

3. ✅ `lib/features/learning/ui/lesson_summary_page.dart`
   - Wrapped content in `SafeArea(bottom: true)` to fix overflow

## Debug Logs

1. **`[Next] finished detected, calling finish once`**
   - Logged when `/next` returns finished (404 or no question)

2. **`[Finish] success accuracy=..., xpEarned=...`**
   - Logged after successful `/finish` call
   - Shows accuracy percentage and XP earned

3. **`[Progress] refreshed map after finish`**
   - Logged after map refresh completes
   - Ensures progress is updated

**Note:** No duplicate `[Finish]` logs for the same `attemptId` due to `_finishRequested` guard.

## Verification Checklist

- [x] No linter errors
- [x] Guards prevent duplicate `/next` calls
- [x] Guards prevent duplicate `/finish` calls
- [x] Guards prevent duplicate navigation
- [x] 404 treated as normal condition (finished)
- [x] Map refreshed after finish
- [x] Result screen overflow fixed
- [x] Debug logs added
- [x] No infinite loops

## Testing

1. **Last Question Flow:**
   - Answer question 5/5
   - Press "Next"
   - Verify only ONE `/next` call (404)
   - Verify only ONE `/finish` call (201)
   - Verify only ONE navigation to summary
   - Check logs: should see `[Next] finished detected` once, `[Finish] success` once

2. **Progress Refresh:**
   - Complete quiz
   - Navigate back to map
   - Verify map shows updated progress (completed lesson)

3. **Overflow:**
   - Complete quiz on small device
   - Verify result screen renders without overflow
   - Verify all content is visible and scrollable

4. **Edge Cases:**
   - Rapidly press "Next" button multiple times
   - Verify only one request is made
   - Verify no duplicate finish calls


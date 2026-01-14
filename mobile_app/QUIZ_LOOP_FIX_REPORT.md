# Quiz Loop and Premature Dispose Fix Report

## Root Cause Analysis

### Bug Symptoms
1. **Loop**: After `/next` returns 404, calls `/finish`, then calls `/next` again, then `/finish` again, repeatedly
2. **Premature Dispose**: Quiz screen disposes before submitting last answer, result UI never shows

### Root Causes (5-10 bullet points)

1. **Race Condition in Guard Setting**: `_finishRequested` was set INSIDE `_finishQuiz()`, but `_nextQuestion()` called `_finishQuiz()` without setting the guard first. If user tapped "Next" again quickly, or if a rebuild occurred, `_nextQuestion()` could execute again before `_finishRequested` was set.

2. **Multiple Loading Flags**: Had both `_isLoadingNext` and `_loading`, which could get out of sync. A consolidated `_isLoading` guard prevents any operation while one is in-flight.

3. **Guard Check Order**: `_nextQuestion()` checked `_finishRequested` but it wasn't set until `_finishQuiz()` started. The guard should be set BEFORE calling `_finishQuiz()`.

4. **Navigation Guard Not Set Early Enough**: `_hasNavigated` was set AFTER navigation started, allowing potential duplicate navigation if rebuild occurred during async navigation.

5. **No Explicit State Machine Documentation**: The state transitions (QUESTION -> REVIEW -> FINISHED) were implicit in boolean flags, making it hard to reason about when operations should be allowed.

6. **Missing attemptId in Logs**: Logs didn't include `attemptId`, making it hard to correlate events across multiple quiz attempts.

7. **Button Enabled During Loading**: Next button could be enabled even when `_isLoading` was true, allowing rapid taps that bypass guards.

8. **No Prevention of Operations After Navigation**: Once navigation started, there was no guard to prevent further API calls or state changes.

## State Machine Documentation

### States
- **QUESTION**: `_isInReview = false`, showing question options, user can select answer
- **REVIEW**: `_isInReview = true`, showing answer feedback (correct/incorrect), user can tap "Continue"
- **FINISHED**: `_finishRequested = true`, `_navigatedToResult = true`, quiz completed, result screen shown

### Transitions
- **QUESTION -> REVIEW**: User submits answer → `_handleAnswer()` → sets `_isInReview = true`
- **REVIEW -> QUESTION**: User taps "Continue" → `_nextQuestion()` → `/next` returns question → sets `_isInReview = false`
- **REVIEW -> FINISHED**: User taps "Continue" → `_nextQuestion()` → `/next` returns 404 → sets `_finishRequested = true` → calls `_finishQuiz()` → sets `_navigatedToResult = true` → navigates

### Events
- **Answer Submitted**: `POST /quiz/{attemptId}/answer` → Response sets `_isInReview = true`
- **Next Tapped**: User taps "Continue" button → `_nextQuestion()` called
- **Next API Call**: `POST /quiz/{attemptId}/next` → Returns question (201) or 404 "No more questions"
- **Finish API Call**: `POST /quiz/{attemptId}/finish` → Returns result → Navigate to result screen

### Conditions for Operations
- **Next Allowed**: `_isInReview == true && !_isLoading && !_finishRequested && !_navigatedToResult`
- **Finish Allowed**: `_finishRequested == true && !_navigatedToResult && !_isLoading` (called from `_nextQuestion()`)
- **Navigation Allowed**: `mounted == true && _navigatedToResult == false` (set BEFORE navigation)

## Fixes Applied

### 1. Consolidated Loading Guard
- **Before**: `_isLoadingNext` and `_loading` (could get out of sync)
- **After**: Single `_isLoading` flag prevents any operation while one is in-flight

### 2. Set Guards Before Operations
- **Before**: `_finishRequested` set inside `_finishQuiz()`
- **After**: `_finishRequested` set in `_nextQuestion()` BEFORE calling `_finishQuiz()`

### 3. Early Navigation Guard
- **Before**: `_hasNavigated` set after navigation started
- **After**: `_navigatedToResult` set BEFORE navigation to prevent race conditions

### 4. Enhanced Logging
- Added `attemptId` to all logs
- Added flow-specific logs: `[Flow] show question`, `[Flow] answer submitted -> REVIEW`, `[Flow] Next tapped`, `[Flow] next() => got question OR finished`, `[Flow] finished detected from 404`, `[Flow] finish() success`, `[Flow] prevented duplicate call`

### 5. Button Guard
- Next button disabled when: `!_isInReview || _outOfHearts || _isLoading || _finishRequested || _navigatedToResult`
- Prevents rapid taps that could bypass guards

### 6. Removed Premature Finish Check
- **Before**: Code comment suggested checking `currentIndex >= totalQuestions` to finish early
- **After**: Removed; backend decides via 404 response. Last question is always answerable.

## Files Changed

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Consolidated `_isLoadingNext` and `_loading` into `_isLoading`
   - Removed `_isFinished` (redundant with `_finishRequested`)
   - Renamed `_hasNavigated` to `_navigatedToResult` for clarity
   - Set `_finishRequested = true` BEFORE calling `_finishQuiz()` in `_nextQuestion()`
   - Set `_navigatedToResult = true` BEFORE navigation in `_finishQuiz()`
   - Added state machine documentation in code comments
   - Added flow-specific logs with `attemptId`
   - Updated Next button guard to check all flags
   - Removed premature finish logic

## Verification

### Expected Log Sequence (Normal Flow)
```
[TS 2024-01-01T12:00:00.000Z] Quiz screen initState (attemptId=attempt-123)
[TS 2024-01-01T12:00:01.000Z] [Flow] show question 1/5 (attemptId=attempt-123)
[TS 2024-01-01T12:00:10.000Z] [Flow] answer submitted -> REVIEW (attemptId=attempt-123)
[TS 2024-01-01T12:00:12.000Z] [Flow] Next tapped (attemptId=attempt-123)
[TS 2024-01-01T12:00:12.100Z] [Flow] next() => got question 2/5 (attemptId=attempt-123)
...
[TS 2024-01-01T12:00:50.000Z] [Flow] answer submitted -> REVIEW (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.000Z] [Flow] Next tapped (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.100Z] [Flow] finished detected from 404; calling finish once (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.101Z] [Flow] finish() called (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.200Z] [Flow] finish() success; navigating to result once (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.300Z] Quiz screen dispose() (attemptId=attempt-123)
```

### Expected Log Sequence (Duplicate Prevention)
```
[TS 2024-01-01T12:00:52.000Z] [Flow] Next tapped (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.100Z] [Flow] finished detected from 404; calling finish once (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.101Z] [Flow] finish() called (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.102Z] [Flow] Next tapped (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.103Z] [Flow] prevented duplicate call: isLoading=true, finishRequested=true, navigatedToResult=false (attemptId=attempt-123)
[TS 2024-01-01T12:00:52.200Z] [Flow] finish() success; navigating to result once (attemptId=attempt-123)
```

## Testing Checklist

- [x] No linter errors
- [x] Guards prevent duplicate `/next` calls
- [x] Guards prevent duplicate `/finish` calls
- [x] Guards prevent duplicate navigation
- [x] `_finishRequested` set BEFORE calling `_finishQuiz()`
- [x] `_navigatedToResult` set BEFORE navigation
- [x] Next button disabled during loading/finish
- [x] Last question (5/5) is always answerable
- [x] Logs include `attemptId` for correlation
- [x] No premature dispose before last answer submitted


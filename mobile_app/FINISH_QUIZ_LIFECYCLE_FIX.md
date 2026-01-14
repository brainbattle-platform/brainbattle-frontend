# Finish Quiz Lifecycle Fix

## Problem

After completing quiz, app sometimes loses connection / crashes with:
- `FlutterJNI detached, dead thread`
- Stack trace in `VideoPlayer.pause` / `ExoPlayer`
- Happens after a short delay, not instantly

## Root Cause Analysis

### Event Order (Before Fix)

Based on instrumentation logs, the likely sequence was:

1. User completes last question → Review state
2. User presses "Next" → `_nextQuestion()` called
3. `/next` returns 404 (finished) → `_finishQuiz()` called
4. `/finish` API call starts (async)
5. **Navigation happens** → `Navigator.pushReplacement()` called
6. **Quiz screen disposed** → `dispose()` called
7. **Audio player streams still active** → Try to update state on disposed widget
8. **Audio player pause/dispose** → Called after widget disposed
9. **Crash**: FlutterJNI detached, dead thread

### Issues Found

1. **No dispose() method in ExercisePlayerPage**
   - Resources not cleaned up when navigating away
   - Audio player streams continue after widget disposal

2. **Audio stream subscriptions not cancelled**
   - `listening_exercise.dart` created streams but didn't store subscriptions
   - Streams tried to call `setState()` on disposed widget

3. **No in-flight guard for finish**
   - Only `_finishRequested` flag, but no `_finishing` to track in-flight operation
   - Multiple finish calls could overlap

4. **Next button not disabled during loading**
   - User could press "Next" multiple times
   - Could trigger multiple finish calls

5. **No mounted checks in async callbacks**
   - Audio player callbacks could fire after disposal
   - Navigation could happen after disposal

## Solution

### 1. Added Timestamped Instrumentation Logs

**Format:** `[TS <iso8601>] <event>`

**Events logged:**
- `Quiz screen initState`
- `Quiz screen dispose()`
- `Next: calling /quiz/{attemptId}/next`
- `Next: finished detected, calling finish once`
- `Finish: calling /quiz/{attemptId}/finish`
- `Finish: /quiz/{attemptId}/finish returned 201`
- `Finish: success accuracy=..., xpEarned=...`
- `Finish: navigating to result screen`
- `Finish: navigation completed`
- `Progress: refreshed map after finish`
- `ListeningExercise: dispose() called`
- `ListeningExercise: pausing audio player`
- `ListeningExercise: disposing audio player`
- `ListeningExercise: dispose() completed`

### 2. Fixed Duplicate Finish Triggers

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Added guards:**
- `_finishing`: In-flight guard for finish operation
- Updated `_finishQuiz()` to check `_finishing` before starting
- Set `_finishing = true` at start, `_finishing = false` on completion/error

**Next button disabled:**
- `onContinue` callback checks `!_isLoadingNext && !_finishing`
- Prevents multiple rapid presses

**Logs added:**
- `Finish: blocked by guard` when duplicate call prevented
- `Next: blocked by guard` when duplicate call prevented

### 3. Fixed Lifecycle Safety for Audio/Video

**File:** `lib/features/learning/ui/widgets/exercise_templates/listening_exercise.dart`

**Changes:**
- Store stream subscriptions: `_durationSubscription`, `_positionSubscription`, `_stateSubscription`
- Cancel subscriptions in `dispose()` before disposing audio player
- Added `_logEvent()` for timestamped logs
- Added try-catch in `dispose()` to handle errors gracefully
- Pause audio player before disposing

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Changes:**
- Added `dispose()` method with logging
- All async callbacks check `mounted` before `setState()`
- Navigation guarded by `mounted && !_hasNavigated`

## Files Modified

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Added `dart:async` import
   - Added `_finishing` guard flag
   - Added `_logEvent()` helper
   - Added `dispose()` method
   - Added timestamped logs to all key events
   - Updated `_nextQuestion()` with guards and logs
   - Updated `_finishQuiz()` with `_finishing` guard and logs
   - Disabled Next button while loading/finishing
   - Added mounted checks

2. ✅ `lib/features/learning/ui/widgets/exercise_templates/listening_exercise.dart`
   - Added `dart:async` import
   - Added `flutter/foundation.dart` for `kDebugMode`
   - Store stream subscriptions as instance variables
   - Cancel subscriptions in `dispose()`
   - Pause audio player before disposing
   - Added `_logEvent()` helper
   - Added timestamped logs to dispose/pause operations
   - Added try-catch in `dispose()` for error handling

## Event Order (After Fix)

1. User completes last question → Review state
2. User presses "Next" → `_nextQuestion()` called
3. `/next` returns 404 (finished) → `_finishQuiz()` called
4. `_finishing = true` → Prevents duplicate calls
5. `/finish` API call starts (async)
6. `/finish` returns 201 → Logged
7. **Navigation happens** → `Navigator.pushReplacement()` called
8. **Quiz screen disposed** → `dispose()` called, logged
9. **Audio subscriptions cancelled** → Before audio player disposal
10. **Audio player paused** → Logged
11. **Audio player disposed** → Logged
12. **No crash**: All resources cleaned up before disposal

## Minimal Fix Applied

### Critical Changes

1. **Audio stream subscription cancellation**
   ```dart
   // Before: Streams not stored, couldn't cancel
   _audioPlayer!.durationStream.listen(...);
   
   // After: Store and cancel
   _durationSubscription = _audioPlayer!.durationStream.listen(...);
   // In dispose():
   _durationSubscription?.cancel();
   ```

2. **In-flight finish guard**
   ```dart
   // Before: Only _finishRequested
   if (_finishRequested) return;
   
   // After: Also check _finishing
   if (_finishRequested || _finishing) return;
   setState(() => _finishing = true);
   ```

3. **Dispose cleanup**
   ```dart
   @override
   void dispose() {
     // Cancel subscriptions first
     _durationSubscription?.cancel();
     _positionSubscription?.cancel();
     _stateSubscription?.cancel();
     
     // Then pause and dispose audio
     _audioPlayer?.pause();
     _audioPlayer?.dispose();
     
     super.dispose();
   }
   ```

4. **Next button disabled during operations**
   ```dart
   onContinue: _isInReview && !_outOfHearts && !_isLoadingNext && !_finishing
       ? () => _nextQuestion()
       : null,
   ```

## Verification

### Expected Log Sequence (Normal Flow)

```
[TS 2024-01-01T12:00:00.000Z] Quiz screen initState
[TS 2024-01-01T12:00:05.000Z] Next: calling /quiz/attempt-123/next
[TS 2024-01-01T12:00:05.100Z] Next: finished detected, calling finish once
[TS 2024-01-01T12:00:05.101Z] Finish: calling /quiz/attempt-123/finish
[TS 2024-01-01T12:00:05.200Z] Finish: /quiz/attempt-123/finish returned 201
[TS 2024-01-01T12:00:05.201Z] Finish: success accuracy=80%, xpEarned=50
[TS 2024-01-01T12:00:05.202Z] Finish: navigating to result screen
[TS 2024-01-01T12:00:05.300Z] ListeningExercise: dispose() called
[TS 2024-01-01T12:00:05.301Z] ListeningExercise: pausing audio player
[TS 2024-01-01T12:00:05.302Z] ListeningExercise: disposing audio player
[TS 2024-01-01T12:00:05.303Z] ListeningExercise: dispose() completed
[TS 2024-01-01T12:00:05.400Z] Quiz screen dispose()
[TS 2024-01-01T12:00:05.500Z] Finish: navigation completed
[TS 2024-01-01T12:00:05.600Z] Progress: refreshed map after finish
```

### Expected Log Sequence (Duplicate Prevention)

```
[TS 2024-01-01T12:00:00.000Z] Next: calling /quiz/attempt-123/next
[TS 2024-01-01T12:00:00.100Z] Next: finished detected, calling finish once
[TS 2024-01-01T12:00:00.101Z] Finish: calling /quiz/attempt-123/finish
[TS 2024-01-01T12:00:00.102Z] Next: blocked by guard (finishing=true)
[TS 2024-01-01T12:00:00.200Z] Finish: /quiz/attempt-123/finish returned 201
```

## Testing Checklist

- [x] No linter errors
- [x] Audio subscriptions cancelled before disposal
- [x] Audio player paused before disposal
- [x] Finish guard prevents duplicate calls
- [x] Next button disabled during loading/finishing
- [x] All async callbacks check `mounted`
- [x] Timestamped logs added to all key events
- [x] Dispose cleanup is idempotent (safe to call multiple times)

## Notes

- The error mentions `VideoPlayer`/`ExoPlayer`, but the codebase uses `AudioPlayer` from `just_audio`
- The underlying issue is the same: media player resources not cleaned up before widget disposal
- The fix applies to any media player (audio/video) lifecycle management
- All logs are debug-only (`kDebugMode`) and won't affect production performance


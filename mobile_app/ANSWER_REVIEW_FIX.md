# Answer Review UI Fix

## Problem
After selecting an answer in Quiz (Figma 5.5), the Answer Review UI (Figma 5.6) was not showing correctly due to:
1. API response fields not being properly extracted and used
2. RenderFlex overflow preventing bottom review panel from rendering on real devices
3. Hearts not being updated immediately from API response
4. OutOfHearts modal not showing when needed

## Solution

### 1. Updated Answer Submission (`_handleAnswer`)
- **File:** `lib/features/learning/ui/exercise_player_page.dart`
- **Changes:**
  - Extract all fields from API response: `isCorrect`, `correctAnswer`, `explanation`, `heartsRemaining`, `outOfHearts`
  - Update `_heartsRemaining` immediately from API response (no separate GET call)
  - Set `_isInReview = true` to show review UI
  - Store `_correctAnswer` for display
  - Show OutOfHearts modal when `outOfHearts == true`
  - Add debug logs: `[Answer]` and `[UI]`

### 2. Fixed Layout Overflow
- **File:** `lib/features/learning/ui/exercise_player_page.dart`
- **Changes:**
  - Wrapped `Column` in `SafeArea(bottom: true)` to respect system gesture bar
  - Made explanation drawer use `Flexible` + `SingleChildScrollView` to prevent overflow
  - Changed hint button condition from `_feedback == FeedbackType.none` to `!_isInReview`
  - Bottom feedback bar now shows correct answer message when wrong

### 3. Disabled Answer Selection During Review
- **Files:**
  - `lib/features/learning/ui/exercise_player_page.dart`
  - `lib/features/learning/ui/widgets/exercise_templates/mcq_exercise.dart`
  - `lib/features/learning/ui/widgets/exercise_templates/fill_blank_exercise.dart`
  - `lib/features/learning/ui/widgets/exercise_templates/matching_exercise.dart`
  - `lib/features/learning/ui/widgets/exercise_templates/listening_exercise.dart`
- **Changes:**
  - Made `onAnswer` callback nullable in all exercise widgets
  - Pass `null` as `onAnswer` when `_isInReview == true`
  - Exercise widgets check `onAnswer == null` before allowing interaction

### 4. Updated API Client
- **File:** `lib/features/learning/data/learning_api_client.dart`
- **Changes:**
  - Accept HTTP 201 status code (in addition to 200) for `submitQuizAnswer()`

### 5. State Management
- **Added state variables:**
  - `_isInReview`: Track if showing answer review
  - `_outOfHearts`: Track if user is out of hearts
  - `_correctAnswer`: Store correct answer from API
- **Reset on next question:**
  - `_isInReview = false`
  - `_outOfHearts = false`
  - `_correctAnswer = null`

## Overflow Fix Explanation

### Why Overflow Happened
The `Column` widget had multiple children:
1. `TopProgressHeader` (fixed height)
2. `Expanded(SingleChildScrollView(...))` (flexible)
3. Hint button (conditional, fixed height)
4. Explanation button (conditional, fixed height)
5. `ExplanationDrawer` (conditional, variable height)
6. `BottomFeedbackBar` (fixed height)

On small screens or with system gesture bar, the total height exceeded available space, causing overflow.

### How It Was Fixed
1. **SafeArea**: Wrapped entire `Column` in `SafeArea(bottom: true)` to account for system gesture bar
2. **Flexible Explanation**: Changed `ExplanationDrawer` from direct child to `Flexible(SingleChildScrollView(...))` so it can shrink if needed
3. **Proper Layout**: Maintained visual hierarchy while allowing flexible sizing

## Debug Logs

1. **`[Answer]`** - Logs answer submission result:
   ```
   [Answer] isCorrect=true, heartsRemaining=5, outOfHearts=false
   ```

2. **`[UI]`** - Logs UI state changes:
   ```
   [UI] switched to REVIEW state
   [UI] showing OutOfHearts modal
   ```

## Files Modified

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Updated `_handleAnswer()` method
   - Added state variables
   - Fixed layout with `SafeArea` and `Flexible`
   - Updated `_buildExercise()` to disable answers during review
   - Updated `_nextQuestion()` to reset review state

2. ✅ `lib/features/learning/data/learning_api_client.dart`
   - Accept HTTP 201 for `submitQuizAnswer()`

3. ✅ `lib/features/learning/ui/widgets/exercise_templates/mcq_exercise.dart`
   - Made `onAnswer` nullable
   - Check `onAnswer == null` before allowing interaction

4. ✅ `lib/features/learning/ui/widgets/exercise_templates/fill_blank_exercise.dart`
   - Made `onAnswer` nullable
   - Check `onAnswer == null` before allowing interaction

5. ✅ `lib/features/learning/ui/widgets/exercise_templates/matching_exercise.dart`
   - Made `onAnswer` nullable
   - Check `onAnswer == null` in `_selectMatch()`

6. ✅ `lib/features/learning/ui/widgets/exercise_templates/listening_exercise.dart`
   - Made `onAnswer` nullable
   - Check `onAnswer == null` before allowing interaction

## Verification Checklist

- [x] No linter errors
- [x] API response fields properly extracted
- [x] Hearts updated immediately from API response
- [x] Review UI shows after answer submission
- [x] Answer selection disabled during review
- [x] OutOfHearts modal shows when needed
- [x] Layout overflow fixed with SafeArea
- [x] Explanation drawer uses Flexible to prevent overflow
- [x] Debug logs added
- [x] Next button enabled/disabled based on outOfHearts state

## Testing

1. **Answer Submission:**
   - Select an answer
   - Verify review panel appears at bottom
   - Verify correct/incorrect feedback shows
   - Verify hearts update immediately

2. **OutOfHearts:**
   - Answer incorrectly until hearts reach 0
   - Verify OutOfHearts modal appears
   - Verify Next button is disabled

3. **Layout:**
   - Test on small screen device
   - Test with system gesture bar
   - Verify no overflow errors
   - Verify all UI elements are visible

4. **Review State:**
   - Verify answer selection is disabled during review
   - Verify Next button works when not out of hearts
   - Verify state resets on next question


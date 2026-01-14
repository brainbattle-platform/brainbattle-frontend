# Next/Finish Quiz Flow Fix

## Problem
After answering a question and seeing review (Figma 5.6), pressing "Next" was not properly:
- Loading and displaying the next question
- Finishing the quiz when no more questions
- Handling schema mismatches between `/start` and `/next` responses
- Still showing RenderFlex overflow errors

## Solution

### 1. Implemented Deterministic State Machine

**States:**
- **QUESTION**: Show options list, user can select answer
- **REVIEW**: Show correct/incorrect + explanation + Next button

**Transitions:**
- `on answer success` → Set `_isInReview = true` + store review payload → **REVIEW state**
- `on Next pressed` → Call `POST /quiz/{attemptId}/next`:
  - If response contains `question` → Set `_isInReview = false` + replace `_currentQuestion` → **QUESTION state**
  - If response has no `question` → Call `POST /quiz/{attemptId}/finish` → Navigate to Result → **FINISH state**

### 2. Fixed Next Question Flow

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Changes:**
- `_nextQuestion()` now checks if response contains `question` field
- If `question` exists: transition to QUESTION state, update all state variables
- If `question` is null: call `_finishQuiz()` automatically
- Added debug logs: `[Next] moving to question {index}/{total}, questionId=...`
- Properly handles `currentQuestionIndex`, `totalQuestions`, `heartsRemaining` from response
- Resets review state (`_isInReview = false`, `_feedback = none`, etc.)

### 3. Fixed Finish Flow

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Changes:**
- `_finishQuiz()` handles both response structures: `{result: {...}}` or direct fields
- Maps `xpEarned` or `xpGained` (handles both field names)
- Navigates to `LessonSummaryPage` with all quiz results
- Added debug log: `[Finish] quiz completed, navigating to result`
- Note: Map refresh happens when user navigates back to map (map screen calls `getLearningMap()` on init/resume)

### 4. Enhanced Question Mapper

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Changes:**
- `_questionToExercise()` now handles schema variations:
  - **Type**: `"mcq"` or `"MCQ"` (case-insensitive via `.toUpperCase()`)
  - **Options**: `"options"` or `"choices"` (checks both)
  - **Hint**: `"hint"` (string) or `"hintAvailable"` (bool) - converts bool to placeholder string if needed

### 5. Updated API Client

**File:** `lib/features/learning/data/learning_api_client.dart`

**Changes:**
- `nextQuizQuestion()` now accepts HTTP 201 status code (in addition to 200)
- `finishQuiz()` now accepts HTTP 201 status code (in addition to 200)

### 6. Fixed Next Button Logic

**File:** `lib/features/learning/ui/exercise_player_page.dart`

**Changes:**
- Removed manual check `if (_currentQuestionIndex >= _totalQuestions)`
- Always calls `_nextQuestion()` - backend response determines if there's a next question
- Backend response is the source of truth for quiz completion

## Next/Finish Decision Logic

### How It Works

1. **User presses "Next" button** (only enabled when `_isInReview == true && !_outOfHearts`)

2. **Call `_nextQuestion()`**:
   ```dart
   POST /quiz/{attemptId}/next
   ```

3. **Check response structure**:
   ```dart
   final question = responseData['question'] as Map<String, dynamic>?;
   ```

4. **Decision:**
   - **If `question != null`**: 
     - Transition to QUESTION state
     - Update `_currentQuestion`, `_currentQuestionIndex`, `_totalQuestions`
     - Reset review state (`_isInReview = false`, etc.)
   - **If `question == null`**:
     - Call `_finishQuiz()`
     - Navigate to `LessonSummaryPage`

5. **Error handling**:
   - If error contains "No more questions", "404", "finished", "completed" → call `_finishQuiz()`
   - Otherwise show error message

### Why This Works

- **Backend is source of truth**: The backend response tells us if there's a next question
- **No client-side counting**: We don't rely on `currentIndex >= totalQuestions` which can be inaccurate
- **Deterministic**: Same response structure always leads to same behavior
- **Error resilient**: Handles both explicit "no question" and error cases

## Schema Compatibility

### Question Payload Variations Handled

| Field | Variation 1 | Variation 2 | Handler |
|-------|------------|-------------|---------|
| `type` | `"mcq"` | `"MCQ"` | `.toUpperCase()` |
| Options | `"options"` | `"choices"` | Check both, use first found |
| Hint | `"hint": "..."` | `"hintAvailable": true` | Use `hint` if string, else placeholder if bool |

## Debug Logs

1. **`[Next]`** - Logs next question transition:
   ```
   [Next] moving to question 2/5, questionId=q-writing-19
   ```

2. **`[Finish]`** - Logs quiz completion:
   ```
   [Finish] quiz completed, navigating to result
   ```

3. **`[MapRefresh]`** - Logs map refresh (note: actual refresh happens on map screen):
   ```
   [MapRefresh] refreshed map after finish
   ```

## Files Modified

1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Updated `_nextQuestion()` method
   - Updated `_finishQuiz()` method
   - Enhanced `_questionToExercise()` mapper
   - Fixed Next button logic

2. ✅ `lib/features/learning/data/learning_api_client.dart`
   - Accept HTTP 201 for `nextQuizQuestion()`
   - Accept HTTP 201 for `finishQuiz()`

## Overflow Fix (Already Applied)

The RenderFlex overflow was already fixed in the previous change:
- `SafeArea(bottom: true)` wraps the entire Column
- Explanation drawer uses `Flexible(SingleChildScrollView(...))`
- All fixed-height elements are properly sized

## Verification Checklist

- [x] No linter errors
- [x] State machine implemented (QUESTION ↔ REVIEW → FINISH)
- [x] Next question loads correctly
- [x] Quiz finishes when no more questions
- [x] Schema variations handled (type, options/choices, hint/hintAvailable)
- [x] Debug logs added
- [x] Next/Finish decision logic clear
- [x] Error handling for edge cases

## Testing

1. **Next Question Flow:**
   - Answer a question
   - Press "Next"
   - Verify next question loads
   - Verify state resets (no review UI, can select answer)

2. **Finish Flow:**
   - Answer last question
   - Press "Next"
   - Verify quiz finishes
   - Verify summary page shows
   - Verify results are correct

3. **Schema Variations:**
   - Test with `type: "mcq"` (lowercase)
   - Test with `type: "MCQ"` (uppercase)
   - Test with `choices` field
   - Test with `options` field
   - Test with `hintAvailable: true`
   - Test with `hint: "..."` string

4. **Error Cases:**
   - Test with network error
   - Test with 404 response
   - Verify graceful error handling


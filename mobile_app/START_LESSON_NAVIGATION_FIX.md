# Start Lesson Navigation Fix

## Problem
When user taps "Start Lesson" on Lesson Overview (Figma 5.4), the app should navigate to Quiz screen (Figma 5.5) immediately using the backend response, without making an extra API call.

## Backend Response Shape
```
POST /api/learning/lessons/{lessonId}/start
Body: {"mode":"writing"}
Response 201:
{
  "ok": true,
  "data": {
    "sessionId": "...",
    "lessonId": "lesson-1-1",
    "mode": "writing",
    "totalQuestions": 5,
    "question": {
      "index": 1,
      "questionId": "q-writing-18",
      "type": "mcq",
      "prompt": "...",
      "choices": ["..."],
      "hintAvailable": true
    }
  }
}
```

## Solution

### 1. Updated `lesson_start_page.dart`
- **File:** `lib/features/learning/ui/lesson_start_page.dart`
- **Changes:**
  - Parse backend response wrapper `{ok, data, error}`
  - Map `sessionId` → `attemptId` (for compatibility)
  - Map `choices` → `options` (UI expects `options`)
  - Format question data for `ExercisePlayerPage`
  - Add debug logs: `[StartLesson]` and `[Nav]`
  - Navigate immediately with initial question data

### 2. Updated `exercise_player_page.dart`
- **File:** `lib/features/learning/ui/exercise_player_page.dart`
- **Changes:**
  - Use `sessionData` from `startLesson` response directly
  - Skip extra API call (`getQuizQuestion`) when `sessionData` has question
  - Extract `sessionId`, `totalQuestions`, `currentQuestionIndex` from `sessionData`
  - Use question from `sessionData` directly (no network call)
  - Load hearts in parallel

### 3. Updated `learning_api_client.dart`
- **File:** `lib/features/learning/data/learning_api_client.dart`
- **Changes:**
  - Accept HTTP 201 status code (in addition to 200) for `startLesson()`

### 4. Schema Compatibility
- **Backend → UI Mapping:**
  - `sessionId` → `attemptId` (both provided for compatibility)
  - `choices` → `options` (UI expects `options`, backend returns `choices`)
  - `type: "mcq"` → handled by `.toUpperCase()` in `_questionToExercise()`
  - `question.index` → `currentQuestionIndex` (1-based)

## Modified Methods

### `lesson_start_page.dart::_startLesson()`
```dart
// Before: Simple pass-through
sessionData: result

// After: Parse and map fields
- Extract sessionId, totalQuestions, question
- Map choices → options
- Format as {sessionId, attemptId, totalQuestions, currentQuestionIndex, question: {...}}
- Add debug logs
- Navigate with formatted data
```

### `exercise_player_page.dart::_startQuiz()`
```dart
// Before: Always called _loadCurrentQuestion() (extra API call)

// After: 
- If sessionData provided: use question directly, skip API call
- If no sessionData: fallback to startQuiz API (existing flow)
```

### `exercise_player_page.dart::_questionToExercise()`
```dart
// Before: Only checked question['options']

// After: Check both question['options'] and question['choices']
// (Backward compatible with both formats)
```

## Debug Logs Added

1. **`[StartLesson]`** - Logs sessionId, questionId, type
   ```
   [StartLesson] sessionId=abc123, questionId=q-writing-18, type=mcq
   ```

2. **`[Nav]`** - Logs navigation to Quiz screen
   ```
   [Nav] pushing Quiz screen with sessionId=abc123
   ```

## Flow Diagram

### Before
```
User taps "Start Lesson"
  ↓
POST /lessons/{lessonId}/start
  ↓
Navigate to Quiz screen
  ↓
GET /quiz/{attemptId}/question  ← Extra API call
  ↓
Render question
```

### After
```
User taps "Start Lesson"
  ↓
POST /lessons/{lessonId}/start
  ↓
Parse response (sessionId, question, etc.)
  ↓
Map choices → options
  ↓
Navigate to Quiz screen with question data
  ↓
Render question immediately (no extra API call)
```

## Testing

1. **Start Lesson Flow:**
   - Open Lesson Overview
   - Tap "Start Lesson"
   - Verify Quiz screen opens immediately
   - Verify question prompt and choices are displayed
   - Check console logs for `[StartLesson]` and `[Nav]`

2. **Schema Compatibility:**
   - Verify MCQ questions render correctly
   - Verify choices are displayed as options
   - Verify question type is handled (lowercase "mcq" → uppercase "MCQ")

3. **Fallback:**
   - Navigate to Quiz screen without sessionData (direct navigation)
   - Verify fallback to `startQuiz()` API still works

## Files Modified

1. ✅ `lib/features/learning/ui/lesson_start_page.dart`
   - Updated `_startLesson()` method
   - Added `import 'package:flutter/foundation.dart'` for `kDebugMode`

2. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Updated `_startQuiz()` method
   - Updated `_questionToExercise()` to handle both `options` and `choices`

3. ✅ `lib/features/learning/data/learning_api_client.dart`
   - Updated `startLesson()` to accept HTTP 201 status code

## Verification Checklist

- [x] No linter errors
- [x] Response wrapper parsing (`{ok, data, error}`)
- [x] Schema mapping (`choices` → `options`, `sessionId` → `attemptId`)
- [x] Debug logs added
- [x] Navigation with initial question (no extra API call)
- [x] Backward compatibility (handles both `options` and `choices`)
- [x] Type conversion (lowercase → uppercase handled)


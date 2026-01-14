# Quiz Loop and Premature Dispose Audit Report

## 1. All Triggers Located

### _nextQuestion() Triggers
**Location:** `lib/features/learning/ui/exercise_player_page.dart`

1. **Line 711**: `BottomFeedbackBar.onContinue` callback
   - **Condition**: `_isInReview && !_outOfHearts && !_isLoading && !_finishRequested && !_navigatedToResult`
   - **Trigger**: User taps "Continue" button after answering
   - **Guard**: Multiple flags prevent duplicate calls

### _finishQuiz() Triggers
**Location:** `lib/features/learning/ui/exercise_player_page.dart`

1. **Line 331**: Inside `_nextQuestion()` when question data exists but no question field
   - **Condition**: `result.hasQuestion && result.questionData != null && question == null`
   - **Guard**: `_finishRequested` is set BEFORE calling `_finishQuiz()`

2. **Line 341**: Inside `_nextQuestion()` when `/next` returns 404
   - **Condition**: `!result.hasQuestion` (404 "No more questions")
   - **Guard**: `_finishRequested` is set BEFORE calling `_finishQuiz()`

**No other triggers found.** ✅

### Navigator Operations
**Location:** `lib/features/learning/ui/exercise_player_page.dart`

1. **Line 409**: `Navigator.pushReplacement()` - Navigate to result screen
   - **Condition**: `mounted && !_navigatedToResult` (inside `_finishQuiz()`)
   - **Guard**: `_navigatedToResult` is set BEFORE navigation

2. **Line 592**: `Navigator.pop()` - Error state "Go Back"
   - **Condition**: `_currentQuestion == null` (error state)
   - **Safe**: Only in error state, not during quiz flow

3. **Line 615**: `Navigator.pop()` - TopProgressHeader close button
   - **Condition**: User manually closes quiz
   - **Safe**: User-initiated, not automatic

4. **Line 657**: `Navigator.pop()` - Hint modal close
   - **Condition**: User closes hint modal
   - **Safe**: Modal navigation only

**No automatic navigation based on question index.** ✅

### Dispose Logic
**Location:** `lib/features/learning/ui/exercise_player_page.dart`

1. **Line 86-89**: Standard `dispose()` lifecycle method
   - **Trigger**: Widget removed from tree (after navigation)
   - **Safe**: Only logs, no navigation or API calls

**No premature dispose triggers found.** ✅

## 2. Confirmation: No Navigation Based on Question Index

### Search Results
**Searched for:** `currentQuestionIndex.*>=|currentQuestionIndex.*==|currentQuestionIndex.*>|totalQuestions.*<=|totalQuestions.*==`

**Result:** **NO MATCHES FOUND** ✅

### Code Analysis
- **Line 707**: Comment explicitly states: `// CRITICAL: Never check currentQuestionIndex >= totalQuestions here; let backend decide via 404`
- **Line 708**: Next button guard: `_isInReview && !_outOfHearts && !_isLoading && !_finishRequested && !_navigatedToResult`
  - **No index comparison** - relies on backend 404 response
- **Line 280**: `_nextQuestion()` guard checks: `!_isInReview || _isLoading || _finishRequested || _navigatedToResult`
  - **No index comparison** - relies on state flags

**Proof:** The last question (5/5) is always answerable. Navigation only happens after `/next` returns 404, not based on index comparison.

## 3. Question Parsing Consistency

### Type Casing
**Location:** `lib/features/learning/ui/exercise_player_page.dart:490-503`

```dart
final typeStr = question['type'] as String? ?? 'MCQ';
// ...
switch (typeStr.toUpperCase()) {
  case 'MCQ':
    type = ExerciseType.mcq;
    break;
  case 'MATCH':
    type = ExerciseType.match;
    break;
  case 'FILL_IN':
  case 'FILL':
    type = ExerciseType.fill;
    break;
  default:
    type = ExerciseType.mcq;
}
```

**Status:** ✅ **Handles both "MCQ" and "mcq"** via `toUpperCase()`

### Options Field
**Location:** `lib/features/learning/ui/exercise_player_page.dart:479-481`

```dart
// Backend may return "choices" or "options" - handle both
final options = (question['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
    (question['choices'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
```

**Status:** ✅ **Handles both "options" and "choices"** via null-coalescing operator

**No normalization needed at API client level** - parsing is already robust.

## 4. Final Log Added

**Location:** `lib/features/learning/ui/exercise_player_page.dart:409`

```dart
_logEvent('[Flow] RESULT_SCREEN_PUSHED');
await Navigator.pushReplacement(...);
```

**Status:** ✅ **Log added immediately before navigation**

## 5. Proof: Code Paths That Prevent Issues

### Proof 1: Prevents Calling /next After Finish

**Code Path:**
```
_nextQuestion() called (line 711)
  ↓
Guard check (line 280):
  if (_attemptId == null || !_isInReview || _isLoading || _finishRequested || _navigatedToResult)
    return; // BLOCKED
  ↓
If /next returns 404 (line 334):
  setState(() {
    _finishRequested = true; // SET BEFORE calling finish
    _isLoading = false;
  });
  await _finishQuiz();
  ↓
If user taps Next again:
  Guard check (line 280):
    _finishRequested == true → return; // BLOCKED ✅
```

**Proof:** Line 280 guard checks `_finishRequested`, which is set at line 328/338 BEFORE calling `_finishQuiz()`. Any subsequent call to `_nextQuestion()` will be blocked.

### Proof 2: Prevents Disposing at 5/5 Display

**Code Path:**
```
Question 5/5 displayed:
  _currentQuestion != null (line 581 check passes)
  _currentQuestionIndex == 5
  _totalQuestions == 5
  ↓
User answers question 5:
  _handleAnswer() called (line 168)
  Sets _isInReview = true (line 211)
  ↓
User taps "Continue":
  onContinue callback (line 708):
    _isInReview == true ✅
    !_outOfHearts ✅
    !_isLoading ✅
    !_finishRequested ✅ (not set yet)
    !_navigatedToResult ✅ (not set yet)
    → onContinue is NOT null → _nextQuestion() called
  ↓
_nextQuestion() calls /next:
  If 404 returned:
    _finishRequested = true (line 328/338)
    _finishQuiz() called
  ↓
_finishQuiz() navigates:
  _navigatedToResult = true (line 398)
  Navigator.pushReplacement() (line 409)
  ↓
Widget disposed AFTER navigation (line 86)
```

**Proof:** 
- No code checks `currentQuestionIndex >= totalQuestions` to trigger navigation
- Question 5/5 is displayed and answerable (line 581 check passes)
- Navigation only happens after `/next` returns 404 (line 334/341)
- `dispose()` only called after navigation completes (line 86, after line 409)

### Proof 3: Prevents Loop

**Code Path:**
```
User taps Next after last question:
  _nextQuestion() called
  /next returns 404
  ↓
Line 335: _logEvent('[Flow] finished detected from 404; calling finish once')
Line 337-340: setState(() {
    _finishRequested = true; // SET IMMEDIATELY
    _isLoading = false;
  });
Line 341: await _finishQuiz();
  ↓
_finishQuiz() guard (line 371):
  if (_attemptId == null || _navigatedToResult || _isLoading)
    return; // BLOCKED if already navigated
  ↓
_finishQuiz() sets _navigatedToResult (line 398):
  setState(() {
    _navigatedToResult = true; // SET BEFORE navigation
  });
  ↓
Navigator.pushReplacement() (line 409)
  ↓
If user taps Next again (shouldn't happen, but if it does):
  Line 708 guard:
    !_finishRequested → FALSE (already set) → onContinue = null → BLOCKED ✅
  ↓
If _nextQuestion() somehow called:
  Line 280 guard:
    _finishRequested == true → return; // BLOCKED ✅
```

**Proof:** 
- `_finishRequested` is set at line 328/338 BEFORE calling `_finishQuiz()`
- `_navigatedToResult` is set at line 398 BEFORE navigation
- Both guards (line 280 and line 708) check these flags
- Button is disabled when `_finishRequested == true` (line 708)

## 6. Remaining Risky Triggers

### None Found ✅

**Analysis:**
- No listeners, providers, or streams that auto-trigger Next/Finish
- No timers or postFrameCallbacks that call Next/Finish
- No conditional navigation based on question index
- All navigation is user-initiated or backend-driven (404 response)

**Only Safe Triggers:**
1. User taps "Continue" button → `_nextQuestion()` (guarded)
2. `/next` returns 404 → `_finishQuiz()` (guarded, `_finishRequested` set first)
3. `_finishQuiz()` success → `Navigator.pushReplacement()` (guarded, `_navigatedToResult` set first)

## Summary

### Files Changed
1. ✅ `lib/features/learning/ui/exercise_player_page.dart`
   - Added `[Flow] RESULT_SCREEN_PUSHED` log at line 409

### Proof Summary

**Prevents /next after finish:**
- Line 280: Guard checks `_finishRequested`
- Line 328/338: `_finishRequested` set BEFORE calling `_finishQuiz()`
- Line 708: Button disabled when `_finishRequested == true`

**Prevents dispose at 5/5:**
- No code compares `currentQuestionIndex >= totalQuestions`
- Question 5/5 is always answerable (line 581 check passes)
- Navigation only after `/next` returns 404
- `dispose()` only after navigation completes

**Prevents loop:**
- `_finishRequested` set BEFORE `_finishQuiz()` call
- `_navigatedToResult` set BEFORE navigation
- Multiple guards check these flags
- Button disabled during finish/navigation

### Question Parsing
- ✅ Type casing: `toUpperCase()` handles "MCQ"/"mcq"
- ✅ Options field: Null-coalescing handles "options"/"choices"
- ✅ No API client normalization needed

### Remaining Risks
- **None identified** ✅

All triggers are guarded, and no automatic navigation based on question index exists.


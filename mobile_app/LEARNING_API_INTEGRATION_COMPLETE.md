# Learning API Integration - Complete

## Summary

All Learning feature screens have been integrated with the new backend APIs (`/api/learning/*`). Mock data and legacy endpoints have been replaced with real API calls.

---

## Files Changed

### Core API Client
1. **`lib/features/learning/data/learning_api_client.dart`**
   - Added debug logging for all API calls (`_logApiCall()`)
   - Fixed response wrapper parsing to handle `{success, data}` consistently
   - All methods now log: `[Learning API] METHOD /path`

### Screen Integrations

2. **`lib/features/learning/ui/galaxy_map_screen.dart`** (5.1 Map)
   - ✅ Replaced `LearningRepository.getUnits()` with `LearningApiClient.getLearningMap()`
   - ✅ Removed `UnitService.fetchUnits()` fallback
   - ✅ Parses API response: `{unitId, unitTitle, skills: [{skillId, title, state, position, progressPercent}]}`
   - ✅ Converts skills to lessons with proper status (LOCKED/AVAILABLE/COMPLETED/CURRENT)
   - ✅ Removed offline data indicator

3. **`lib/features/learning/ui/galaxy_map_screen.dart`** (5.2 Skill Picker)
   - ✅ Added `getModesForSkill()` call when skill planet is tapped
   - ✅ Checks if mode is locked before navigation
   - ✅ Shows error if API fails

4. **`lib/features/learning/ui/lesson_detail_screen.dart`** (5.3 Lesson Detail)
   - ✅ Converted to StatefulWidget
   - ✅ Calls `getLessonDetail()` on init
   - ✅ Uses API data for title, description, level
   - ✅ Shows loading and error states

5. **`lib/features/learning/ui/lesson_start_page.dart`** (5.4 Lesson Overview + Start)
   - ✅ Converted to StatefulWidget
   - ✅ Calls `getLessonOverview()` on init (with optional mode parameter)
   - ✅ Calls `startLesson()` when Start button is pressed
   - ✅ Passes session data to ExercisePlayerPage
   - ✅ Displays API data: estimatedTime, xpReward, totalQuestions, hearts, streakProtected

6. **`lib/features/learning/ui/exercise_player_page.dart`** (5.5-5.6-5.9 Quiz Flow)
   - ✅ **Complete rewrite** to use quiz attempt flow:
     - `startQuiz()` - Start quiz attempt
     - `getQuizQuestion()` - Get current question
     - `submitQuizAnswer()` - Submit answer
     - `nextQuizQuestion()` - Move to next question
     - `finishQuiz()` - Finish quiz and navigate to summary
   - ✅ Replaced `getItems()` with quiz flow
   - ✅ Converts API question format to `ExerciseItem` for UI
   - ✅ Handles MCQ, MATCH, FILL_IN question types
   - ✅ Uses hearts from API (5.7)
   - ✅ Shows hint from question payload (5.10)

7. **`lib/features/learning/ui/practice_hub_page.dart`** (5.8 Practice Hub)
   - ✅ Converted to StatefulWidget
   - ✅ Calls `getPracticeHub()` on init
   - ✅ Displays weak skills, mistake questions, spaced repetition queue from API
   - ✅ Calls `startPractice()` when user starts practice
   - ✅ Shows loading and error states

---

## Endpoints Used by Each Screen

| Screen | Endpoint | Method | When Called |
|--------|----------|--------|-------------|
| **Galaxy Map** | `/api/learning/map` | GET | On screen load |
| **Skill Picker** | `/api/learning/skills/{skillId}/modes` | GET | When skill planet tapped |
| **Lesson Detail** | `/api/learning/lessons/{lessonId}` | GET | On screen load |
| **Lesson Overview** | `/api/learning/lessons/{lessonId}/overview` | GET | On screen load |
| **Start Lesson** | `/api/learning/lessons/{lessonId}/start` | POST | When Start button pressed |
| **Quiz Start** | `/api/learning/quiz/start` | POST | When exercise player loads |
| **Get Question** | `/api/learning/quiz/{attemptId}/question` | GET | On load, after next |
| **Submit Answer** | `/api/learning/quiz/{attemptId}/answer` | POST | When user submits answer |
| **Next Question** | `/api/learning/quiz/{attemptId}/next` | POST | When Continue pressed |
| **Finish Quiz** | `/api/learning/quiz/{attemptId}/finish` | POST | When last question answered |
| **Get Hearts** | `/api/learning/hearts` | GET | On load, after wrong answer |
| **Practice Hub** | `/api/learning/practice/hub` | GET | On screen load |
| **Start Practice** | `/api/learning/practice/start` | POST | When practice started |

---

## Key Changes

### 1. Response Wrapper Handling
All API methods now consistently handle the backend response wrapper:
```dart
final data = jsonDecode(response.body) as Map<String, dynamic>;
if (data.containsKey('data')) {
  return data['data'] as Map<String, dynamic>;
}
return data;
```

### 2. Debug Logging
All API calls log to console in debug builds:
```dart
_logApiCall('GET', '/learning/map');
// Output: [Learning API] GET /learning/map
```

### 3. Error Handling
- Removed all mock fallbacks
- Shows proper error states using `LearningErrorState`
- No silent failures

### 4. Hearts Integration (5.7)
- Replaced `HeartsService` (local storage) with API calls
- `getHearts()` called on load and after wrong answers
- Hearts consumed server-side, client syncs via API
- Out-of-hearts dialog uses API cooldown data

### 5. Quiz Flow (5.5-5.6-5.9)
- Complete replacement of `getItems()` with quiz attempt flow
- Questions fetched one at a time from API
- Answers submitted immediately
- Progress tracked server-side
- Summary uses API result data

### 6. Hint Support (5.10)
- Uses `hint` field from question payload
- No new endpoint needed

---

## Manual Test Steps (Android Emulator)

### Prerequisites
1. Backend running on `http://localhost:3001`
2. Android emulator running
3. Backend has seeded data

### Test Flow

#### 1. Galaxy Map (5.1)
```
1. Open app → Navigate to Learning → Galaxy Map
2. Verify map loads with units/skills from API
3. Check console logs: [Learning API] GET /learning/map
4. Verify no "offline data" banner
```

#### 2. Skill Picker (5.2)
```
1. Tap a lesson planet in galaxy map
2. Tap a skill planet (listening/speaking/reading/writing)
3. Verify console: [Learning API] GET /learning/skills/{skillId}/modes
4. If locked, verify error message
5. If available, navigate to lesson detail
```

#### 3. Lesson Detail (5.3)
```
1. Navigate to lesson detail screen
2. Verify console: [Learning API] GET /learning/lessons/{lessonId}
3. Verify lesson title, description, level from API
```

#### 4. Lesson Overview + Start (5.4)
```
1. Navigate to lesson start page
2. Verify console: [Learning API] GET /learning/lessons/{lessonId}/overview
3. Verify preview cards show API data (time, XP, questions, hearts)
4. Tap "Start Lesson"
5. Verify console: [Learning API] POST /learning/lessons/{lessonId}/start
6. Verify navigation to exercise player
```

#### 5. Quiz Flow (5.5-5.6-5.9)
```
1. In exercise player, verify console:
   - [Learning API] POST /learning/quiz/start
   - [Learning API] GET /learning/quiz/{attemptId}/question
2. Answer a question
3. Verify console: [Learning API] POST /learning/quiz/{attemptId}/answer
4. Verify feedback (correct/wrong)
5. Tap Continue
6. Verify console: [Learning API] POST /learning/quiz/{attemptId}/next
7. Continue until last question
8. Answer last question, tap Continue
9. Verify console: [Learning API] POST /learning/quiz/{attemptId}/finish
10. Verify navigation to summary with API result data
```

#### 6. Hearts (5.7)
```
1. Answer a question incorrectly
2. Verify console: [Learning API] POST /learning/quiz/{attemptId}/answer
3. Verify hearts decrease (check TopProgressHeader)
4. If hearts reach 0, verify out-of-hearts dialog
5. Verify dialog shows cooldown from API
```

#### 7. Practice Hub (5.8)
```
1. Navigate to Practice Hub
2. Verify console: [Learning API] GET /learning/practice/hub
3. Verify weak skills, mistakes, spaced repetition displayed
4. Tap a practice option
5. Verify console: [Learning API] POST /learning/practice/start
```

#### 8. Hint (5.10)
```
1. In exercise player, if question has hint
2. Tap "Show hint" button
3. Verify hint from question payload is displayed
```

---

## Checklist

- [x] 5.1 Map: `getLearningMap()` integrated
- [x] 5.2 Skill Picker: `getModesForSkill()` integrated
- [x] 5.3 Lesson Detail: `getLessonDetail()` integrated
- [x] 5.4 Overview + Start: `getLessonOverview()` and `startLesson()` integrated
- [x] 5.5-5.6 Quiz Flow: Complete quiz attempt flow integrated
- [x] 5.7 Hearts: API calls replace local storage
- [x] 5.8 Practice Hub: `getPracticeHub()` and `startPractice()` integrated
- [x] 5.10 Hint: Uses hint from question payload
- [x] Debug logging added to all API calls
- [x] Response wrapper parsing fixed consistently
- [x] All mock fallbacks removed
- [x] Error states show proper messages
- [x] `x-user-id` header sent automatically (via `HttpClientWithUser`)

---

## Remaining Notes

1. **HeartsService**: Still exists but is no longer used by Learning feature. Could be removed or kept for other features.

2. **LearningRepository**: Still exists with `useMockFallback` flag, but is no longer used by updated screens. Could be deprecated.

3. **Legacy Endpoints**: Old endpoints (`/domains/`, `/units/`, `/lessons/items`) are no longer called by updated screens.

4. **Question Type Mapping**: API question types (MCQ, MATCH, FILL_IN) are mapped to Flutter `ExerciseType` enum. If backend adds new types, update `_questionToExercise()`.

5. **Session Data**: `ExercisePlayerPage` accepts optional `sessionData` from `startLesson()`. If provided, uses it instead of calling `startQuiz()`.

---

## Testing Checklist

- [ ] App launches without errors
- [ ] Galaxy map loads from API
- [ ] Skill picker fetches modes
- [ ] Lesson detail loads from API
- [ ] Lesson overview shows API data
- [ ] Quiz flow works end-to-end
- [ ] Hearts sync with API
- [ ] Practice hub loads from API
- [ ] Hints display correctly
- [ ] Error states show when API fails
- [ ] Debug logs appear in console
- [ ] No mock data fallbacks occur

---

## Next Steps

1. Test on Android emulator with backend running
2. Verify all API responses match expected format
3. Handle edge cases (empty responses, network errors)
4. Add retry logic if needed
5. Remove deprecated code (`HeartsService`, `LearningRepository` with mock fallback)


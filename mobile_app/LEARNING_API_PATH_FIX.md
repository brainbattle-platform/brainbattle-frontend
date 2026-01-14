# Learning API Path Fix - Double /learning Removed

## Problem
- Base URL (`ApiConfig.learningBaseUrl`) already includes `/api/learning`
- `LearningApiClient` was prepending `/learning` to all paths
- Result: `/api/learning/learning/*` → 404 errors

## Solution
Removed `/learning` prefix from all request paths in `LearningApiClient`.

---

## Modified Methods

### Map & Skills
1. ✅ `getLearningMap()` - `/learning/map` → `/map`
2. ✅ `getSkillsForUnit()` - `/learning/units/{unitId}/skills` → `/units/{unitId}/skills`
3. ✅ `getModesForSkill()` - `/learning/skills/{skillId}/modes` → `/skills/{skillId}/modes`

### Lessons
4. ✅ `getLessonDetail()` - `/learning/lessons/{lessonId}` → `/lessons/{lessonId}`
5. ✅ `getLessonOverview()` - `/learning/lessons/{lessonId}/overview` → `/lessons/{lessonId}/overview`
6. ✅ `startLesson()` - `/learning/lessons/{lessonId}/start` → `/lessons/{lessonId}/start`

### Quiz Flow
7. ✅ `startQuiz()` - `/learning/quiz/start` → `/quiz/start`
8. ✅ `getQuizQuestion()` - `/learning/quiz/{attemptId}/question` → `/quiz/{attemptId}/question`
9. ✅ `submitQuizAnswer()` - `/learning/quiz/{attemptId}/answer` → `/quiz/{attemptId}/answer`
10. ✅ `nextQuizQuestion()` - `/learning/quiz/{attemptId}/next` → `/quiz/{attemptId}/next`
11. ✅ `finishQuiz()` - `/learning/quiz/{attemptId}/finish` → `/quiz/{attemptId}/finish`

### Hearts
12. ✅ `getHearts()` - `/learning/hearts` → `/hearts`
13. ✅ `consumeHeart()` - `/learning/hearts/consume` → `/hearts/consume`
14. ✅ `recoverHearts()` - `/learning/hearts/recover` → `/hearts/recover`

### Practice
15. ✅ `getPracticeHub()` - `/learning/practice/hub` → `/practice/hub`
16. ✅ `startPractice()` - `/learning/practice/start` → `/practice/start`

**Total:** 16 methods fixed

---

## Final URL Format

### Base URL (from `ApiConfig.learningBaseUrl`)
- Android Emulator: `http://10.0.2.2:3001/api/learning`
- Android Real Device: `http://10.0.16.6:3001/api/learning`
- iOS Simulator: `http://localhost:3001/api/learning`

### Path Construction
```dart
baseUrl + path = final URL
```

### Examples

| Method | Path | Base URL | Final URL |
|--------|------|----------|-----------|
| `getLearningMap()` | `/map` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/map` ✅ |
| `getModesForSkill()` | `/skills/{skillId}/modes` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/skills/{skillId}/modes` ✅ |
| `startQuiz()` | `/quiz/start` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/quiz/start` ✅ |
| `getHearts()` | `/hearts` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/hearts` ✅ |
| `getPracticeHub()` | `/practice/hub` | `http://10.0.2.2:3001/api/learning` | `http://10.0.2.2:3001/api/learning/practice/hub` ✅ |

---

## Debug Logging

All methods log the path (without base URL) for debugging:
```dart
_logApiCall('GET', '/map');
// Output: [Learning API] GET /map
```

The full URL is logged by `HttpClientWithUser`:
```dart
// Output: [HTTP GET] http://10.0.2.2:3001/api/learning/map
```

---

## Verification

### Before Fix
- ❌ `http://10.0.2.2:3001/api/learning/learning/map` (404)

### After Fix
- ✅ `http://10.0.2.2:3001/api/learning/map` (200)

---

## File Changed
- `lib/features/learning/data/learning_api_client.dart` - All 16 API methods updated

---

## Testing
1. Run app on emulator/device
2. Check console logs: `[Learning API] GET /map`
3. Check HTTP logs: `[HTTP GET] http://10.0.2.2:3001/api/learning/map`
4. Verify API responds with 200 (not 404)


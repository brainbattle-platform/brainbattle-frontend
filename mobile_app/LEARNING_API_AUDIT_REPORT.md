# Learning API Integration Audit Report

**Date:** 2024  
**Scope:** `lib/features/learning` and shared networking layers  
**Purpose:** Verify real API usage vs mock data

---

## 1. Real HTTP Endpoints Currently Called

### API Client: `LearningApiClient`
**Location:** `lib/features/learning/data/learning_api_client.dart`  
**Base URL Source:** `ApiConfig.learningBaseUrl`
- **Android:** `http://10.0.2.2:3001/api/learning` (default)
- **iOS:** `http://localhost:3001/api/learning` (default)
- **Override:** `--dart-define=LEARNING_API_BASE_URL=http://...`

**HTTP Client:** `HttpClientWithUser` (`lib/core/network/http_client_with_user.dart`)
- **Headers:** 
  - `Content-Type: application/json`
  - `x-user-id: {userId}` (from `UserContextService`, defaults to `"user_1"`)

### Endpoints Defined (NOT YET USED IN UI)

| Method | Path | Function | Status |
|--------|------|----------|--------|
| GET | `/learning/map` | `getLearningMap()` | ❌ **Not called by UI** |
| GET | `/learning/units/{unitId}/skills` | `getSkillsForUnit()` | ❌ **Not called by UI** |
| GET | `/learning/skills/{skillId}/modes` | `getModesForSkill()` | ❌ **Not called by UI** |
| GET | `/learning/lessons/{lessonId}` | `getLessonDetail()` | ❌ **Not called by UI** |
| GET | `/learning/lessons/{lessonId}/overview` | `getLessonOverview()` | ❌ **Not called by UI** |
| POST | `/learning/lessons/{lessonId}/start` | `startLesson()` | ❌ **Not called by UI** |
| POST | `/learning/quiz/start` | `startQuiz()` | ❌ **Not called by UI** |
| GET | `/learning/quiz/{attemptId}/question` | `getQuizQuestion()` | ❌ **Not called by UI** |
| POST | `/learning/quiz/{attemptId}/answer` | `submitQuizAnswer()` | ❌ **Not called by UI** |
| POST | `/learning/quiz/{attemptId}/next` | `nextQuizQuestion()` | ❌ **Not called by UI** |
| POST | `/learning/quiz/{attemptId}/finish` | `finishQuiz()` | ❌ **Not called by UI** |
| GET | `/learning/hearts` | `getHearts()` | ❌ **Not called by UI** |
| POST | `/learning/hearts/consume` | `consumeHeart()` | ❌ **Not called by UI** |
| POST | `/learning/hearts/recover` | `recoverHearts()` | ❌ **Not called by UI** |
| GET | `/learning/practice/hub` | `getPracticeHub()` | ❌ **Not called by UI** |
| POST | `/learning/practice/start` | `startPractice()` | ❌ **Not called by UI** |

### Endpoints Actually Called (OLD/LEGACY)

| Method | Path | Function | Where Called | Status |
|--------|------|----------|--------------|--------|
| GET | `/domains/{domainId}/units` | `getUnits()` | `LearningRepository.getUnits()` → `LearningApiClient.getUnits()` | ⚠️ **Legacy endpoint** |
| GET | `/units/{unitId}/lessons` | `getLessons()` | `LearningRepository.getLessons()` → `LearningApiClient.getLessons()` | ⚠️ **Legacy endpoint** |
| GET | `/lessons/{lessonId}/items` | `getItems()` | `LearningRepository.getItems()` → `LearningApiClient.getItems()` | ⚠️ **Legacy endpoint** |
| GET | `/skills/{skillId}/lessons` | `fetchLessons()` | `LessonService.fetchLessons()` (deprecated) | ❌ **Deprecated, old endpoint** |

**Note:** These legacy endpoints (`/domains/`, `/units/`, `/lessons/items`) are **NOT** the new Learning API endpoints (`/api/learning/*`). They appear to be old API structure.

---

## 2. Mock/Stub Data Usage

### A. Repository-Level Mock Fallback

**File:** `lib/features/learning/data/learning_repository.dart`

**Conditional Flag:** `useMockFallback` (default: `true`)

**Methods with Mock Fallback:**
1. `getUnits()` - Falls back to `MockLearningData.englishDomain().units` on API error
2. `getLessons()` - Falls back to `MockLearningData.englishDomain()` units on API error
3. `getItems()` - Falls back to `MockLearningData.exercisesForLesson(lessonId)` on API error

**How to Switch to Real API:**
```dart
final repository = LearningRepository(useMockFallback: false);
```

**Where Used:**
- `lib/features/learning/ui/galaxy_map_screen.dart:35` - `LearningRepository()` (uses default `useMockFallback: true`)
- `lib/features/learning/ui/exercise_player_page.dart:53` - `LearningRepository()` (uses default `useMockFallback: true`)

---

### B. UI-Level Mock Fallback

**File:** `lib/features/learning/ui/galaxy_map_screen.dart:66-75`

**Fallback Chain:**
1. Try `LearningRepository.getUnits()` (with mock fallback)
2. If that fails, fallback to `UnitService.fetchUnits()` (mock)

**Code:**
```dart
try {
  final units = await _repository.getUnits(domainId: 'english');
  // ...
} catch (e) {
  // Fallback to UnitService (mock)
  final units = await _svc.fetchUnits();
  // ...
}
```

**How to Switch:** Remove catch block or ensure API succeeds.

---

**File:** `lib/features/learning/ui/exercise_player_page.dart:82-93`

**Fallback:**
```dart
try {
  final items = await _repository.getItems(lessonId: widget.lesson.id);
  // ...
} catch (e) {
  // Fallback to mock
  _exercises = MockLearningData.exercisesForLesson(widget.lesson.id);
  // ...
}
```

**How to Switch:** Remove catch block or ensure API succeeds.

---

### C. Direct Mock Data Usage (No API Attempt)

**File:** `lib/features/learning/ui/review_queue_page.dart:19-22`
```dart
final _reviewQueue = [
  MockLearningData.lesson1(),
  MockLearningData.lesson2(),
];
```
**Why Mock:** Hardcoded list, no API call  
**How to Switch:** Add API call to fetch review queue

---

**File:** `lib/features/learning/ui/practice_hub_page.dart:18-88`
```dart
// Mock weak skills
final weakSkills = [
  // ... hardcoded list
];
```
**Why Mock:** Hardcoded list, no API call  
**How to Switch:** Call `LearningApiClient.getPracticeHub()`

---

**File:** `lib/features/learning/ui/mistakes_review_page.dart:35`
```dart
final allExercises = MockLearningData.exercisesForLesson(widget.lesson.id);
```
**Why Mock:** Direct mock usage, no API call  
**How to Switch:** Call `LearningRepository.getItems()` or `LearningApiClient.getItems()`

---

**File:** `lib/features/learning/ui/lesson_start_page.dart:26`
```dart
final exercises = MockLearningData.exercisesForLesson(lesson.id);
```
**Why Mock:** Direct mock usage, no API call  
**How to Switch:** Call `LearningRepository.getItems()`

---

**File:** `lib/features/learning/ui/domain_selector_bottom_sheet.dart:38-39`
```dart
_domains = [
  MockLearningData.englishDomain(),
  MockLearningData.programmingDomain(),
];
```
**Why Mock:** Hardcoded list, no API call  
**How to Switch:** Add API call to fetch domains

---

**File:** `lib/features/learning/ui/curriculum_browser_page.dart:25`
```dart
_selectedDomain = MockLearningData.englishDomain();
```
**Why Mock:** Hardcoded, no API call  
**How to Switch:** Add API call to fetch domains

---

**File:** `lib/features/learning/ui/learning_stats_page.dart:15`
```dart
// Mock stats
```
**Why Mock:** Hardcoded stats, no API call  
**How to Switch:** Add API call to fetch stats

---

**File:** `lib/features/learning/ui/league_page.dart:15`
```dart
// Mock leaderboard
```
**Why Mock:** Hardcoded leaderboard, no API call  
**How to Switch:** Add API call to fetch leaderboard

---

**File:** `lib/features/learning/ui/achievements_page.dart:15`
```dart
// Mock achievements
```
**Why Mock:** Hardcoded achievements, no API call  
**How to Switch:** Add API call to fetch achievements

---

**File:** `lib/features/learning/ui/placement_test_page.dart:35`
```dart
}; // Mock correct answers
```
**Why Mock:** Hardcoded answers, no API call  
**How to Switch:** Add API call to fetch placement test data

---

### D. Legacy Services (Mock/Deprecated)

**File:** `lib/features/learning/data/unit_service.dart`
- Uses old endpoint structure
- May be mock or legacy API

**File:** `lib/features/learning/data/lesson_service.dart`
- **Status:** `@Deprecated`
- **Endpoint:** `/skills/{skillId}/lessons` (old structure)
- **Where Used:** `lib/features/learning/ui/lessons_sceen.dart:29`

---

## 3. API Contract Mismatches

### A. Response Wrapper

**Expected:** `{ "success": true, "data": {...} }`  
**Actual in Code:** 
- `LearningApiClient` methods extract `data['data']` ✅ (correct)
- Legacy methods (`getUnits`, `getLessons`, `getItems`) expect raw arrays ❌ (may be wrong)

**File:** `lib/features/learning/data/learning_api_client.dart:33-34`
```dart
final data = jsonDecode(response.body) as List<dynamic>;
return data.map((e) => _unitFromJson(e as Map<String, dynamic>)).toList();
```
**Issue:** Expects raw array, but new API returns `{success, data}` wrapper.

---

### B. Endpoint Path Mismatch

**New Learning API:** `/api/learning/*`  
**Old/Legacy API:** `/domains/*`, `/units/*`, `/lessons/*`

**Current State:**
- `LearningApiClient` uses `ApiConfig.learningBaseUrl` which points to `/api/learning`
- But `getUnits()`, `getLessons()`, `getItems()` call paths like `/domains/{domainId}/units` which don't match new API structure
- New methods (`getLearningMap()`, `getModesForSkill()`, etc.) use correct `/learning/*` paths but are **NOT CALLED**

---

### C. Missing Fields / Wrong Types

**File:** `lib/features/learning/data/lesson_model.dart:44`
```dart
description: json['description'] ?? 'Demo lesson from API',
```
**Issue:** Fallback value suggests API may not return description.

**File:** `lib/features/learning/ui/galaxy_map_screen.dart:285`
```dart
final LessonStatus status = (lesson.status) ?? _resolveStatus(i, lessons);
```
**Issue:** Status may be null, uses fallback logic.

**File:** `lib/features/learning/ui/galaxy_map_screen.dart:348-351`
```dart
double _to01(double? p) {
  final v = (p ?? 0).clamp(0, 100);
  return v > 1 ? v / 100 : v.toDouble();
}
```
**Issue:** Progress may be null or in wrong format (0-100 vs 0-1).

---

## 4. Final Checklist

### Real API Used ✅/❌

| Feature | Endpoint | Status | Notes |
|---------|----------|--------|-------|
| **Map** | `GET /api/learning/map` | ❌ **NOT USED** | `getLearningMap()` exists but UI doesn't call it |
| **Modes** | `GET /api/learning/skills/{skillId}/modes` | ❌ **NOT USED** | `getModesForSkill()` exists but UI doesn't call it |
| **Overview** | `GET /api/learning/lessons/{lessonId}/overview` | ❌ **NOT USED** | `getLessonOverview()` exists but UI doesn't call it |
| **Start Quiz** | `POST /api/learning/quiz/start` | ❌ **NOT USED** | `startQuiz()` exists but UI doesn't call it |
| **Finish Quiz** | `POST /api/learning/quiz/{attemptId}/finish` | ❌ **NOT USED** | `finishQuiz()` exists but UI doesn't call it |
| **Hearts** | `GET /api/learning/hearts` | ❌ **NOT USED** | `getHearts()` exists but UI uses `HeartsService` (local storage) |
| **Practice Hub** | `GET /api/learning/practice/hub` | ❌ **NOT USED** | `getPracticeHub()` exists but UI uses mock data |

### Mock Remains At:

1. **Repository Level:**
   - `LearningRepository` - `useMockFallback: true` by default
   - Used in: `galaxy_map_screen.dart`, `exercise_player_page.dart`

2. **UI Level Fallbacks:**
   - `galaxy_map_screen.dart:66` - Falls back to `UnitService` (mock)
   - `exercise_player_page.dart:82` - Falls back to `MockLearningData`

3. **Direct Mock Usage (No API):**
   - `review_queue_page.dart` - Hardcoded review queue
   - `practice_hub_page.dart` - Hardcoded weak skills
   - `mistakes_review_page.dart` - Direct mock exercises
   - `lesson_start_page.dart` - Direct mock exercises
   - `domain_selector_bottom_sheet.dart` - Hardcoded domains
   - `curriculum_browser_page.dart` - Hardcoded domain
   - `learning_stats_page.dart` - Hardcoded stats
   - `league_page.dart` - Hardcoded leaderboard
   - `achievements_page.dart` - Hardcoded achievements
   - `placement_test_page.dart` - Hardcoded answers

4. **Legacy Services:**
   - `UnitService` - Old endpoint structure
   - `LessonService` - Deprecated, old endpoint structure

---

## Summary

### Current State:
- ✅ **API Client Ready:** `LearningApiClient` has all new Learning API methods defined
- ❌ **Not Integrated:** UI screens do NOT call new API methods
- ⚠️ **Using Legacy:** UI uses old `LearningRepository` methods that call legacy endpoints (`/domains/`, `/units/`, `/lessons/items`)
- ❌ **Mock Fallback Active:** `useMockFallback: true` by default, falls back to mock on any error
- ❌ **Direct Mock:** Many screens use mock data directly without attempting API calls

### Critical Issues:
1. **New API methods exist but are never called** - UI needs to be updated to use them
2. **Legacy endpoints** - Old API structure still in use (`/domains/`, `/units/`, `/lessons/items`)
3. **Mock fallback too aggressive** - Any API error immediately falls back to mock
4. **Response wrapper mismatch** - Legacy methods expect raw arrays, new API returns `{success, data}`

### Action Required:
1. Update UI screens to call new `LearningApiClient` methods (`getLearningMap()`, `getModesForSkill()`, etc.)
2. Remove or disable mock fallback (`useMockFallback: false`)
3. Fix legacy endpoint calls to use new `/api/learning/*` structure
4. Update response parsing to handle `{success, data}` wrapper consistently


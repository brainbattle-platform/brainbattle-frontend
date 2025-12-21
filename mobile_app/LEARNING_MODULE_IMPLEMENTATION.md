# Learning Module Implementation Report

## Tổng quan

Module Learning đã được hoàn thiện để đạt functional parity với Duolingo-style, giữ nguyên theme/branding của BrainBattle.

## Files đã tạo/sửa/xóa

### 1. Routes & Models

**Tạo mới:**
- `lib/features/learning/learning_routes.dart` - Single source of truth cho tất cả learning routes
- `lib/features/learning/domain/domain_model.dart` - Domain model
- `lib/features/learning/domain/exercise_model.dart` - ExerciseItem và ExerciseType enum
- `lib/features/learning/domain/lesson_summary_model.dart` - LessonSummary model
- `lib/features/learning/domain/attempt_result_model.dart` - AttemptResult model
- `lib/features/learning/data/mock/mock_data.dart` - Mock data cho demo end-to-end

**Sửa:**
- `lib/features/learning/domain/exercise_model.dart` - Xóa duplicate AttemptResult (đã tách ra file riêng)

### 2. Core Learning Loop Screens

**Tạo mới:**
- `lib/features/learning/ui/unit_detail_page.dart` - A2: UnitDetailPage
- `lib/features/learning/ui/lesson_start_page.dart` - A3: LessonStartPage
- `lib/features/learning/ui/exercise_player_page.dart` - A4: ExercisePlayerPage
- `lib/features/learning/ui/lesson_summary_page.dart` - A7: LessonSummaryPage
- `lib/features/learning/ui/unit_completion_page.dart` - A8: UnitCompletionPage

**Sửa:**
- `lib/features/learning/ui/lesson_detail_screen.dart` - Thêm button "Start Lesson"
- `lib/features/learning/ui/galaxy_map_screen.dart` - Thêm navigation đến UnitDetailPage

### 3. Exercise Templates

**Tạo mới:**
- `lib/features/learning/ui/widgets/exercise_templates/mcq_exercise.dart` - MCQ template
- `lib/features/learning/ui/widgets/exercise_templates/fill_blank_exercise.dart` - Fill blank template
- `lib/features/learning/ui/widgets/exercise_templates/matching_exercise.dart` - Matching template
- `lib/features/learning/ui/widgets/exercise_templates/listening_exercise.dart` - Listening template (stub)

### 4. Shared Widgets

**Tạo mới:**
- `lib/features/learning/ui/widgets/top_progress_header.dart` - Progress header với close button
- `lib/features/learning/ui/widgets/bottom_feedback_bar.dart` - Feedback bar (correct/wrong)
- `lib/features/learning/ui/widgets/explanation_drawer.dart` - Explanation bottom sheet

### 5. Practice & Review Screens

**Tạo mới:**
- `lib/features/learning/ui/practice_hub_page.dart` - A9: PracticeHubPage
- `lib/features/learning/ui/mistakes_review_page.dart` - A10: MistakesReviewPage
- `lib/features/learning/ui/review_queue_page.dart` - A11: ReviewQueuePage

### 6. Progress & Motivation Screens

**Tạo mới:**
- `lib/features/learning/ui/daily_goal_picker_page.dart` - B1: DailyGoalPickerPage
- `lib/features/learning/ui/streak_page.dart` - B2: StreakPage
- `lib/features/learning/ui/league_page.dart` - B3: LeaguePage
- `lib/features/learning/ui/achievements_page.dart` - B4: AchievementsPage
- `lib/features/learning/ui/learning_stats_page.dart` - B5: LearningStatsPage
- `lib/features/learning/ui/learning_settings_page.dart` - B6: LearningSettingsPage

### 7. Onboarding & Domain Screens

**Tạo mới:**
- `lib/features/learning/ui/domain_selector_bottom_sheet.dart` - E6: DomainSelectorBottomSheet
- `lib/features/learning/ui/curriculum_browser_page.dart` - E7: CurriculumBrowserPage
- `lib/features/learning/ui/placement_test_page.dart` - A12: PlacementTestPage (stub)

### 8. Navigation Updates

**Sửa:**
- `lib/app.dart` - Thêm tất cả learning routes vào MaterialApp

## Checklist Mapping

| ChecklistID | UI Name | Status | Evidence (class + file) | Notes |
|------------|---------|--------|-------------------------|-------|
| A1 | LearnPathMapPage | DONE | `GalaxyMapScreen` - `ui/galaxy_map_screen.dart` | Giữ nguyên, không tạo mới |
| A2 | UnitDetailPage | DONE | `UnitDetailPage` - `ui/unit_detail_page.dart` | Skills overview + lessons list + CTA Start |
| A3 | LessonStartPage | DONE | `LessonStartPage` - `ui/lesson_start_page.dart` | Preview (time, XP, streak protect) |
| A4 | ExercisePlayerPage | DONE | `ExercisePlayerPage` - `ui/exercise_player_page.dart` | Render theo 4 template types |
| A4.1 | MCQExercise | DONE | `MCQExercise` - `ui/widgets/exercise_templates/mcq_exercise.dart` | Multiple choice |
| A4.2 | FillBlankExercise | DONE | `FillBlankExercise` - `ui/widgets/exercise_templates/fill_blank_exercise.dart` | Fill in the blank |
| A4.3 | MatchingExercise | DONE | `MatchingExercise` - `ui/widgets/exercise_templates/matching_exercise.dart` | Matching pairs |
| A4.4 | ListeningExercise | STUB | `ListeningExercise` - `ui/widgets/exercise_templates/listening_exercise.dart` | UI stub, không có audio thật |
| A5 | Hint/Explanation drawer | DONE | `ExplanationDrawer` - `ui/widgets/explanation_drawer.dart` | Bottom sheet |
| A6 | Correct/Wrong feedback | DONE | `BottomFeedbackBar` - `ui/widgets/bottom_feedback_bar.dart` | Overlay với continue button |
| A7 | LessonSummaryPage | DONE | `LessonSummaryPage` - `ui/lesson_summary_page.dart` | XP, accuracy, time, mistakes |
| A8 | UnitCompletionPage | DONE | `UnitCompletionPage` - `ui/unit_completion_page.dart` | Completion + reward UI |
| A9 | PracticeHubPage | DONE | `PracticeHubPage` - `ui/practice_hub_page.dart` | Weak skills + quick practice |
| A10 | MistakesReviewPage | DONE | `MistakesReviewPage` - `ui/mistakes_review_page.dart` | List mistakes + redo |
| A11 | ReviewQueuePage | DONE | `ReviewQueuePage` - `ui/review_queue_page.dart` | Spaced repetition queue |
| A12 | PlacementTestPage | STUB | `PlacementTestPage` - `ui/placement_test_page.dart` | UI flow stub, không có scoring thật |
| B1 | DailyGoalPickerPage | DONE | `DailyGoalPickerPage` - `ui/daily_goal_picker_page.dart` | Pick minutes per day |
| B2 | StreakPage | DONE | `StreakPage` - `ui/streak_page.dart` | Calendar streak (stub calendar) |
| B3 | LeaguePage | DONE | `LeaguePage` - `ui/league_page.dart` | Weekly leaderboard (mock data) |
| B4 | AchievementsPage | DONE | `AchievementsPage` - `ui/achievements_page.dart` | Achievement list (mock) |
| B5 | LearningStatsPage | DONE | `LearningStatsPage` - `ui/learning_stats_page.dart` | Stats overview (mock) |
| B6 | LearningSettingsPage | DONE | `LearningSettingsPage` - `ui/learning_settings_page.dart` | Sound/speaking/reminders |
| E6 | DomainSelectorBottomSheet | DONE | `DomainSelectorBottomSheet` - `ui/domain_selector_bottom_sheet.dart` | Bottom sheet selector |
| E7 | CurriculumBrowserPage | DONE | `CurriculumBrowserPage` - `ui/curriculum_browser_page.dart` | Browse domains/units/skills |

## Stub/Placeholder Notes

1. **ListeningExercise (A4.4)**: UI stub, không có audio playback thật. Button play/pause chỉ là visual.
2. **PlacementTestPage (A12)**: UI flow stub, không có scoring algorithm thật. Chỉ hiển thị kết quả hardcoded.
3. **LeaguePage (B3)**: Sử dụng mock leaderboard data, chưa kết nối API.
4. **AchievementsPage (B4)**: Sử dụng mock achievements, chưa kết nối API.
5. **LearningStatsPage (B5)**: Sử dụng mock stats, chưa kết nối API.
6. **StreakPage (B2)**: Calendar là stub đơn giản, chưa có logic phức tạp.

## Navigation Flow

### Core Learning Loop
```
GalaxyMapScreen
  └─> Tap Unit -> UnitDetailPage
      └─> Tap Lesson -> LessonStartPage
          └─> Start Lesson -> ExercisePlayerPage
              └─> Complete -> LessonSummaryPage
                  └─> Continue -> Back to GalaxyMap
                  └─> Review Mistakes -> MistakesReviewPage
```

### Practice & Review
```
PracticeHubPage
  └─> Practice Skill -> LessonStartPage
  └─> Review Mistakes -> MistakesReviewPage
  └─> Spaced Repetition -> ReviewQueuePage
```

### Progress & Motivation
```
LearningSettingsPage
  └─> Daily Goal -> DailyGoalPickerPage
  └─> Streak -> StreakPage
  └─> League -> LeaguePage
  └─> Achievements -> AchievementsPage
  └─> Stats -> LearningStatsPage
```

### Domain & Curriculum
```
CurriculumBrowserPage
  └─> Domain Selector -> DomainSelectorBottomSheet
  └─> Tap Unit -> UnitDetailPage
```

## Theme & Styling

Tất cả screens sử dụng:
- `Theme.of(context)` để lấy theme hiện tại
- `BBColors` từ `core/theme/app_theme.dart` cho dark mode
- `ColorScheme` từ theme cho primary colors
- Không hardcode màu Duolingo, giữ nguyên branding BrainBattle

## Mock Data

Mock data được định nghĩa trong `data/mock/mock_data.dart`:
- 2 domains: English, Programming
- 2 units với 2 lessons mỗi unit
- Mỗi lesson có 5 exercises với đủ 4 template types
- Fallback về mock data khi API không available

## Compilation Status

✅ Tất cả files compile thành công
✅ Không có linter errors
✅ Routes đã được thêm vào `app.dart`
✅ Navigation flow hoàn chỉnh

## Next Steps (Optional)

1. Kết nối API thật cho exercises, lessons, stats
2. Implement audio playback cho ListeningExercise
3. Implement scoring algorithm cho PlacementTest
4. Kết nối real-time leaderboard cho League
5. Implement spaced repetition algorithm cho ReviewQueue
6. Thêm animations/transitions cho better UX


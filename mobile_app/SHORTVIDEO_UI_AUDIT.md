# ShortVideo Module UI Audit Report
## TikTok-Style Feature Comparison

**Date:** 2024  
**Scope:** `lib/features/shortvideo/**`  
**Objective:** Identify existing features, gaps, and stubs compared to TikTok

---

## A) ENTRY & NAVIGATION OVERVIEW

### Entry Point
- **File:** `lib/features/shortvideo/ui/shortvideo_shell.dart`
- **Class:** `ShortVideoShell`
- **Route:** `/shorts-shell` (defined in `app.dart`)
- **Description:** Main shell with horizontal PageView containing 4 tabs:
  - Index 0: BattleShell
  - Index 1: CommunityView
  - Index 2: **ShortVideoFeedPage** (main entry)
  - Index 3: GalaxyMapScreen

### Navigation Flow
```
ShortVideoShell (horizontal PageView)
  └─ ShortVideoFeedPage (vertical PageView)
      ├─ Tap Search → ShortsSearchPage
      ├─ Tap Avatar → (STUB: onAvatarTap: () {})
      ├─ Tap Comment → CommentSheet (bottom sheet)
      ├─ Tap Upload → ShortsRecorderPage
      └─ Bottom Bar → (STUB: most actions empty)
```

### Routes
- ✅ `/shorts-shell` → ShortVideoShell
- ❌ No dedicated routes for:
  - Profile page
  - Search results page
  - Hashtag page
  - Sound page
  - Video detail page

---

## B) SCREEN INVENTORY

| Screen | File | Chức năng | Trạng thái |
|--------|------|-----------|------------|
| **Feed** | `ui/shortvideo_feed_page.dart` | Vertical PageView feed, video player, actions | ✅ DONE |
| **Search** | `ui/shorts_search_page.dart` | Search input, suggestions, history | ⚠️ PARTIAL (no results page) |
| **Recorder** | `ui/shorts_recorder_page.dart` | Camera preview, record video | ⚠️ PARTIAL (no editor/preview) |
| **Comment Sheet** | `widgets/comment_sheet.dart` | Bottom sheet with comments list | ✅ DONE |
| **Profile** | N/A | User profile screen | ❌ MISSING |
| **Search Results** | N/A | Results tabs (Top/Videos/Users/Hashtags) | ❌ MISSING |
| **Hashtag Page** | N/A | Videos by hashtag | ❌ MISSING |
| **Sound Page** | N/A | Videos using same sound | ❌ MISSING |
| **Video Detail** | N/A | Full-screen video with metadata | ❌ MISSING (reuses feed) |
| **Upload/Editor** | N/A | Video editor, trim, effects | ❌ MISSING |
| **Notifications** | N/A | Inbox/notifications list | ❌ MISSING |
| **Settings** | N/A | Privacy, safety settings | ❌ MISSING |

---

## C) TIKTOK CHECKLIST COVERAGE

### A) FEED & PLAYER CORE

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **A1** | For You feed (vertical PageView) | ✅ DONE | `ShortVideoFeedPage` - `PageView.builder` with `scrollDirection: Axis.vertical` | Vertical swipe works |
| **A2** | Following feed (toggle tab) | ⚠️ PARTIAL | `TopTabs` widget shows tabs: `['LIVE', 'Khám phá', 'Bạn bè', 'Đã follow', 'Đề xuất']` | UI exists but no logic to switch feeds |
| **A3** | Auto-play/pause theo visibility | ✅ DONE | `ShortVideoPlayer` uses `VisibilityDetector` - `onVisibilityChanged` callback | Plays when visible > 60%, pauses otherwise |
| **A4** | Preload/next video caching | ❌ MISSING | No preloading logic | Only loads on scroll |
| **A5** | Loop / replay | ✅ DONE | `VideoPlayerController.setLooping(true)` in `ShortVideoPlayer` | Auto-loops |
| **A6** | Progress indicator + scrub | ✅ DONE | `Slider` widget in `ShortVideoFeedPage` (lines 255-274) | Shows progress, allows seeking |
| **A7** | Double-tap like animation | ✅ DONE | `ShortVideoPlayer._doubleTapLike()` - shows heart icon animation | Heart appears on double-tap |
| **A8** | Tap để pause/resume | ✅ DONE | `GestureDetector` with `onTap: _togglePlayPause` | Single tap pauses/resumes |
| **A9** | Mute/unmute + volume UX | ❌ MISSING | No mute button or volume control | Video always plays with audio |
| **A10** | Error state video (retry) | ❌ MISSING | No error handling UI | Video fails silently |

### B) VIDEO METADATA UI

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **B1** | Caption + "more/less" | ⚠️ PARTIAL | `ShortVideoFeedPage` shows caption (line 244) with `maxLines: 2, overflow: TextOverflow.ellipsis` | Shows caption but no "more/less" expand |
| **B2** | Hashtags clickable | ❌ MISSING | Caption is plain text, no hashtag parsing | No hashtag detection/links |
| **B3** | Music/sound info row (marquee) | ⚠️ STUB | Hardcoded `CaptionPill` with `source: 'CapCut', label: 'Thử mẫu này'` (line 237) | Not connected to real music data |
| **B4** | Location / tags | ❌ MISSING | No location data in model | Not implemented |

### C) ACTIONS (right-side action bar)

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **C1** | Like toggle + count (optimistic UI) | ✅ DONE | `RightRail` widget + `_toggleLike()` in feed - updates state immediately | Optimistic update works |
| **C2** | Comment open sheet | ✅ DONE | `_openComments()` opens `CommentSheet` as bottom sheet | Full comment UI |
| **C3** | Share sheet | ⚠️ STUB | `RightRail.onShare` callback exists but empty: `onShare: () {}` | No share dialog/sheet |
| **C4** | Save/Favorite | ⚠️ STUB | `RightRail` shows save icon + count, but `onSave: () {}` is empty | No save functionality |
| **C5** | Follow/unfollow creator | ❌ MISSING | `RightRail.onAvatarTap: () {}` is empty | No profile/follow flow |
| **C6** | Report/Not interested | ❌ MISSING | No report button or menu | Not implemented |

### D) COMMENTS EXPERIENCE

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **D1** | Bottom sheet comment list | ✅ DONE | `CommentSheet` widget with `showModalBottomSheet` | Full-screen bottom sheet |
| **D2** | Add comment input + send | ✅ DONE | `_InputBar` widget with `TextEditingController` + `_send()` method | Can add comments |
| **D3** | Reply thread UI (nested) | ✅ DONE | `CommentTile` with `replies` prop, nested rendering | Shows replies indented |
| **D4** | Like comment | ✅ DONE | `_toggleLike()` in `CommentSheet` | Optimistic update |
| **D5** | Sort (Top/New) | ✅ DONE | `PopupMenuButton` with `CommentSort.relevant/newest/oldest` | Sorting works |
| **D6** | Keyboard handling / safe area | ✅ DONE | `Padding(padding: EdgeInsets.only(bottom: insets))` in `_InputBar` | Handles keyboard |

### E) CREATOR / PROFILE FLOW

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **E1** | Tap avatar → Profile screen | ❌ MISSING | `RightRail.onAvatarTap: () {}` is empty | No navigation |
| **E2** | Profile header (avatar, follow, bio) | ❌ MISSING | No profile screen exists | Not implemented |
| **E3** | Grid videos / liked videos tabs | ❌ MISSING | No profile screen | Not implemented |
| **E4** | Follow button states | ❌ MISSING | No follow functionality | Not implemented |
| **E5** | Open video from profile grid → player | ❌ MISSING | No profile grid | Not implemented |

### F) SEARCH & DISCOVERY

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **F1** | Search page | ✅ DONE | `ShortsSearchPage` with search input | UI exists |
| **F2** | Search suggestions/trending | ✅ DONE | `ShortsSearchService.getSuggestions()` + `getRecommend()` | Suggestions work |
| **F3** | Results tabs (Top/Videos/Users/Hashtags) | ❌ MISSING | TODO comment: `// TODO: điều hướng đến trang kết quả tìm kiếm` (line 57) | No results page |
| **F4** | Hashtag page | ❌ MISSING | No hashtag page | Not implemented |
| **F5** | Sound page | ⚠️ STUB | Search page shows music item (line 149-156) but `onTap: () {}` is empty | UI stub only |

### G) UPLOAD / CREATE (UI)

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **G1** | Record screen (camera preview) | ✅ DONE | `ShortsRecorderPage` with `CameraController` | Full camera UI |
| **G2** | Upload from gallery | ⚠️ STUB | Gallery icon exists (line 317) but `onTap: () {}` is empty | No gallery picker |
| **G3** | Editor UI (trim, cover, text, stickers) | ❌ MISSING | TODO: `// TODO: điều hướng sang trang preview/chỉnh sửa` (line 155) | No editor |
| **G4** | Post screen (caption, hashtags, privacy) | ❌ MISSING | No post screen | Not implemented |
| **G5** | Drafts | ❌ MISSING | No drafts storage | Not implemented |

### H) INBOX / NOTIFICATIONS (UI)

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **H1** | Notifications list | ❌ MISSING | `BottomShortsBar` shows inbox icon with badge (line 42) but no page | Badge exists, no screen |
| **H2** | Messages entry | ❌ MISSING | No messages feature | Not implemented |
| **H3** | Activity badge counts | ⚠️ PARTIAL | `BottomShortsBar.inboxBadge: 8` is hardcoded | Badge UI exists, no real data |

### I) SETTINGS / SAFETY / MODERATION (UI)

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **I1** | Report flow | ❌ MISSING | No report button | Not implemented |
| **I2** | Block user | ❌ MISSING | No block functionality | Not implemented |
| **I3** | Privacy settings | ❌ MISSING | No settings screen | Not implemented |
| **I4** | Community guidelines | ❌ MISSING | No guidelines link | Not implemented |

### J) PERFORMANCE / QUALITY

| ID | Feature | Status | Evidence | Notes |
|----|---------|--------|----------|-------|
| **J1** | Player package | ✅ DONE | Uses `video_player` package | Standard Flutter video player |
| **J2** | Memory leaks: dispose controllers | ⚠️ PARTIAL | `ShortVideoPlayer.dispose()` disposes controller, but `_controllers` map in feed may leak | Controllers stored in map, need cleanup |
| **J3** | Smooth scroll: build cost | ⚠️ PARTIAL | `PageView.builder` is efficient, but each item builds full stack | Could optimize with `AutomaticKeepAliveClientMixin` |
| **J4** | Network image caching | ✅ DONE | Uses `cached_network_image` package in `ShortVideoPlayer` | Thumbnails cached |
| **J5** | Analytics events stubs | ❌ MISSING | No analytics tracking | Not implemented |

---

## D) GAP ANALYSIS

### Top 10 Missing Features (High UX Impact)

1. **Profile Screen** (E1-E5) - Cannot view creator profiles, follow users, or browse their videos
2. **Search Results Page** (F3) - Search exists but no results display
3. **Mute/Unmute Control** (A9) - No way to control audio
4. **Video Error Handling** (A10) - Videos fail silently
5. **Share Sheet** (C3) - Share button does nothing
6. **Hashtag Pages** (F4, B2) - Hashtags not clickable, no hashtag pages
7. **Follow/Unfollow** (C5, E4) - Core social feature missing
8. **Video Preloading** (A4) - No preload, causes loading delays
9. **Report/Block** (I1, I2) - No safety features
10. **Upload Editor** (G3, G4) - Cannot edit or post videos

### Quick Wins (2-3 days, UI + state only)

1. **Mute/Unmute Button** - Add toggle button in `RightRail`, control `VideoPlayerController.setVolume()`
2. **Share Sheet** - Create `ShareSheet` bottom sheet with options (Copy link, Share to...)
3. **Error State** - Add error widget in `ShortVideoPlayer` with retry button
4. **Caption Expand** - Add "more/less" button to caption in feed
5. **Hashtag Parsing** - Parse hashtags from caption, make clickable (navigate to stub page)

### Mid Priority (1-2 weeks)

1. **Profile Screen** - Create profile page with grid, follow button, bio
2. **Search Results** - Create results page with tabs (Top/Videos/Users)
3. **Follow System** - Add follow state, update UI optimistically
4. **Video Preloading** - Preload next 2-3 videos in background
5. **Save/Favorite** - Implement save functionality with local storage

### Hard / Backend Required

1. **Upload Editor** - Video trimming, effects, filters (requires native plugins)
2. **Notifications System** - Real-time notifications (requires backend)
3. **Report/Block** - Moderation system (requires backend)
4. **Analytics** - Event tracking (requires analytics service)
5. **Sound/Music Library** - Music selection and attribution (requires backend)

---

## E) CODE QUALITY & RISKS

### Performance Risks

1. **Controller Memory Leaks**
   - **File:** `shortvideo_feed_page.dart`
   - **Issue:** `_controllers` map stores controllers but may not dispose all when items removed
   - **Fix:** Implement cleanup in `dispose()` or when items removed

2. **No Video Preloading**
   - **File:** `shortvideo_feed_page.dart`
   - **Issue:** Videos only load when scrolled into view
   - **Impact:** Loading delays between videos
   - **Fix:** Preload next 2-3 videos in background

3. **Heavy Widget Tree Per Video**
   - **File:** `shortvideo_feed_page.dart` (lines 141-276)
   - **Issue:** Each video item builds full stack (player, overlays, gradients, sliders)
   - **Fix:** Use `AutomaticKeepAliveClientMixin` or optimize with `RepaintBoundary`

### Code Smells

1. **Hardcoded Data**
   - **File:** `shortvideo_feed_page.dart` (line 237)
   - **Issue:** `CaptionPill(source: 'CapCut', label: 'Thử mẫu này')` is hardcoded
   - **Fix:** Use `item.music` or `item.source` from model

2. **Empty Callbacks**
   - **Files:** Multiple (RightRail, BottomBar, SearchPage)
   - **Issue:** Many callbacks are empty `() {}`
   - **Fix:** Add TODO comments or implement stubs

3. **Mock Data in Service**
   - **File:** `comment_service.dart`
   - **Issue:** Uses in-memory `_db` map, not real API
   - **Note:** Acceptable for MVP, but should be documented

4. **Fake Thumbnails**
   - **File:** `shortvideo_model.dart` (line 46)
   - **Issue:** `'https://picsum.photos/seed/short$idStr/600/900'` is fake
   - **Note:** Should use real thumbnail from API

### Missing Error Handling

1. **Video Load Failures** - No retry UI
2. **Network Errors** - No error state in feed
3. **Camera Errors** - Basic error handling in recorder, but no retry flow
4. **API Failures** - Service throws exceptions, no fallback

---

## F) SUMMARY STATISTICS

### Coverage by Category

| Category | Done | Partial | Stub | Missing | Total |
|----------|------|---------|------|---------|-------|
| **Feed & Player** | 6 | 1 | 0 | 3 | 10 |
| **Metadata UI** | 0 | 2 | 1 | 1 | 4 |
| **Actions** | 2 | 0 | 3 | 1 | 6 |
| **Comments** | 6 | 0 | 0 | 0 | 6 |
| **Profile** | 0 | 0 | 0 | 5 | 5 |
| **Search** | 2 | 0 | 1 | 2 | 5 |
| **Upload** | 1 | 0 | 1 | 3 | 5 |
| **Notifications** | 0 | 1 | 0 | 2 | 3 |
| **Settings** | 0 | 0 | 0 | 4 | 4 |
| **Performance** | 2 | 2 | 0 | 1 | 5 |
| **TOTAL** | **19** | **6** | **6** | **22** | **53** |

### Overall Assessment

- **✅ Core Feed Experience:** 70% complete (vertical feed, player, comments work well)
- **⚠️ Social Features:** 20% complete (no profiles, follow, share)
- **❌ Content Creation:** 20% complete (recorder works, no editor/post)
- **❌ Discovery:** 40% complete (search UI exists, no results/hashtags)
- **⚠️ Polish:** 50% complete (missing error states, mute, preloading)

**Recommendation:** Focus on Quick Wins first (mute, share, error states), then Profile + Search Results for social engagement.

---

## G) FILES REFERENCE

### Core Files
- `lib/features/shortvideo/ui/shortvideo_shell.dart` - Main shell
- `lib/features/shortvideo/ui/shortvideo_feed_page.dart` - Feed page
- `lib/features/shortvideo/widgets/shortvideo_player.dart` - Video player
- `lib/features/shortvideo/widgets/right_rail.dart` - Action bar
- `lib/features/shortvideo/widgets/comment_sheet.dart` - Comments UI

### Data Layer
- `lib/features/shortvideo/data/shortvideo_model.dart` - Video model
- `lib/features/shortvideo/data/shortvideo_service.dart` - API service
- `lib/features/shortvideo/data/comment_model.dart` - Comment model
- `lib/features/shortvideo/data/comment_service.dart` - Comment service (mock)

### Additional Screens
- `lib/features/shortvideo/ui/shorts_search_page.dart` - Search
- `lib/features/shortvideo/ui/shorts_recorder_page.dart` - Camera recorder

---

**End of Audit Report**


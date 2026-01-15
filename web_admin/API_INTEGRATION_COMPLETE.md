# API Integration Complete - Dashboard & Learners

## ✅ Đã hoàn thành

### 1. API Client Layer

**Files created:**
- `src/lib/api/config.ts` - API configuration (base URL, admin key)
- `src/lib/api/client.ts` - HTTP client wrapper với axios, tự động thêm `x-admin-key` header
- `src/lib/api/admin-analytics.ts` - Admin Analytics API client với TypeScript types

**Dependencies added:**
- `axios: ^1.7.9` - HTTP client library

### 2. Dashboard Page Integration

**File updated:** `src/app/admin/page.tsx`

**APIs integrated:**
- ✅ `GET /api/admin/learning/summary` - Summary statistics
- ✅ `GET /api/admin/learning/timeseries/attempts` - Timeseries data
- ✅ `GET /api/admin/learning/top-lessons` - Top lessons by attempts

**Features:**
- Real-time data fetching khi range filter thay đổi (7d, 30d, 90d)
- Loading state và error handling
- Stats cards hiển thị:
  - Total Users
  - Active Learners (7d)
  - Total Attempts
  - Avg Accuracy
  - Attempts in range (với % change)
  - Completions in range (với % change)
- Trend chart hiển thị attempts và completions over time
- Top lessons list từ API

**Component updated:**
- `src/components/dashboard/TrendChartCard.tsx` - Hỗ trợ "attempts" và "completions" tabs

### 3. Learners Page Integration

**File updated:** `src/app/admin/users/learners/page.tsx`

**Status:**
- ✅ Đã import `adminAnalyticsApi`
- ✅ Đã setup structure để fetch learning stats
- ⚠️ **Note:** Learners page vẫn dùng mock data cho user list (vì cần API từ auth-service)
- ⚠️ **Note:** Learning stats API cần numeric `userId`, nhưng mock data dùng UUID. Cần mapping service hoặc API update để accept UUID.

**APIs available (ready to use):**
- `GET /api/admin/learning/users/:userId/overview` - User learning overview
- `GET /api/admin/learning/users/:userId/attempts` - User attempts history

---

## 🔧 Configuration

### Environment Variables

Tạo file `.env.local` trong `brainbattle-frontend/web_admin/`:

```env
# DOU Service (Learning/Admin APIs)
NEXT_PUBLIC_DOU_API_URL=http://localhost:4003/api

# Admin API Key
NEXT_PUBLIC_ADMIN_API_KEY=dev-admin
```

**Default values:**
- `NEXT_PUBLIC_DOU_API_URL`: `http://localhost:4003/api`
- `NEXT_PUBLIC_ADMIN_API_KEY`: `dev-admin`

---

## 📝 API Client Usage Examples

### Dashboard - Fetch Summary

```typescript
import { adminAnalyticsApi } from "@/lib/api/admin-analytics";

// Fetch summary with date range
const summary = await adminAnalyticsApi.getSummary("2024-01-01", "2024-01-31");
// Returns: { usersTotal, usersActive7d, attemptsTotal, attemptsInRange, completionsInRange, avgAccuracyInRange }
```

### Dashboard - Fetch Timeseries

```typescript
const timeseries = await adminAnalyticsApi.getTimeseries("2024-01-01", "2024-01-31");
// Returns: { points: [{ date, attempts, completions }] }
```

### Dashboard - Fetch Top Lessons

```typescript
const topLessons = await adminAnalyticsApi.getTopLessons("attempts", 10);
// Returns: { items: [{ lessonId, count }] }
```

### Learners - Fetch User Overview

```typescript
const overview = await adminAnalyticsApi.getUserOverview(123);
// Returns: { userId, hearts, streakDays, unitsCompleted, planetsCompleted, lastActiveAt }
```

### Learners - Fetch User Attempts

```typescript
const attempts = await adminAnalyticsApi.getUserAttempts(123, 50);
// Returns: { items: [{ attemptId, lessonId, mode, score, total, accuracy, durationSec, completedAt }] }
```

---

## 🚀 Next Steps

### Priority 1: Complete Learners Page Integration
1. **User List API:** Cần API từ `auth-service` để fetch user list (thay thế mock data)
2. **User ID Mapping:** Cần mapping service để convert UUID (từ auth-service) sang numeric ID (cho dou-service) hoặc update dou-service API để accept UUID
3. **Learning Stats Display:** Hiển thị learning stats trong LearnerRow hoặc detail modal

### Priority 2: Error Handling & UX
1. **Retry Logic:** Thêm retry logic cho failed API calls
2. **Loading States:** Cải thiện loading states cho từng component
3. **Error Messages:** User-friendly error messages

### Priority 3: Additional Features
1. **Caching:** Thêm caching cho API responses (React Query hoặc SWR)
2. **Real-time Updates:** WebSocket hoặc polling cho real-time data
3. **Export:** Export dashboard data to CSV/PDF

---

## 📊 API Response Examples

### Summary Response
```json
{
  "usersTotal": 150,
  "usersActive7d": 45,
  "attemptsTotal": 1250,
  "attemptsInRange": 320,
  "completionsInRange": 280,
  "avgAccuracyInRange": 0.82
}
```

### Timeseries Response
```json
{
  "points": [
    { "date": "2024-01-15", "attempts": 123, "completions": 45 },
    { "date": "2024-01-16", "attempts": 145, "completions": 52 }
  ]
}
```

### Top Lessons Response
```json
{
  "items": [
    { "lessonId": "lesson-1-1", "count": 245 },
    { "lessonId": "lesson-1-2", "count": 189 }
  ]
}
```

---

## 🐛 Known Issues

1. **User ID Mismatch:** 
   - Mock learners dùng UUID strings
   - Learning APIs cần numeric userId
   - **Solution:** Cần mapping service hoặc update API

2. **CORS:** 
   - Nếu gặp CORS errors, cần configure CORS trong `brainbattle-dou` service
   - Hoặc dùng Next.js API routes như proxy

3. **Authentication:**
   - Hiện tại dùng `x-admin-key` header
   - Trong production, nên dùng JWT hoặc session-based auth

---

## ✅ Testing Checklist

- [x] API client có thể fetch summary data
- [x] API client có thể fetch timeseries data
- [x] API client có thể fetch top lessons
- [x] Dashboard hiển thị real data từ API
- [x] Dashboard có loading state
- [x] Dashboard có error handling
- [x] Trend chart hiển thị attempts/completions
- [ ] Learners page có thể fetch user learning stats (blocked by user ID mapping)
- [ ] Error handling cho network failures
- [ ] Retry logic cho failed requests

---

## 📚 Documentation

- **API Client:** `src/lib/api/client.ts`
- **Analytics API:** `src/lib/api/admin-analytics.ts`
- **Dashboard Page:** `src/app/admin/page.tsx`
- **Learners Page:** `src/app/admin/users/learners/page.tsx`


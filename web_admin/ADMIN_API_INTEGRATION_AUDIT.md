# Admin API Integration Audit Report

## 📋 Tổng quan

Kiểm tra xem web_admin đã có UI sẵn sàng để nối với admin APIs của brainbattle-dou chưa.

---

## 🔍 1. Admin APIs có sẵn trong brainbattle-dou

### 1.1. Admin Analytics APIs (`/api/admin/learning/*`)

**Controller:** `AdminAnalyticsController`
**Base Path:** `/api/admin/learning`

**Endpoints:**
1. `GET /api/admin/learning/summary?from=YYYY-MM-DD&to=YYYY-MM-DD`
   - Response: `{ usersTotal, usersActive7d, attemptsTotal, attemptsInRange, completionsInRange, avgAccuracyInRange }`

2. `GET /api/admin/learning/timeseries/attempts?from&to`
   - Response: `{ points: [{ date, attempts, completions }] }`

3. `GET /api/admin/learning/top-lessons?metric=attempts|completions&limit=10`
   - Response: `{ items: [{ lessonId, count }] }`

4. `GET /api/admin/learning/users/:userId/overview`
   - Response: `{ userId, hearts, streakDays, unitsCompleted, planetsCompleted, lastActiveAt }`

5. `GET /api/admin/learning/users/:userId/attempts?limit=50`
   - Response: `{ items: [{ attemptId, lessonId, mode, score, total, accuracy, durationSec, completedAt }] }`

### 1.2. Admin Content APIs (`/api/admin/learning/*`)

**Controller:** `AdminContentController`
**Base Path:** `/api/admin/learning`
**Auth:** `x-admin-key` header required (AdminKeyGuard)

**Endpoints:**

**Units CRUD:**
- `POST /api/admin/learning/units` - Create unit
- `GET /api/admin/learning/units?publishedOnly=true` - List units
- `GET /api/admin/learning/units/:id` - Get unit by Prisma PK
- `GET /api/admin/learning/units/by-unitId/:unitId` - Get unit by business key
- `PUT /api/admin/learning/units/:id` - Update unit
- `DELETE /api/admin/learning/units/:id` - Delete unit
- `POST /api/admin/learning/units/:id/publish` - Publish unit
- `POST /api/admin/learning/units/:id/unpublish` - Unpublish unit
- `PUT /api/admin/learning/units/:id/order` - Update order
- `POST /api/admin/learning/units/reorder` - Bulk reorder

**Lessons CRUD:**
- `POST /api/admin/learning/lessons` - Create lesson
- `GET /api/admin/learning/lessons?unitId=&publishedOnly=` - List lessons
- `GET /api/admin/learning/lessons/:id` - Get lesson by Prisma PK
- `GET /api/admin/learning/lessons/by-lessonId/:lessonId` - Get lesson by business key
- `PUT /api/admin/learning/lessons/:id` - Update lesson
- `DELETE /api/admin/learning/lessons/:id` - Delete lesson
- `POST /api/admin/learning/lessons/:id/publish` - Publish lesson
- `POST /api/admin/learning/lessons/:id/unpublish` - Unpublish lesson
- `PUT /api/admin/learning/lessons/:id/order` - Update order
- `POST /api/admin/learning/lessons/reorder` - Bulk reorder

**Questions CRUD:**
- `POST /api/admin/learning/questions` - Create question
- `GET /api/admin/learning/questions?lessonId=&mode=&publishedOnly=` - List questions
- `GET /api/admin/learning/questions/:id` - Get question by Prisma PK
- `GET /api/admin/learning/questions/by-questionId/:questionId` - Get question by business key
- `PUT /api/admin/learning/questions/:id` - Update question
- `DELETE /api/admin/learning/questions/:id` - Delete question
- `POST /api/admin/learning/questions/:id/publish` - Publish question
- `POST /api/admin/learning/questions/:id/unpublish` - Unpublish question
- `PUT /api/admin/learning/questions/:id/order` - Update order
- `POST /api/admin/learning/questions/reorder` - Bulk reorder

---

## 🎨 2. UI Components có sẵn trong web_admin

### 2.1. Dashboard Page (`/admin`)
- ✅ **Location:** `src/app/admin/page.tsx`
- ✅ **Status:** Có UI, đang dùng **mock data**
- ✅ **Components:**
  - StatCard (stats metrics)
  - TrendChartCard (trend charts)
  - DonutChartCard (donut charts)
  - TopLessons (top lessons list)
  - NeedsAttention (lessons cần attention)
  - PendingTasks (pending tasks)
  - RealtimeFeed (realtime feed)
- ❌ **API Integration:** Chưa có, đang dùng mock từ `@/mock/dashboard.mock`

### 2.2. Learners Page (`/admin/users/learners`)
- ✅ **Location:** `src/app/admin/users/learners/page.tsx`
- ✅ **Status:** Có UI, đang dùng **mock data**
- ✅ **Components:**
  - LearnersHeader
  - LearnersStats
  - LearnersTable
  - LearnersToolbar
  - LearnerGrowthChartCard
  - LearnerStatusDonutCard
- ❌ **API Integration:** Chưa có, đang dùng mock từ `@/mock/learners.mock`

### 2.3. Creators Page (`/admin/users/creators`)
- ✅ **Location:** `src/app/admin/users/creators/page.tsx`
- ✅ **Status:** Có UI, đang dùng **mock data**
- ❌ **API Integration:** Chưa có, đang dùng mock từ `@/mock/creators.mock`

### 2.4. Violations Page (`/admin/users/violations`)
- ✅ **Location:** `src/app/admin/users/violations/page.tsx`
- ✅ **Status:** Có UI, đang dùng **mock data**
- ❌ **API Integration:** Chưa có, đang dùng mock từ `@/mock/violations.mock`

### 2.5. Learning Content Pages
- ❌ **Status:** Chưa có pages
- ✅ **Sidebar Menu:** Có menu items trong `sidebar.menu.ts`:
  - `/admin/learning/units` - AIM Lessons
  - `/admin/learning/questions` - Question Bank
  - `/admin/learning/import-export` - Import / Export
  - `/admin/learning/tags` - Metadata Tags
- ❌ **Pages:** Chưa tạo pages tương ứng

---

## 🔌 3. API Client / Service Layer

### 3.1. Hiện trạng
- ❌ **Không có API client** để gọi brainbattle-dou APIs
- ❌ **Không có HTTP client library** (axios, fetch wrapper) trong `package.json`
- ❌ **Không có service layer** để abstract API calls
- ✅ **Có mock data** trong `src/mock/` folder

### 3.2. Dependencies hiện tại
```json
{
  "dependencies": {
    "next": "15.4.6",
    "react": "19.1.0",
    "react-dom": "19.1.0",
    // ... UI libraries
    // ❌ Không có axios, fetch wrapper, hoặc API client
  }
}
```

---

## 📊 4. Mapping: API ↔ UI

### 4.1. Dashboard Analytics

| API Endpoint | UI Component | Status |
|-------------|--------------|--------|
| `GET /api/admin/learning/summary` | StatCard (Active Learners, etc.) | ❌ Chưa nối |
| `GET /api/admin/learning/timeseries/attempts` | TrendChartCard | ❌ Chưa nối |
| `GET /api/admin/learning/top-lessons` | TopLessons | ❌ Chưa nối |

### 4.2. Learners Management

| API Endpoint | UI Component | Status |
|-------------|--------------|--------|
| `GET /api/admin/learning/users/:userId/overview` | LearnerRow (detail view) | ❌ Chưa nối |
| `GET /api/admin/learning/users/:userId/attempts` | LearnerRow (attempts list) | ❌ Chưa nối |

### 4.3. Learning Content Management

| API Endpoint | UI Component | Status |
|-------------|--------------|--------|
| `GET /api/admin/learning/units` | Units List Page | ❌ Chưa có page |
| `POST /api/admin/learning/units` | Create Unit Form | ❌ Chưa có page |
| `GET /api/admin/learning/lessons` | Lessons List Page | ❌ Chưa có page |
| `GET /api/admin/learning/questions` | Questions List Page | ❌ Chưa có page |

---

## ✅ 5. Kết luận

### 5.1. UI Components
- ✅ **Có sẵn:** Dashboard, Learners, Creators, Violations pages với UI components đầy đủ
- ❌ **Thiếu:** Learning Content pages (Units, Lessons, Questions)

### 5.2. API Integration
- ❌ **Chưa có:** API client/service layer
- ❌ **Chưa có:** HTTP client library (axios hoặc fetch wrapper)
- ❌ **Chưa nối:** Tất cả pages đang dùng mock data

### 5.3. Cần làm để nối API

**Priority 1: Tạo API Client Layer**
1. Thêm `axios` hoặc dùng native `fetch`
2. Tạo `src/lib/api/client.ts` - HTTP client wrapper
3. Tạo `src/lib/api/admin-analytics.ts` - Analytics API client
4. Tạo `src/lib/api/admin-content.ts` - Content CRUD API client
5. Tạo `src/lib/api/config.ts` - API base URL config

**Priority 2: Tạo Learning Content Pages**
1. `src/app/admin/learning/units/page.tsx` - Units list & CRUD
2. `src/app/admin/learning/questions/page.tsx` - Questions list & CRUD
3. `src/app/admin/learning/import-export/page.tsx` - Import/Export UI
4. `src/app/admin/learning/tags/page.tsx` - Tags management

**Priority 3: Nối API vào existing pages**
1. Dashboard: Nối analytics APIs
2. Learners: Nối user overview/attempts APIs
3. Replace mock data với real API calls

---

## 📝 6. Recommendations

### 6.1. Immediate Actions
1. **Tạo API client layer** với axios hoặc fetch
2. **Tạo Learning Content pages** (Units, Lessons, Questions)
3. **Nối Dashboard** với analytics APIs
4. **Nối Learners page** với user APIs

### 6.2. API Base URL Configuration
```typescript
// src/lib/api/config.ts
export const API_BASE_URL = process.env.NEXT_PUBLIC_DOU_API_URL || 'http://localhost:4003/api';
export const ADMIN_API_KEY = process.env.NEXT_PUBLIC_ADMIN_API_KEY || 'dev-admin';
```

### 6.3. Example API Client Structure
```typescript
// src/lib/api/admin-analytics.ts
import { client } from './client';

export const adminAnalyticsApi = {
  getSummary: (from?: string, to?: string) => 
    client.get('/admin/learning/summary', { params: { from, to } }),
  
  getTimeseries: (from?: string, to?: string) =>
    client.get('/admin/learning/timeseries/attempts', { params: { from, to } }),
  
  getTopLessons: (metric: 'attempts' | 'completions', limit = 10) =>
    client.get('/admin/learning/top-lessons', { params: { metric, limit } }),
  
  getUserOverview: (userId: number) =>
    client.get(`/admin/learning/users/${userId}/overview`),
  
  getUserAttempts: (userId: number, limit = 50) =>
    client.get(`/admin/learning/users/${userId}/attempts`, { params: { limit } }),
};
```

---

## 🎯 Summary

| Component | UI Status | API Integration | Action Needed |
|-----------|-----------|-----------------|---------------|
| Dashboard | ✅ Có | ❌ Chưa | Tạo API client + nối analytics APIs |
| Learners | ✅ Có | ❌ Chưa | Tạo API client + nối user APIs |
| Creators | ✅ Có | ❌ Chưa | N/A (không có API tương ứng) |
| Violations | ✅ Có | ❌ Chưa | N/A (không có API tương ứng) |
| Learning Units | ❌ Chưa | ❌ Chưa | Tạo page + API client + nối content APIs |
| Learning Questions | ❌ Chưa | ❌ Chưa | Tạo page + API client + nối content APIs |

**Overall Status:** UI có sẵn nhưng chưa có API integration layer. Cần tạo API client và nối APIs vào existing pages.


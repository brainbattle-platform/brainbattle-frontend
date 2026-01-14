# Community Feature: Frontend ↔ Backend Integration Readiness Report

**Date**: January 14, 2026  
**Scope**: `brainbattle-frontend/mobile_app/lib/features/community` ↔ `brainbattle-clan` backend

---

## Executive Summary

The Flutter Community feature expects a **REST API** for threads, messages, clans, and presence. The backend provides two separate services:
1. **`brainbattle-clan/brainbattle-core`** (Clan management)
2. **`brainbattle-clan/brainbattle-messaging`** (Conversations & Messages)

**Verdict**: ⚠️ **Partially Compatible** — core endpoints exist but require significant alignment on naming, response structure, and missing endpoints.

---

## 1. Frontend API Expectations (from Flutter code)

### A) Required Endpoints

| FE Expected | Method | Path | Purpose |
|---|---|---|---|
| GET /community/threads | GET | `/community/threads` | List all threads (dm + clan) with filters/search |
| GET /community/threads/:id | GET | `/community/threads/{threadId}` | Get thread detail (members, isClan, avatar) |
| GET /community/threads/:id/messages | GET | `/community/threads/{threadId}/messages` | Load messages (cursor pagination) |
| POST /community/threads/:id/messages | POST | `/community/threads/{threadId}/messages` | Send text or attachment message |
| POST /community/threads/:id/read | POST | `/community/threads/{threadId}/read` | Mark thread as read |
| POST /community/clans | POST | `/community/clans` | Create clan (group) |
| GET /community/presence/active | GET | `/community/presence/active` | Load "Active now" users |

### B) Required Query Parameters

- **GET /community/threads**
  - `type`: `all` | `dm` | `clan` (filter by type)
  - `filter`: `unread` (show unread only)
  - `q`: search string (title/participant)
  - `sort`: `updatedAt_desc` (default)
  - `limit`: int (page size, default 20)
  - `cursor`: string (pagination)

- **GET /community/threads/:id/messages**
  - `limit`: int (default 50)
  - `cursor`: string (messageId for older messages)

- **GET /community/presence/active**
  - `limit`: int (default 20)
  - `cursor`: string

### C) Request Body Schemas

**Create Clan (POST /community/clans)**
```json
{
  "name": "BrainBattle Clan",
  "description": "Practice together",
  "avatarUrl": "https://cdn.example.com/clans/new.png",
  "memberIds": ["u2", "u3", "u4"]
}
```

**Send Message (POST /community/threads/:id/messages)**
```json
{
  "text": "Hi team!",
  "attachments": [
    {
      "type": "image",
      "url": "https://cdn.example.com/uploads/demo_photo.png",
      "thumbnailUrl": "https://cdn.example.com/uploads/demo_photo_thumb.jpg",
      "fileName": "demo_photo.png",
      "sizeBytes": 245013,
      "mimeType": "image/png"
    }
  ]
}
```

**Mark Read (POST /community/threads/:id/read)**
```json
{}
```

### D) Expected Response Format

**Success**
```json
{
  "data": { ... },
  "meta": { "nextCursor": "..." }
}
```

**Error**
```json
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Bad request",
    "details": { ... }
  }
}
```

### E) Auth Expectations

- **Authorization**: `Bearer <token>` header on all requests
- Token provider: `tokenProvider` in `CommunityApi` class

---

## 2. Backend Implementation (Actual)

### brainbattle-clan/brainbattle-core (Clan Management)

**Base**: `/v1/clans`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| POST | `/v1/clans` | Create clan | ✅ JwtGuard |
| GET | `/v1/clans/:clanId` | Get clan detail | ✅ JwtGuard |
| GET | `/v1/clans/:clanId/members` | List members | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/join` | Join clan (auto/request) | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/approve` | Approve join (leader only) | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/leave` | Leave clan | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/ban/:userId` | Ban member | ✅ JwtGuard |
| GET | `/v1/clans/:clanId/settings` | Get settings | ✅ JwtGuard |
| PATCH | `/v1/clans/:clanId/settings` | Update settings | ✅ JwtGuard |
| GET | `/v1/clans/:clanId/invite-links` | List invite links | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/invite-links` | Create invite link | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/invite-links/reset` | Reset invite links | ✅ JwtGuard |
| DELETE | `/v1/clans/:clanId/invite-links/:inviteId` | Revoke invite | ✅ JwtGuard |
| POST | `/v1/clans/join/invite` | Join via invite token | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/members/:userId/role` | Promote/demote | ✅ JwtGuard |
| POST | `/v1/clans/:clanId/transfer-leader/:newLeaderId` | Transfer leader | ✅ JwtGuard |

**Request/Response Format**:
- Returns raw Prisma entities (no `{ data, meta }` wrapper)
- Example response: `{ id: '...', name: '...', slug: '...', visibility: 'public', createdBy: '...' }`

**Create Clan DTO**:
```typescript
{
  name: string;          // min 3 chars
  visibility: 'public' | 'private';
}
```
❌ **Missing fields**: `description`, `avatarUrl`, `memberIds`

### brainbattle-clan/brainbattle-messaging (Conversations & Messages)

**Base**: `/v1`

| Method | Path | Purpose | Auth |
|---|---|---|---|
| GET | `/v1/conversations` | List my conversations | ✅ HttpJwtGuard |
| GET | `/v1/conversations/:id/messages` | Get messages (cursor) | ✅ HttpJwtGuard |
| POST | `/v1/conversations/:id/read` | Mark read | ✅ HttpJwtGuard |

**Additional (WebSocket)**:
- `conversation.join` — join conversation room
- `message.send` — send text message realtime

**Attachments**:
| Method | Path | Purpose |
|---|---|---|
| POST | `/v1/attachments/upload` | Upload file (multipart/form-data) |
| GET | `/v1/attachments/:id/url` | Get signed URL |
| DELETE | `/v1/attachments/:id` | Delete attachment |

**Request/Response Format**:
- Returns raw Prisma entities (no `{ data, meta }` wrapper)
- Example: `[{ id: '...', type: 'dm', clanId: null, updatedAt: '...' }]`

**Mark Read DTO**:
```typescript
{
  lastReadAt: string; // ISO8601
}
```

---

## 3. Compatibility Matrix

### ✅ Covered Endpoints

| FE Endpoint | BE Endpoint | Notes |
|---|---|---|
| POST /community/clans | POST /v1/clans | ⚠️ DTO mismatch (see below) |
| GET /community/threads | GET /v1/conversations | ⚠️ Path mismatch |
| GET /community/threads/:id/messages | GET /v1/conversations/:id/messages | ✅ Logic exists |
| POST /community/threads/:id/read | POST /v1/conversations/:id/read | ⚠️ DTO mismatch |

### ❌ Missing Endpoints

| FE Endpoint | Status | Fix |
|---|---|---|
| GET /community/threads/:id | ❌ Not found | Need to add `GET /v1/conversations/:id` with thread detail (members, isClan, avatarUrl) |
| POST /community/threads/:id/messages | ⚠️ WebSocket only | Add REST endpoint `POST /v1/conversations/:id/messages` |
| GET /community/presence/active | ❌ Not found | Create presence service + `/v1/presence/active` endpoint |

### ⚠️ Mismatched Endpoints

| FE Expects | BE Provides | Issue | Fix |
|---|---|---|---|
| **Path**: `/community/threads` | `/v1/conversations` | Inconsistent naming | ✅ Alias or update FE to use `/v1/conversations` |
| **Response**: `{ data: {...}, meta: {...} }` | Raw Prisma entity | Missing wrapper | ✅ Add response interceptor to wrap all responses |
| **Create Clan body**: `{ name, description, avatarUrl, memberIds[] }` | `{ name, visibility }` | FE sends more fields | ✅ Update `CreateClanDto` to accept `description`, `avatarUrl`, `memberIds`; store in `Clan.settings` JSON field |
| **Mark Read body**: `{}` | `{ lastReadAt: ISO8601 }` | BE requires timestamp | ⚠️ FE should send current timestamp OR BE can default to `new Date()` |
| **Pagination**: `cursor` (string) | `cursor` (string) | ✅ Compatible | None |
| **Message send**: inline attachments in body | Upload first, then reference `attachmentId` | Different flow | ⚠️ FE must upload attachment via `/v1/attachments/upload`, then send message with `attachmentId` |

---

## 4. Integration Readiness Checklist

### Endpoint: **List Threads (Conversations)**

**FE expects**:
- Method + Path: `GET /community/threads`
- Query: `type=all|dm|clan`, `filter=unread`, `q=search`, `limit`, `cursor`
- Response:
  ```json
  {
    "data": {
      "items": [
        {
          "id": "dm_1",
          "title": "Ngoc Han",
          "isClan": false,
          "memberCount": 2,
          "participants": [...],
          "lastMessagePreview": "Hello 👋",
          "lastMessageAt": "2026-01-14T11:20:00Z",
          "unreadCount": 1,
          "avatarUrl": null
        }
      ]
    },
    "meta": { "nextCursor": "..." }
  }
  ```

**BE provides**:
- Method + Path: `GET /v1/conversations`
- Response: `[{ id: '...', type: 'dm', clanId: null, updatedAt: '...' }]`

**Verdict**: ⚠️ **NEEDS CHANGE**

**Fix**:
1. ✅ Add response wrapper: `{ data: { items: [...] }, meta: { nextCursor } }`
2. ✅ Enrich response with:
   - `title`: For DM → fetch other user's name; For Clan → fetch clan name
   - `isClan`: boolean (from `type === 'clan'`)
   - `memberCount`: count `ConversationMember` where `leftAt IS NULL`
   - `participants`: array of `UserLite[]` (id, name, avatarUrl)
   - `lastMessagePreview`: fetch latest message text
   - `lastMessageAt`: fetch latest message `createdAt`
   - `unreadCount`: count messages after user's `ReadReceipt.lastReadAt`
   - `avatarUrl`: fetch from Clan or User
3. ✅ Add query params: `type`, `filter`, `q` (search), `cursor`

---

### Endpoint: **Get Thread Detail**

**FE expects**:
- Method + Path: `GET /community/threads/{threadId}`
- Response:
  ```json
  {
    "data": {
      "id": "clan_ielts",
      "title": "IELTS Warriors",
      "isClan": true,
      "memberCount": 128,
      "avatarUrl": "https://cdn.example.com/clans/ielts.png",
      "participants": [
        { "id": "me", "name": "You" },
        { "id": "u2", "name": "Han" }
      ],
      "lastMessagePreview": "Han: Tối nay battle IELTS nhé?",
      "lastMessageAt": "2026-01-14T11:15:00Z",
      "unreadCount": 3,
      "seenBySummary": "Seen by Linh, Vy, +2"
    },
    "meta": {}
  }
  ```

**BE provides**: ❌ **Not found**

**Verdict**: ❌ **MISSING**

**Fix**:
1. ✅ Create endpoint: `GET /v1/conversations/:id`
2. ✅ Validate user is member
3. ✅ Return enriched thread detail (same fields as list endpoint + `seenBySummary`)
4. ✅ Wrap response: `{ data: {...}, meta: {} }`

---

### Endpoint: **Get Messages**

**FE expects**:
- Method + Path: `GET /community/threads/{threadId}/messages`
- Query: `limit=50`, `cursor=messageId`
- Response:
  ```json
  {
    "data": {
      "items": [
        {
          "id": "m_1736853723456",
          "sender": { "id": "me", "name": "You", "avatarUrl": "..." },
          "text": "Hi team!",
          "attachments": [],
          "createdAt": "2026-01-14T11:22:03Z",
          "status": "sent",
          "readBy": ["me"]
        }
      ]
    },
    "meta": { "nextCursor": "m_1736853720000" }
  }
  ```

**BE provides**:
- Method + Path: `GET /v1/conversations/:id/messages`
- Query: `limit`, `cursor`
- Response: `[{ id: '...', conversationId: '...', senderId: '...', content: '...', kind: 'text', createdAt: '...', attachments: [...], receipts: [...] }]`

**Verdict**: ⚠️ **NEEDS CHANGE**

**Fix**:
1. ✅ Wrap response: `{ data: { items: [...] }, meta: { nextCursor: lastMessageId } }`
2. ✅ Enrich message:
   - `sender`: embed `UserLite` (id, name, avatarUrl) — currently returns only `senderId`
   - `text`: rename `content` → `text` (or alias)
   - `status`: derive from `receipts` (sent/delivered/read)
   - `readBy`: array of userIds from `MessageReceipt`
3. ✅ Return `nextCursor` as last message ID in batch

---

### Endpoint: **Send Message**

**FE expects**:
- Method + Path: `POST /community/threads/{threadId}/messages`
- Body:
  ```json
  {
    "text": "Hi team!",
    "attachments": [
      { "type": "image", "url": "...", "thumbnailUrl": "...", "fileName": "...", "sizeBytes": 245013, "mimeType": "..." }
    ]
  }
  ```
- Response:
  ```json
  {
    "data": {
      "id": "m_1736853723456",
      "sender": { "id": "me", "name": "You" },
      "text": "Hi team!",
      "attachments": [...],
      "createdAt": "2026-01-14T11:22:03Z",
      "status": "sent",
      "readBy": ["me"]
    },
    "meta": {}
  }
  ```

**BE provides**:
- WebSocket: `message.send` event
- ❌ No REST endpoint

**Verdict**: ❌ **MISSING REST ENDPOINT**

**Fix**:
1. ✅ Add REST endpoint: `POST /v1/conversations/:id/messages`
2. ✅ Body:
   ```json
   {
     "text": "Hi team!",
     "attachmentIds": ["att_1", "att_2"]  // Pre-uploaded via /v1/attachments/upload
   }
   ```
3. ✅ Response: same as WebSocket ack, wrapped in `{ data: {...}, meta: {} }`
4. ⚠️ **FE must change flow**:
   - Upload attachment first: `POST /v1/attachments/upload` (multipart)
   - Get `attachmentId` from response
   - Send message: `POST /v1/conversations/:id/messages` with `attachmentIds`

---

### Endpoint: **Mark Thread Read**

**FE expects**:
- Method + Path: `POST /community/threads/{threadId}/read`
- Body: `{}`
- Response: `{ "data": { "unreadCount": 0, "markedAt": "2026-01-14T11:23:00Z" }, "meta": {} }`

**BE provides**:
- Method + Path: `POST /v1/conversations/:id/read`
- Body: `{ "lastReadAt": "2026-01-14T11:23:00Z" }` (required)
- Response: `{ ok: true }`

**Verdict**: ⚠️ **NEEDS CHANGE**

**Fix**:
1. ✅ Update BE DTO: make `lastReadAt` optional; default to `new Date()` if not provided
2. ✅ Wrap response: `{ data: { unreadCount: 0, markedAt: lastReadAt }, meta: {} }`
3. OR: ✅ Update FE to send `{ lastReadAt: DateTime.now().toIso8601String() }`

---

### Endpoint: **Create Clan**

**FE expects**:
- Method + Path: `POST /community/clans`
- Body:
  ```json
  {
    "name": "BrainBattle Clan",
    "description": "Practice together",
    "avatarUrl": "https://cdn.example.com/clans/new.png",
    "memberIds": ["u2", "u3", "u4"]
  }
  ```
- Response:
  ```json
  {
    "data": {
      "clan": {
        "id": "clan_1736853660000",
        "name": "BrainBattle Clan",
        "description": "Practice together",
        "avatarUrl": "https://cdn.example.com/clans/new.png",
        "createdAt": "2026-01-14T11:21:12Z",
        "createdBy": { "id": "me", "name": "You" },
        "memberIds": ["me", "u2", "u3", "u4"],
        "memberCount": 4
      },
      "thread": {
        "id": "thread_8q2x",
        "title": "BrainBattle Clan",
        "isClan": true,
        "memberCount": 4,
        "participants": [...]
      }
    },
    "meta": {}
  }
  ```

**BE provides**:
- Method + Path: `POST /v1/clans`
- Body:
  ```json
  {
    "name": "BrainBattle Clan",
    "visibility": "public"
  }
  ```
- Response: `{ id: '...', name: '...', slug: '...', visibility: 'public', createdBy: '...' }`

**Verdict**: ⚠️ **NEEDS CHANGE**

**Fix**:
1. ✅ Update `CreateClanDto`:
   ```typescript
   {
     name: string;
     visibility: 'public' | 'private';
     description?: string;
     avatarUrl?: string;
     memberIds?: string[];  // Initial members to add
   }
   ```
2. ✅ Store `description` in `Clan.settings.description` (JSON field)
3. ✅ Store `avatarUrl` in `Clan.coverUrl` (or add `avatarUrl` column)
4. ✅ After clan creation, add all `memberIds` as members (role: 'member')
5. ✅ Create conversation automatically: call `ensureClanConversation(clanId, leaderId)` after clan creation
6. ✅ Return wrapped response:
   ```json
   {
     "data": {
       "clan": { ... },
       "thread": { id: conversationId, title: clanName, isClan: true, memberCount, participants }
     },
     "meta": {}
   }
   ```

---

### Endpoint: **Presence (Active Now)**

**FE expects**:
- Method + Path: `GET /community/presence/active`
- Query: `limit=20`, `cursor`
- Response:
  ```json
  {
    "data": {
      "items": [
        { "id": "u2", "name": "Han", "avatarUrl": "...", "isActiveNow": true, "lastActiveAt": "2026-01-14T11:21:00Z" }
      ]
    },
    "meta": { "nextCursor": "..." }
  }
  ```

**BE provides**: ❌ **Not found**

**Verdict**: ❌ **MISSING**

**Fix**:
1. ✅ Create presence service (Redis-based or DB-based)
2. ✅ Track user online status (via WebSocket `handleConnection`/`handleDisconnect`)
3. ✅ Store `lastActiveAt` timestamp
4. ✅ Add endpoint: `GET /v1/presence/active`
5. ✅ Return users active in last 5 minutes
6. ✅ Wrap response: `{ data: { items: [...] }, meta: { nextCursor } }`

---

## 5. Response Format Standardization

**Problem**: BE returns raw Prisma entities; FE expects `{ data, meta }` wrapper.

**Solution**: Add global response interceptor in NestJS.

**Implementation**:

```typescript
// common/response.interceptor.ts
import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

@Injectable()
export class ResponseWrapperInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map((data) => {
        // If already wrapped, return as-is
        if (data && typeof data === 'object' && ('data' in data || 'error' in data)) {
          return data;
        }
        // Wrap in { data, meta }
        return { data, meta: {} };
      }),
    );
  }
}

// app.module.ts
import { APP_INTERCEPTOR } from '@nestjs/core';

@Module({
  providers: [
    {
      provide: APP_INTERCEPTOR,
      useClass: ResponseWrapperInterceptor,
    },
  ],
})
export class AppModule {}
```

---

## 6. Priority Fixes

### P0 (Blocking — must fix before FE works)

| Priority | Task | Service | Estimate |
|---|---|---|---|
| **P0.1** | Add response wrapper interceptor | core + messaging | 30 min |
| **P0.2** | Add REST endpoint: `POST /v1/conversations/:id/messages` | messaging | 1 hour |
| **P0.3** | Enrich `GET /v1/conversations` response (title, isClan, memberCount, lastMessagePreview, unreadCount) | messaging | 2 hours |
| **P0.4** | Add endpoint: `GET /v1/conversations/:id` (thread detail) | messaging | 1 hour |
| **P0.5** | Update `CreateClanDto` to accept `description`, `avatarUrl`, `memberIds` | core | 1 hour |
| **P0.6** | Auto-create conversation when clan is created | core | 30 min |

**Total P0**: ~6 hours

### P1 (Important — improves UX)

| Priority | Task | Service | Estimate |
|---|---|---|---|
| **P1.1** | Add endpoint: `GET /v1/presence/active` (Active Now) | messaging or new service | 2 hours |
| **P1.2** | Make `lastReadAt` optional in `POST /v1/conversations/:id/read` | messaging | 15 min |
| **P1.3** | Enrich message response with `sender` (UserLite), `readBy[]` | messaging | 1 hour |
| **P1.4** | Add query params to `GET /v1/conversations`: `type`, `filter`, `q`, `cursor` | messaging | 1 hour |

**Total P1**: ~4 hours

### P2 (Nice-to-have)

| Priority | Task | Service | Estimate |
|---|---|---|---|
| **P2.1** | Add `seenBySummary` to thread detail (e.g., "Seen by Linh, Vy, +2") | messaging | 1 hour |
| **P2.2** | Normalize naming: `/community/threads` → `/v1/conversations` (or vice versa) | both | 30 min |
| **P2.3** | Add error code standardization (e.g., `FORBIDDEN` → `NOT_AUTHORIZED`) | both | 1 hour |

**Total P2**: ~2.5 hours

---

## 7. Summary

### Current State
- ✅ Core clan CRUD exists
- ✅ Messaging & conversations exist
- ⚠️ Response format mismatch (no wrapper)
- ❌ Missing REST endpoint for sending messages
- ❌ Missing thread detail endpoint
- ❌ Missing presence endpoint
- ⚠️ Create clan DTO incomplete

### Next Steps
1. **Backend Team**: Implement P0 fixes (~6 hours)
2. **Frontend Team**: Update API base path from `/community` → `/v1` (or backend adds alias)
3. **Frontend Team**: Update attachment flow: upload first, then reference `attachmentId` in message send
4. **Backend Team**: Add P1 fixes for better UX (~4 hours)
5. **Integration Test**: Use mock data to verify end-to-end flow

### API Base Path Recommendation
- **Option A**: Backend adds route alias: `/community/*` → `/v1/*` (no FE change)
- **Option B**: FE updates `CommunityApi.baseUrl` from `/community` → `/v1` (1 line change)

**Recommendation**: **Option B** (update FE) — cleaner, avoids duplicate routes.

---

## 8. Example FE Repository Update

**File**: `brainbattle-frontend/mobile_app/lib/features/community/data/community_repository.dart`

**Before**:
```dart
@override
Future<CursorPage<Post>> getFeed({String? cursor}) async {
  final res = await api.get('/community/feed', params: {'cursor': cursor ?? ''});
  final json = jsonDecode(res.body);
  final items = (json['items'] as List).map((e) => _mapPost(e)).toList();
  return CursorPage(items, nextCursor: json['nextCursor']);
}
```

**After**:
```dart
@override
Future<CursorPage<Post>> getFeed({String? cursor}) async {
  final res = await api.get('/v1/conversations', params: {'cursor': cursor ?? ''});
  final json = jsonDecode(res.body);
  final items = (json['data']['items'] as List).map((e) => _mapThread(e)).toList();
  return CursorPage(items, nextCursor: json['meta']['nextCursor']);
}
```

---

## 9. OpenAPI Specification (Proposed)

See separate file: `community_openapi.yaml` (to be generated from backend Swagger docs after fixes).

---

**End of Report**

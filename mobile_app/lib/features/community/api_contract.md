Data Needs

UserLite: minimal user used across UI
Fields: id (string, required), name (string, required), avatarUrl (string, optional), isActiveNow (bool, optional), lastActiveAt (ISO8601, optional)
Derived: activeStatus (FE from lastActiveAt, e.g., “Active 5m ago”); presence dot (FE from isActiveNow)
Relationships: member of Thread/Clan
Thread (chat thread; DM or Clan group)
Fields: id (string, required), title (string, required), isClan (bool, required), memberCount (int, required for group header), participants (UserLite[], required for info sheet), lastMessagePreview (string, required), lastMessageAt (ISO8601, required), unreadCount (int, required), avatarUrl (string, optional for group), seenBySummary (string, optional; used for “Seen by …” line in latest message)
Derived: timeLabel (FE from lastMessageAt, e.g., “5m”, “22:03”); activeStatus (FE from participants[*].lastActiveAt)
Relationships: has many Message; belongs to many UserLite
Message
Fields: id (string, required), sender (UserLite, required), text (string, optional), attachments (Attachment[], optional), createdAt (ISO8601, required), status (enum MessageStatus: sending/sent/delivered/read/failed — FE may map; BE can expose delivery/read), readBy (string[] userIds, optional)
Derived: status label (FE), seenByText (BE optional string or FE from readBy + participants)
Relationships: belongs to Thread; sender is UserLite
Attachment
Fields: id (string, required), type (enum: image/file/link/video), url (string, required), thumbnailUrl (string, optional), fileName (string, optional), sizeBytes (int, optional), mimeType (string, optional)
Clan (group chat metadata)
Fields: id (string, required), name (string, required), description (string, optional), avatarUrl (string, optional), createdAt (ISO8601, required), createdBy (UserLite, required), memberIds (string[], required)
Derived: memberCount (BE), threadId (string, required if chat thread is the clan’s main chat)
Relationships: has a main Thread; members are UserLite
Presence (Active Now)
Fields: users (UserLite[] with isActiveNow=true), nextCursor (string, optional)
Derived: none; FE composes the strip
Notes and sources:

Threads list + filters/search in mobile_app/lib/features/community/ui/chats/chats_page.dart
Thread page (messages, send, read, info sheet) in mobile_app/lib/features/community/ui/thread/thread_page.dart
New clan flow in mobile_app/lib/features/community/ui/clan/new_clan_page.dart
Models in mobile_app/lib/features/community/data/models.dart
Demo store behavior in mobile_app/lib/features/community/data/demo_store.dart
Routes in mobile_app/lib/features/community/community_routes.dart
App routes integration in mobile_app/lib/app.dart
UI Actions → API

Load chat threads list
GET /community/threads with filters: type=all|dm|clan, filter=unread, q=search, cursor pagination
Load thread details (members, isClan, avatar)
GET /community/threads/{threadId}
Load messages in a thread
GET /community/threads/{threadId}/messages with cursor pagination
Send a text message
POST /community/threads/{threadId}/messages
Send attachment (image/file/link/video)
POST /community/threads/{threadId}/messages with attachments[]
Mark thread as read (clear unread)
POST /community/threads/{threadId}/read
Create clan (group)
POST /community/clans
Presence: load “Active now” users
GET /community/presence/active
Optional (room discovery, used in battle queue UI card stubs):
Battle join is separate domain; skip in this contract.
Filters/sorting:

Threads: type, filter=unread, q (search), sort=updatedAt_desc (default), limit, cursor
Messages: cursor, limit (reverse chronological; FE uses reverse: true)
API Contract (REST)

Conventions
Auth: Bearer token required (unless specified)
Dates: ISO8601 strings
Pagination: cursor-based with meta.nextCursor
Success shape: { "data": ..., "meta": ... }
Error shape: { "error": { "code": "...", "message": "...", "details": ... } }
List Threads
Method + Path: GET /community/threads
Auth: Bearer required
Query:
type: all|dm|clan (default: all)
filter: unread (optional)
q: string (search by title/participant)
sort: updatedAt_desc|updatedAt_asc (default: updatedAt_desc)
limit: int (default 20, max 50)
cursor: string (optional)
Response
data.items: ThreadLite[]
ThreadLite: { id, title, isClan, memberCount, lastMessagePreview, lastMessageAt, unreadCount, avatarUrl?, participants?: UserLite[minimal] }
meta: { nextCursor }
Status: 200
Errors: 401, 400
Get Thread Detail
Method + Path: GET /community/threads/{threadId}
Auth: Bearer required
Response
data: {
id, title, isClan, memberCount, avatarUrl?,
participants: UserLite[],
lastMessagePreview, lastMessageAt, unreadCount,
seenBySummary? (string)
}
meta: {}
Status: 200
Errors: 404, 401
List Messages in Thread
Method + Path: GET /community/threads/{threadId}/messages
Auth: Bearer required
Query:
limit: int (default 50, max 100)
cursor: string (optional; returns messages before cursor by createdAt)
Response
data.items: Message[]
Message: {
id, sender: UserLite, text?, attachments?: Attachment[],
createdAt, status?: MessageStatus, readBy?: string[]
}
meta: { nextCursor }
Status: 200
Errors: 404, 401
Send Message
Method + Path: POST /community/threads/{threadId}/messages
Auth: Bearer required
Body:
{ text?: string, attachments?: AttachmentInput[] }
AttachmentInput: { type: image|file|link|video, url: string, thumbnailUrl?, fileName?, sizeBytes?, mimeType? }
Response
data: Message (server-assigned id, createdAt, status=sent/delivered)
meta: {}
Status: 201
Errors: 400, 413, 404, 401
Mark Thread Read
Method + Path: POST /community/threads/{threadId}/read
Auth: Bearer required
Body: {}
Response
data: { unreadCount: 0, markedAt: ISO8601 }
meta: {}
Status: 200
Errors: 404, 401
Create Clan (Group)
Method + Path: POST /community/clans
Auth: Bearer required
Body:
{
name: string,
description?: string,
avatarUrl?: string,
memberIds: string[] // must include at least 2 others; server implicitly adds current user
}
Response
data: {
clan: { id, name, description?, avatarUrl?, createdAt, createdBy: UserLite, memberIds, memberCount },
thread: { id, title, isClan: true, memberCount, participants: UserLite[] }
}
meta: {}
Status: 201
Errors: 400, 409, 401
Active Now (Presence)
Method + Path: GET /community/presence/active
Auth: Bearer required
Query:
limit: int (default 20, max 100)
cursor: string (optional)
Response
data.items: UserLite[] (with isActiveNow=true, lastActiveAt=now)
meta: { nextCursor }
Status: 200
Errors: 401
Types

UserLite: { id: string, name: string, avatarUrl?: string, isActiveNow?: boolean, lastActiveAt?: string }
Attachment: { id: string, type: string, url: string, thumbnailUrl?: string, fileName?: string, sizeBytes?: number, mimeType?: string }
MessageStatus: "sending" | "sent" | "delivered" | "read" | "failed"
Error shape (all endpoints)

{ "error": { "code": "INVALID_INPUT", "message": "Bad request", "details": { ... } } }
Examples

Feed of threads (2 items)

Request: GET /community/threads?type=all&limit=2
Response:
{
"data": {
"items": [
{
"id": "dm_1",
"title": "Ngoc Han",
"isClan": false,
"memberCount": 2,
"participants": [
{ "id": "me", "name": "You", "avatarUrl": "https://i.pravatar.cc/150?img=3" },
{ "id": "u2", "name": "Han", "avatarUrl": "https://i.pravatar.cc/150?img=5", "isActiveNow": true, "lastActiveAt": "2026-01-14T11:21:00Z" }
],
"lastMessagePreview": "Hello 👋",
"lastMessageAt": "2026-01-14T11:20:00Z",
"unreadCount": 1,
"avatarUrl": null
},
{
"id": "clan_ielts",
"title": "IELTS Warriors",
"isClan": true,
"memberCount": 128,
"participants": [],
"lastMessagePreview": "Han: Tối nay battle IELTS nhé?",
"lastMessageAt": "2026-01-14T11:15:00Z",
"unreadCount": 3,
"avatarUrl": "https://cdn.example.com/clans/ielts.png"
}
]
},
"meta": { "nextCursor": "eyJvZmZzZXQiOjJ9" }
}
Thread detail with comments/messages summary

Request: GET /community/threads/clan_ielts
Response:
{
"data": {
"id": "clan_ielts",
"title": "IELTS Warriors",
"isClan": true,
"memberCount": 128,
"avatarUrl": "https://cdn.example.com/clans/ielts.png",
"participants": [
{ "id": "me", "name": "You", "avatarUrl": "https://i.pravatar.cc/150?img=3" },
{ "id": "u2", "name": "Han" },
{ "id": "u3", "name": "Linh" }
],
"lastMessagePreview": "Han: Tối nay battle IELTS nhé?",
"lastMessageAt": "2026-01-14T11:15:00Z",
"unreadCount": 3,
"seenBySummary": "Seen by Linh, Vy, +2"
},
"meta": {}
}
Create clan request/response

Request:
{
"name": "BrainBattle Clan",
"description": "Practice together",
"avatarUrl": "https://cdn.example.com/clans/new.png",
"memberIds": ["u2", "u3", "u4"]
}
Response:
{
"data": {
"clan": {
"id": "clan_1736853660000",
"name": "BrainBattle Clan",
"description": "Practice together",
"avatarUrl": "https://cdn.example.com/clans/new.png",
"createdAt": "2026-01-14T11:21:12Z",
"createdBy": { "id": "me", "name": "You", "avatarUrl": "https://i.pravatar.cc/150?img=3" },
"memberIds": ["me", "u2", "u3", "u4"],
"memberCount": 4
},
"thread": {
"id": "thread_8q2x",
"title": "BrainBattle Clan",
"isClan": true,
"memberCount": 4,
"participants": [
{ "id": "me", "name": "You" },
{ "id": "u2", "name": "Han" },
{ "id": "u3", "name": "Linh" },
{ "id": "u4", "name": "Vy" }
]
}
},
"meta": {}
}
Post message (text) request/response

Request:
{
"text": "Hi team!"
}
Response:
{
"data": {
"id": "m_1736853723456",
"sender": { "id": "me", "name": "You", "avatarUrl": "https://i.pravatar.cc/150?img=3" },
"text": "Hi team!",
"attachments": [],
"createdAt": "2026-01-14T11:22:03Z",
"status": "sent",
"readBy": ["me"]
},
"meta": {}
}
Post message (attachment) request/response

Request:
{
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
Response:
{
"data": {
"id": "m_1736853726789",
"sender": { "id": "me", "name": "You" },
"attachments": [
{
"id": "att_1",
"type": "image",
"url": "https://cdn.example.com/uploads/demo_photo.png",
"thumbnailUrl": "https://cdn.example.com/uploads/demo_photo_thumb.jpg",
"fileName": "demo_photo.png",
"sizeBytes": 245013,
"mimeType": "image/png"
}
],
"createdAt": "2026-01-14T11:22:07Z",
"status": "sent",
"readBy": ["me"]
},
"meta": {}
}
Mark thread read

Request: POST /community/threads/{threadId}/read
Response:
{
"data": { "unreadCount": 0, "markedAt": "2026-01-14T11:23:00Z" },
"meta": {}
}

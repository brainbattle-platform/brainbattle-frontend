// lib/features/community/data/community_repository.dart
import 'dart:convert';
import 'community_api.dart';
import 'models.dart';

// Interface
abstract class ICommunityRepository {
  Future<CursorPage<Post>> getFeed({String? cursor});
  Future<CursorPage<Room>> getRooms({String? cursor});
  Future<CursorPage<ThreadLite>> getDmThreads({String? cursor});
  Future<CursorPage<Message>> getThreadMessages(String threadId, {String? cursor});
  Future<void> sendMessage(String threadId, String text);
}

// HTTP implementation (sẽ dùng khi BE xong)
class CommunityRepositoryHttp implements ICommunityRepository {
  final CommunityApi api;
  CommunityRepositoryHttp(this.api);

  @override
  Future<CursorPage<Post>> getFeed({String? cursor}) async {
    final res = await api.get('/community/feed', params: {'cursor': cursor ?? ''});
    final json = jsonDecode(res.body);
    final items = (json['items'] as List).map((e) => _mapPost(e)).toList();
    return CursorPage(items, nextCursor: json['nextCursor']);
  }

  @override
  Future<CursorPage<Room>> getRooms({String? cursor}) async {
    final res = await api.get('/community/rooms', params: {'cursor': cursor ?? ''});
    final json = jsonDecode(res.body);
    final items = (json['items'] as List).map((e) => _mapRoom(e)).toList();
    return CursorPage(items, nextCursor: json['nextCursor']);
  }

  @override
  Future<CursorPage<ThreadLite>> getDmThreads({String? cursor}) async {
    final res = await api.get('/community/dm/threads', params: {'cursor': cursor ?? ''});
    final json = jsonDecode(res.body);
    final items = (json['items'] as List).map((e) => _mapThreadLite(e)).toList();
    return CursorPage(items, nextCursor: json['nextCursor']);
  }

  @override
  Future<CursorPage<Message>> getThreadMessages(String threadId, {String? cursor}) async {
    final res = await api.get('/community/threads/$threadId/messages', params: {'cursor': cursor ?? ''});
    final json = jsonDecode(res.body);
    final items = (json['items'] as List).map((e) => _mapMessage(e)).toList();
    return CursorPage(items, nextCursor: json['nextCursor']);
  }

  @override
  Future<void> sendMessage(String threadId, String text) async {
    await api.post('/community/threads/$threadId/messages', body: {'text': text});
  }

  // --- mappers (tùy theo BE) ---
  UserLite _user(Map u) => UserLite(id: u['id'], name: u['name'], avatarUrl: u['avatar']);
  Post _mapPost(Map j) => Post(
    id: j['id'], author: _user(j['author']), text: j['text'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
    likes: j['likes'] ?? 0, comments: j['comments'] ?? 0,
  );
  Room _mapRoom(Map j) => Room(id: j['id'], name: j['name'], coverUrl: j['cover'], members: j['members'] ?? 0);
  ThreadLite _mapThreadLite(Map j) => ThreadLite(
    id: j['id'], title: j['title'], totalMessages: j['totalMessages'] ?? 0,
    updatedAt: DateTime.parse(j['updatedAt']),
  );
  Message _mapMessage(Map j) => Message(
    id: j['id'], sender: _user(j['sender']), text: j['text'] ?? '',
    createdAt: DateTime.parse(j['createdAt']),
  );
}

// Fake implementation (dùng NGAY bây giờ)
class CommunityRepositoryFake implements ICommunityRepository {
  final _me = const UserLite(id: 'me', name: 'You');

  @override
  Future<CursorPage<Post>> getFeed({String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    return CursorPage([
      Post(id: 'p1', author: _me, text: 'Welcome to BrainBattle! 🎯', createdAt: now, likes: 12, comments: 3),
      Post(id: 'p2', author: const UserLite(id:'u2', name:'Han'), text: 'Learning streak day #7 🔥', createdAt: now.subtract(const Duration(minutes: 5)), likes: 4, comments: 1),
    ], nextCursor: null);
  }

  @override
  Future<CursorPage<Room>> getRooms({String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return CursorPage([
      const Room(id: 'r1', name: 'IELTS Warriors', members: 128),
      const Room(id: 'r2', name: 'Grammar Ninjas', members: 42),
    ]);
  }

  @override
  Future<CursorPage<ThreadLite>> getDmThreads({String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return CursorPage([
      ThreadLite(id: 'dm_1', title: 'Ngoc Han', totalMessages: 23, updatedAt: now),
      ThreadLite(id: 'dm_2', title: 'Linh', totalMessages: 3, updatedAt: now.subtract(const Duration(hours: 2))),
    ]);
  }

  @override
  Future<CursorPage<Message>> getThreadMessages(String threadId, {String? cursor}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    return CursorPage([
      Message(id:'m1', sender:_me, text:'Hi there!', createdAt: now),
      Message(id:'m2', sender: const UserLite(id:'u2', name:'Han'), text:'Hello 👋', createdAt: now),
    ]);
  }

  @override
  Future<void> sendMessage(String threadId, String text) async {
    await Future.delayed(const Duration(milliseconds: 120));
  }
}

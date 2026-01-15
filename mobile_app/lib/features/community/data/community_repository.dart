// lib/features/community/data/community_repository.dart
import 'dart:convert';
import 'community_api.dart';
import 'models.dart';

// Interface
abstract class ICommunityRepository {
  Future<CursorPage<ThreadLiteApi>> getThreads({
    String type = 'all',
    String? filter,
    String? q,
    int limit = 20,
    String? cursor,
  });

  Future<ThreadDetail> getThreadDetail(String threadId);

  Future<CursorPage<Message>> getMessages(
    String threadId, {
    int limit = 50,
    String? cursor,
  });

  Future<Message> sendMessage(
    String threadId, {
    String? text,
    List<Map<String, dynamic>>? attachments,
  });

  /// Upload a single attachment file and return the normalized
  /// attachment JSON (compatible with Attachment.fromJson).
  Future<Attachment> uploadAttachment({
    required String filePath,
    required String type, // image | file
    String? fileName,
  });

  Future<void> markRead(String threadId);

  Future<CursorPage<UserLite>> getActiveUsers({int limit = 20, String? cursor});

  Future<CreateClanResponse> createClan({
    required String name,
    String? description,
    String? avatarUrl,
    required List<String> memberIds,
  });

  Future<String> ensureDmThread(String userId);
}

// HTTP implementation
class CommunityRepositoryHttp implements ICommunityRepository {
  final CommunityApi api;
  CommunityRepositoryHttp(this.api);

  @override
  Future<CursorPage<ThreadLiteApi>> getThreads({
    String type = 'all',
    String? filter,
    String? q,
    int limit = 20,
    String? cursor,
  }) async {
    final params = <String, String>{
      'type': type,
      'limit': limit.toString(),
      if (filter != null) 'filter': filter,
      if (q != null && q.isNotEmpty) 'q': q,
      if (cursor != null) 'cursor': cursor,
    };

    final res = await api.getMessaging('/community/threads', params: params);
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => ThreadLiteApi.fromJson(e as Map<String, dynamic>))
        .toList();
    final nextCursor = json['meta']['nextCursor'] as String?;
    return CursorPage(items, nextCursor: nextCursor);
  }

  @override
  Future<ThreadDetail> getThreadDetail(String threadId) async {
    final res = await api.getMessaging('/community/threads/$threadId');
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    return ThreadDetail.fromJson(data);
  }

  @override
  Future<CursorPage<Message>> getMessages(
    String threadId, {
    int limit = 50,
    String? cursor,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final res = await api.getMessaging(
      '/community/threads/$threadId/messages',
      params: params,
    );
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList();
    final nextCursor = json['meta']['nextCursor'] as String?;
    return CursorPage(items, nextCursor: nextCursor);
  }

  @override
  Future<Message> sendMessage(
    String threadId, {
    String? text,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final body = <String, dynamic>{
      if (text != null && text.isNotEmpty) 'text': text,
      if (attachments != null && attachments.isNotEmpty)
        'attachments': attachments,
    };

    if (body.isEmpty) {
      throw Exception('Message must contain text or attachments');
    }

    final res = await api.postMessaging(
      '/community/threads/$threadId/messages',
      body: body,
    );
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    return Message.fromJson(data);
  }

  @override
  Future<Attachment> uploadAttachment({
    required String filePath,
    required String type,
    String? fileName,
  }) async {
    final json = await api.uploadCommunityAttachment(filePath, fileName: fileName);
    final base = Attachment.fromJson(json);
    if (base.type == type) return base;

    // Normalize type to the requested one if backend returns a generic value.
    return Attachment(
      id: base.id,
      type: type,
      url: base.url,
      thumbnailUrl: base.thumbnailUrl,
      fileName: base.fileName,
      sizeBytes: base.sizeBytes,
      mimeType: base.mimeType,
      width: base.width,
      height: base.height,
    );
  }

  @override
  Future<void> markRead(String threadId) async {
    await api.postMessaging('/community/threads/$threadId/read', body: {});
  }

  @override
  Future<CursorPage<UserLite>> getActiveUsers({
    int limit = 20,
    String? cursor,
  }) async {
    final params = <String, String>{
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };

    final res = await api.getMessaging(
      '/community/presence/active',
      params: params,
    );
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => UserLite.fromJson(e as Map<String, dynamic>))
        .toList();
    final nextCursor = json['meta']['nextCursor'] as String?;
    return CursorPage(items, nextCursor: nextCursor);
  }

  @override
  Future<CreateClanResponse> createClan({
    required String name,
    String? description,
    String? avatarUrl,
    required List<String> memberIds,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatarUrl': avatarUrl,
      'memberIds': memberIds,
    };

    final res = await api.postCore('/community/clans', body: body);
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    return CreateClanResponse.fromJson(data);
  }

  @override
  Future<String> ensureDmThread(String userId) async {
    final res = await api.postMessaging(
      '/internal/conversations',
      body: {
        'type': 'dm',
        'participantIds': ['me', userId],
      },
    );
    final json = jsonDecode(res.body);
    final data = json['data'] as Map<String, dynamic>;
    return data['id'] as String;
  }
}

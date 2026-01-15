// lib/features/community/data/models.dart

/* ======= Common paging ======= */
class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;
  const CursorPage(this.items, {this.nextCursor});
}

/* ======= User lite (contract-compliant) ======= */
class UserLite {
  final String id;
  final String handle;
  final String displayName;
  final String? avatarUrl;
  final bool? isActiveNow;
  final DateTime? lastActiveAt;

  const UserLite({
    required this.id,
    required this.handle,
    required this.displayName,
    this.avatarUrl,
    this.isActiveNow,
    this.lastActiveAt,
  });

  // Legacy name getter for backward compatibility
  String get name => displayName;

  factory UserLite.fromJson(Map<String, dynamic> json) => UserLite(
    id: json['id'] as String,
    handle: json['handle'] as String,
    displayName: json['displayName'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    isActiveNow: json['isActiveNow'] as bool?,
    lastActiveAt: json['lastActiveAt'] != null
        ? DateTime.parse(json['lastActiveAt'] as String)
        : null,
  );
}

/* ======= Pulse post (nếu còn dùng) ======= */
class Post {
  final String id;
  final UserLite author;
  final String text;
  final DateTime createdAt;
  final int likes;
  final int comments;
  const Post({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });
}

/* ======= Rooms / Groups ======= */
class Room {
  final String id;
  final String name;
  final String? coverUrl;
  final int members;
  const Room({required this.id, required this.name, this.coverUrl, this.members = 0});
}

/* ======= Thread lite (list các cuộc hội thoại) ======= */
class ThreadLite {
  final String id;
  final String title;
  final int totalMessages;
  final DateTime updatedAt;
  const ThreadLite({
    required this.id,
    required this.title,
    required this.totalMessages,
    required this.updatedAt,
  });
}

/* ======= ThreadLiteApi (from backend /community/threads) ======= */
class ThreadLiteApi {
  final String id;
  final String title;
  final bool isClan;
  final String? clanId;
  final int memberCount;
  final String? avatarUrl;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;
  final List<UserLite> participants;

  const ThreadLiteApi({
    required this.id,
    required this.title,
    required this.isClan,
    this.clanId,
    required this.memberCount,
    this.avatarUrl,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.participants,
  });

  factory ThreadLiteApi.fromJson(Map<String, dynamic> json) => ThreadLiteApi(
    id: json['id'] as String,
    title: json['title'] as String,
    isClan: json['isClan'] as bool,
    clanId: json['clanId'] as String?,
    memberCount: json['memberCount'] as int,
    avatarUrl: json['avatarUrl'] as String?,
    lastMessagePreview: json['lastMessagePreview'] as String,
    lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    unreadCount: json['unreadCount'] as int,
    participants: (json['participants'] as List)
        .map((u) => UserLite.fromJson(u as Map<String, dynamic>))
        .toList(),
  );
}

/* ======= Thread Detail (extends ThreadLiteApi) ======= */
class ThreadDetail extends ThreadLiteApi {
  final String? seenBySummary;

  const ThreadDetail({
    required super.id,
    required super.title,
    required super.isClan,
    super.clanId,
    required super.memberCount,
    super.avatarUrl,
    required super.lastMessagePreview,
    required super.lastMessageAt,
    required super.unreadCount,
    required super.participants,
    this.seenBySummary,
  });

  factory ThreadDetail.fromJson(Map<String, dynamic> json) => ThreadDetail(
    id: json['id'] as String,
    title: json['title'] as String,
    isClan: json['isClan'] as bool,
    clanId: json['clanId'] as String?,
    memberCount: json['memberCount'] as int,
    avatarUrl: json['avatarUrl'] as String?,
    lastMessagePreview: json['lastMessagePreview'] as String,
    lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
    unreadCount: json['unreadCount'] as int,
    participants: (json['participants'] as List)
        .map((u) => UserLite.fromJson(u as Map<String, dynamic>))
        .toList(),
    seenBySummary: json['seenBySummary'] as String?,
  );
}

/* ======= Attachment ======= */
class Attachment {
  final String id;
  final String type; // image | file | link
  final String url;
  final String? thumbnailUrl;
  final String? fileName;
  final int? sizeBytes;
  final String? mimeType;
  final int? width;
  final int? height;

  const Attachment({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.fileName,
    this.sizeBytes,
    this.mimeType,
    this.width,
    this.height,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    id: json['id'] as String,
    type: json['type'] as String,
    url: json['url'] as String,
    thumbnailUrl: json['thumbnailUrl'] as String?,
    fileName: json['fileName'] as String?,
    sizeBytes: json['sizeBytes'] as int?,
    mimeType: json['mimeType'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
  );
}

/* ======= Message & Status ======= */
enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  final String id;
  final String conversationId;
  final UserLite? sender; // null for system messages
  final String text;
  final List<Attachment> attachments;
  final DateTime createdAt;
  final MessageStatus status;
  final List<UserLite>? readBy;

  const Message({
    required this.id,
    required this.conversationId,
    this.sender,
    required this.text,
    this.attachments = const [],
    required this.createdAt,
    this.status = MessageStatus.delivered,
    this.readBy,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    UserLite? sender,
    String? text,
    List<Attachment>? attachments,
    DateTime? createdAt,
    MessageStatus? status,
    List<UserLite>? readBy,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      readBy: readBy ?? this.readBy,
    );
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    MessageStatus statusFromString(String? s) {
      switch (s) {
        case 'read': return MessageStatus.read;
        case 'delivered': return MessageStatus.delivered;
        case 'sent': return MessageStatus.sent;
        default: return MessageStatus.delivered;
      }
    }

    return Message(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      sender: json['sender'] != null
          ? UserLite.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      text: json['text'] as String? ?? '',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: statusFromString(json['status'] as String?),
      readBy: json['readBy'] != null
          ? (json['readBy'] as List)
              .map((u) => UserLite.fromJson(u as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class ClanSummary {
  final String id;
  final String name;
  final int memberCount;
  final String lastMessage;
  final DateTime lastAt;
  ClanSummary(this.id, this.name, this.memberCount, this.lastMessage, this.lastAt);
}

/* ======= Clan (from POST /community/clans response) ======= */
class Clan {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? avatarUrl;
  final String visibility;
  final UserLite createdBy;
  final List<String> memberIds;
  final int memberCount;
  final DateTime createdAt;

  const Clan({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.avatarUrl,
    required this.visibility,
    required this.createdBy,
    required this.memberIds,
    required this.memberCount,
    required this.createdAt,
  });

  factory Clan.fromJson(Map<String, dynamic> json) => Clan(
    id: json['id'] as String,
    name: json['name'] as String,
    slug: json['slug'] as String,
    description: json['description'] as String?,
    avatarUrl: json['avatarUrl'] as String?,
    visibility: json['visibility'] as String,
    createdBy: UserLite.fromJson(json['createdBy'] as Map<String, dynamic>),
    memberIds: (json['memberIds'] as List).cast<String>(),
    memberCount: json['memberCount'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

/* ======= CreateClanResponse ======= */
class CreateClanResponse {
  final Clan clan;
  final ThreadLiteApi thread;

  const CreateClanResponse({required this.clan, required this.thread});

  factory CreateClanResponse.fromJson(Map<String, dynamic> json) =>
      CreateClanResponse(
        clan: Clan.fromJson(json['clan'] as Map<String, dynamic>),
        thread: ThreadLiteApi.fromJson(json['thread'] as Map<String, dynamic>),
      );
}

class ThreadPageArgs {
  final String threadId;
  const ThreadPageArgs({required this.threadId});
}

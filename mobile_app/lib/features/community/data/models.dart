// lib/features/community/data/models.dart

/* ======= Common paging ======= */
class CursorPage<T> {
  final List<T> items;
  final String? nextCursor;
  const CursorPage(this.items, {this.nextCursor});
}

/* ======= User lite ======= */
class UserLite {
  final String id;
  final String name;
  final String? avatarUrl;
  const UserLite({required this.id, required this.name, this.avatarUrl});
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

/* ======= Message & Status ======= */
enum MessageStatus { sending, sent, delivered, read, failed }

class Message {
  final String id;
  final UserLite sender;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.delivered,
  });

  Message copyWith({
    String? id,
    UserLite? sender,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
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

class ThreadPageArgs {
  final String threadId;
  const ThreadPageArgs({required this.threadId});
}

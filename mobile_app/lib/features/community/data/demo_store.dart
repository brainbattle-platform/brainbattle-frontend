import 'dart:async';
import 'package:flutter/foundation.dart';
import 'models.dart';

class DemoThread {
  final String id;
  final String title;
  final bool isClan;
  final List<UserLite> members;
  final List<Message> messages = [];
  int unread = 0;
  String? seenByText;

  DemoThread({
    required this.id,
    required this.title,
    required this.isClan,
    required this.members,
  });
}

class DemoCommunityStore extends ChangeNotifier {
  DemoCommunityStore._();
  static final DemoCommunityStore I = DemoCommunityStore._();

  final Map<String, DemoThread> _threads = {};

  List<DemoThread> get threads => _threads.values.toList();
  DemoThread thread(String id) => _threads[id]!;

  /* ================= INIT ================= */

  void ensureDemoDmThreads() {
    _ensureDm(id: 'demo_dm_david', name: 'David Lee', userId: 'david');
    _ensureDm(id: 'demo_dm_teacher', name: 'Teacher Anna', userId: 'teacher');
  }

  void _ensureDm({
    required String id,
    required String name,
    required String userId,
  }) {
    if (_threads.containsKey(id)) return;
    _threads[id] = DemoThread(
      id: id,
      title: name,
      isClan: false,
      members: [
        _me,
        UserLite(id: userId, name: name),
      ],
    );
  }

  void sendDm(String threadId, String text) {
    final t = thread(threadId);

    // user gửi
    t.messages.add(_msg(_me, text));
    notifyListeners();

    // ===== reply 1 sau 6s =====
    Future.delayed(const Duration(seconds: 6), () {
      if (!_threads.containsKey(threadId)) return;

      final reply1 = threadId == 'demo_dm_teacher'
          ? _msg(
              const UserLite(id: 'teacher', name: 'Teacher Anna'),
              'Hi, I saw your message.',
            )
          : _msg(
              const UserLite(id: 'david', name: 'David Lee'),
              'Hello world!',
            );

      t.messages.add(reply1);
      t.unread += 1;
      notifyListeners();
    });

    // ===== reply 2 sau 20s =====
    Future.delayed(const Duration(seconds: 20), () {
      if (!_threads.containsKey(threadId)) return;

      final reply2 = threadId == 'demo_dm_teacher'
          ? _msg(
              const UserLite(id: 'teacher', name: 'Teacher Anna'),
              'Let’s review your assignment together.',
            )
          : _msg(
              const UserLite(id: 'david', name: 'David Lee'),
              'Test clan tiếp?',
            );

      t.messages.add(reply2);
      t.unread += 1;
      notifyListeners();
    });
  }

  /* ================= CLAN ================= */

  String createClan({required String name, required List<UserLite> members}) {
    final id = 'clan_${DateTime.now().millisecondsSinceEpoch}';
    _threads[id] = DemoThread(
      id: id,
      title: name,
      isClan: true,
      members: members,
    );
    notifyListeners();
    return id;
  }

  void sendClanMessage({required String threadId, required Message message}) {
    final t = thread(threadId);
    t.messages.add(message);
    t.seenByText = null;
    notifyListeners();

    Future.delayed(const Duration(seconds: 2), () {
      if (!_threads.containsKey(threadId)) return;
      final names = t.members
          .where((m) => m.id != 'me')
          .map((e) => e.name)
          .toList();
      if (names.isNotEmpty) {
        t.seenByText =
            'Seen by ${names.take(2).join(', ')}${names.length > 2 ? ', +${names.length - 2}' : ''}';
        notifyListeners();
      }
    });
  }

  void simulateIncomingClanMessage(String threadId) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!_threads.containsKey(threadId)) return;
      final t = thread(threadId);
      final sender = t.members.firstWhere((m) => m.id != 'me');
      t.messages.add(_msg(sender, 'Vào battle đi.'));
      t.unread += 1;
      notifyListeners();
    });
  }

  void markRead(String threadId) {
    if (!_threads.containsKey(threadId)) return;
    _threads[threadId]!.unread = 0;
    notifyListeners();
  }

  /* ================= HELPERS ================= */

  static const _me = UserLite(
    id: 'me',
    name: 'You',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  );

  Message _msg(UserLite u, String text) => Message(
    id: DateTime.now().microsecondsSinceEpoch.toString(),
    sender: u,
    text: text,
    createdAt: DateTime.now(),
  );
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../data/models.dart';
import '../../data/demo_store.dart';
import '../../widgets/thread_header.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/card_container.dart';

class ThreadPage extends StatefulWidget {
  const ThreadPage({super.key});
  static const routeName = CommunityRoutes.thread;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  static const _accent = Color(0xFFF3B4C3);

  final _input = TextEditingController();
  final _scroll = ScrollController();

  late String _threadId;

  final _me = const UserLite(
    id: 'me',
    name: 'You',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as ThreadArgs;
    _threadId = args.threadId;

    // mark read ngay khi mở thread
    DemoCommunityStore.I.markRead(_threadId);
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();

    // 👉 demo: thoát clan thì giả lập incoming message sau 3s
    final thread = DemoCommunityStore.I.thread(_threadId);
    if (thread.isClan) {
      DemoCommunityStore.I.simulateIncomingClanMessage(_threadId);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: AnimatedBuilder(
        animation: DemoCommunityStore.I,
        builder: (_, __) {
          final thread = DemoCommunityStore.I.thread(_threadId);
          final messages = thread.messages;
          final isClan = thread.isClan;
          final memberCount = thread.members.length;

          // đảm bảo đang mở thread thì unread luôn = 0
          DemoCommunityStore.I.markRead(_threadId);

          final avatarUrl = isClan
              ? 'https://i.pravatar.cc/150?img=1'
              : 'https://i.pravatar.cc/150?img=5';

          return Column(
            children: [
              ThreadHeader(
                title: thread.title,
                subtitle: isClan ? '$memberCount members' : null,
                avatarUrl: avatarUrl,
                onBack: () => Navigator.pop(context),
                onInfo: () => _openInfoSheet(
                  title: thread.title,
                  avatarUrl: avatarUrl,
                  isClan: isClan,
                  memberCount: memberCount,
                  members: thread.members,
                ),
              ),

              // ===== Message list / empty =====
              Expanded(
                child: messages.isEmpty
                    ? _ThreadEmptyState(
                        title: thread.title,
                        isClan: isClan,
                        memberCount: memberCount,
                      )
                    : ListView.builder(
                        controller: _scroll,
                        reverse: true,
                        padding:
                            const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final m =
                              messages[messages.length - 1 - i];
                          final fromMe = m.sender.id == _me.id;

                          String? seenByText;
                          if (isClan && i == 0) {
                            seenByText = thread.seenByText;
                          }

                          return MessageBubble(
                            msg: m,
                            fromMe: fromMe,
                            showAvatar: !fromMe,
                            showSenderName: isClan && !fromMe,
                            seenByText: seenByText,
                          );
                        },
                      ),
              ),

              const Divider(height: 1, color: Colors.white10),

              // ===== Composer =====
              SafeArea(
                top: false,
                child: _ThreadComposer(
                  controller: _input,
                  accent: _accent,
                  onAttach: _openAttachSheet,
                  onSend: _sendText,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= SEND TEXT =================

  void _sendText() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    final thread = DemoCommunityStore.I.thread(_threadId);

    if (thread.isClan) {
      DemoCommunityStore.I.sendClanMessage(
        threadId: _threadId,
        message: Message(
          id: DateTime.now().toString(),
          sender: _me,
          text: text,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      DemoCommunityStore.I.sendDm(_threadId, text);
    }

    _input.clear();
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  // ================= ATTACH =================

  void _openAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A243B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AttachSheet(
        onSelect: _sendAttachment,
      ),
    );
  }

  void _sendAttachment(String type) {
    final thread = DemoCommunityStore.I.thread(_threadId);
    if (!thread.isClan) return; // chỉ demo attach cho clan

    final text = switch (type) {
      'Image' => '📷 Image: demo_photo.png',
      'File' => '📎 File: demo.pdf',
      'Link' => '🔗 https://example.com',
      'Camera' => '📸 Camera photo',
      _ => '[Attachment]',
    };

    DemoCommunityStore.I.sendClanMessage(
      threadId: _threadId,
      message: Message(
        id: DateTime.now().toString(),
        sender: _me,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ================= INFO SHEET =================

  void _openInfoSheet({
    required String title,
    required String avatarUrl,
    required bool isClan,
    required int memberCount,
    required List<UserLite> members,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A243B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ThreadInfoSheet(
        title: title,
        avatarUrl: avatarUrl,
        isClan: isClan,
        memberCount: memberCount,
        members: members,
      ),
    );
  }
}

/* ================= Composer ================= */

class _ThreadComposer extends StatelessWidget {
  final TextEditingController controller;
  final Color accent;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _ThreadComposer({
    required this.controller,
    required this.accent,
    required this.onAttach,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onAttach,
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white70),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle:
                    const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2F2941),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 6),
          FloatingActionButton.small(
            heroTag: 'send',
            backgroundColor: accent,
            foregroundColor: Colors.black,
            onPressed: onSend,
            child: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

/* ================= Attach Sheet ================= */

class _AttachSheet extends StatelessWidget {
  final ValueChanged<String> onSelect;

  const _AttachSheet({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Attach(
              icon: Icons.insert_photo_rounded,
              label: 'Image',
              onTap: () => onSelect('Image'),
            ),
            _Attach(
              icon: Icons.attach_file_rounded,
              label: 'File',
              onTap: () => onSelect('File'),
            ),
            _Attach(
              icon: Icons.link_rounded,
              label: 'Link',
              onTap: () => onSelect('Link'),
            ),
            _Attach(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: () => onSelect('Camera'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Attach extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Attach({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFF3B4C3),
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ================= Empty State ================= */

class _ThreadEmptyState extends StatelessWidget {
  final String title;
  final bool isClan;
  final int memberCount;

  const _ThreadEmptyState({
    required this.title,
    required this.isClan,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isClan ? '#$title' : title,
              style: text.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isClan
                  ? 'This is the $title clan with $memberCount members.'
                  : 'This is your chat with $title.',
              textAlign: TextAlign.center,
              style:
                  text.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= Info Sheet ================= */

class _ThreadInfoSheet extends StatelessWidget {
  final String title;
  final String avatarUrl;
  final bool isClan;
  final int memberCount;
  final List<UserLite> members;

  const _ThreadInfoSheet({
    required this.title,
    required this.avatarUrl,
    required this.isClan,
    required this.memberCount,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    text.titleMedium?.copyWith(color: Colors.white)),
            if (isClan) ...[
              const SizedBox(height: 12),
              CardContainer(
                child: Column(
                  children: members
                      .map(
                        (m) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                m.avatarUrl ?? ''),
                          ),
                          title: Text(
                            m.name,
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

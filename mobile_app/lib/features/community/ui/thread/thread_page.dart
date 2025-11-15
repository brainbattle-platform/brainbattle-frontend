import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../data/models.dart';
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

  // giả lập: mình là "me"
  final _me = const UserLite(
    id: 'me',
    name: 'You',
    avatarUrl: 'https://i.pravatar.cc/150?img=3',
  );

  // demo member list cho clan-info (sau này map từ BE)
  final List<ClanMember> _demoMembers = const [
    ClanMember(
      name: 'Han',
      role: 'Owner',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    ClanMember(
      name: 'Linh',
      role: 'Mod',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
    ),
    ClanMember(
      name: 'Diem',
      role: 'Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
    ),
    ClanMember(
      name: 'Vy',
      role: 'Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
    ),
    ClanMember(
      name: 'Quan',
      role: 'Member',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
    ),
  ];

  // TODO: thay bằng dữ liệu thật từ BE
  final List<Message> _messages = [
    Message(
      id: '1',
      sender: const UserLite(
        id: 'u2',
        name: 'Linh',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      text: 'Hey, welcome to BrainBattle! 🎯',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.delivered,
    ),
    Message(
      id: '2',
      sender: const UserLite(
        id: 'me',
        name: 'You',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      text: 'Hi Linh!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
      status: MessageStatus.read,
    ),
    Message(
      id: '3',
      sender: const UserLite(
        id: 'me',
        name: 'You',
        avatarUrl: 'https://i.pravatar.cc/150?img=3',
      ),
      text:
          'This is a long message to demonstrate max bubble width. It should wrap nicely and not touch the opposite screen edge.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      status: MessageStatus.delivered,
    ),
    Message(
      id: '4',
      sender: const UserLite(
        id: 'u2',
        name: 'Linh',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
      ),
      text: 'Alright!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 7)),
      status: MessageStatus.delivered,
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    String title = 'Thread';
    bool isClan = false;
    String avatarUrl = 'https://i.pravatar.cc/150?img=5';
    int memberCount = _demoMembers.length;

    // Hỗ trợ cả ThreadArgs lẫn Map
    if (args is ThreadArgs) {
      title = args.title ?? title;
      isClan = _guessIsClanFromTitle(title);
    } else if (args is Map) {
      title = (args['title'] as String?) ?? title;
      final argAvatar = args['avatarUrl'] as String?;
      if (argAvatar != null && argAvatar.isNotEmpty) {
        avatarUrl = argAvatar;
      }
      isClan = (args['isClan'] as bool?) ?? _guessIsClanFromTitle(title);
      memberCount = (args['memberCount'] as int?) ?? memberCount;
    }

    final subtitle =
        isClan ? '$memberCount members' : null; // mini subtitle dưới title

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: Column(
        children: [
          // Header dùng chung DM / Clan
          ThreadHeader(
            title: title,
            subtitle: subtitle,
            avatarUrl: avatarUrl,
            onBack: () => Navigator.pop(context),
            onInfo: () => _openInfoSheet(
              title: title,
              avatarUrl: avatarUrl,
              isClan: isClan,
              memberCount: memberCount,
            ),
          ),

          // ===== List message / empty-state =====
          Expanded(
            child: _messages.isEmpty
                ? _ThreadEmptyState(
                    title: title,
                    avatarUrl: avatarUrl,
                    isClan: isClan,
                    memberCount: memberCount,
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[_messages.length - 1 - i];
                      final fromMe = m.sender.id == _me.id;
                      final showAvatar = _shouldShowAvatar(i);

                      // demo: seen-by chỉ cho message mới nhất của clan
                      String? seenByText;
                      if (isClan && i == 0) {
                        seenByText = 'Seen by Linh, Vy, +2';
                      }

                      return MessageBubble(
                        msg: m,
                        fromMe: fromMe,
                        showAvatar: !fromMe && showAvatar,
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
      ),
    );
  }

  bool _guessIsClanFromTitle(String title) =>
      title.toLowerCase().contains('clan');

  // Ẩn avatar khi 2 tin liền kề cùng một người gửi
  bool _shouldShowAvatar(int builderIndex) {
    final reversedIndex = _messages.length - 1 - builderIndex;
    if (reversedIndex == 0) return true;
    final cur = _messages[reversedIndex];
    final prev = _messages[reversedIndex - 1];
    return cur.sender.id != prev.sender.id;
  }

  void _sendText() {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        Message(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          sender: _me,
          text: text,
          createdAt: DateTime.now(),
          status: MessageStatus.sending,
        ),
      );
    });
    _input.clear();

    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );

    // demo flow trạng thái
    Future.delayed(const Duration(milliseconds: 600), () {
      final idx =
          _messages.lastIndexWhere((m) => m.status == MessageStatus.sending);
      if (idx != -1) {
        setState(() {
          _messages[idx] =
              _messages[idx].copyWith(status: MessageStatus.sent);
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      final idx =
          _messages.lastIndexWhere((m) => m.status == MessageStatus.sent);
      if (idx != -1) {
        setState(() {
          _messages[idx] =
              _messages[idx].copyWith(status: MessageStatus.delivered);
        });
      }
    });
  }

  void _openAttachSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A243B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AttachSheet(),
    );
  }

  void _openInfoSheet({
    required String title,
    required String avatarUrl,
    required bool isClan,
    required int memberCount,
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
        members: isClan ? _demoMembers : const [],
      ),
    );
  }
}

/* ================== Composer ================== */

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
            tooltip: 'Attach',
            onPressed: onAttach,
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message…',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF2F2941),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

/* ================== Attach bottom sheet ================== */

class _AttachSheet extends StatelessWidget {
  const _AttachSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _Attach(icon: Icons.insert_photo_rounded, label: 'Image'),
            _Attach(icon: Icons.attach_file_rounded, label: 'File'),
            _Attach(icon: Icons.link_rounded, label: 'Link'),
            _Attach(icon: Icons.camera_alt_rounded, label: 'Camera'),
          ],
        ),
      ),
    );
  }
}

class _Attach extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Attach({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        // TODO: implement attach action
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFF3B4C3),
            child: Icon(Icons.add, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ================== Empty state khi chưa có message ================== */

class _ThreadEmptyState extends StatelessWidget {
  final String title;
  final String avatarUrl; // giữ lại nếu sau này cần, nhưng không hiển thị
  final bool isClan;
  final int memberCount;

  const _ThreadEmptyState({
    required this.title,
    required this.avatarUrl,
    required this.isClan,
    required this.memberCount,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final headerLine = isClan
        ? 'This is the $title clan with $memberCount members.'
        : 'This is your chat with $title.';

    const ctaLine =
        'Start a conversation and share your language-learning tips, '
        'questions, and experiences so everyone can improve together.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isClan ? '#$title' : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              headerLine,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              ctaLine,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================== Thread / Clan Info bottom sheet ================== */

class _ThreadInfoSheet extends StatelessWidget {
  final String title;
  final String avatarUrl;
  final bool isClan;
  final int memberCount;
  final List<ClanMember> members;

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
    final headerStatus =
        isClan ? '$memberCount members' : 'Active now'; // mini subtitle

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF443A5B),
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        headerStatus,
                        style: text.bodySmall?.copyWith(
                          color: isClan
                              ? Colors.white70
                              : Colors.greenAccent.shade200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            if (isClan) ...[
              Text(
                'Members',
                style: text.labelMedium?.copyWith(
                  color: Colors.white70,
                  letterSpacing: .3,
                ),
              ),
              const SizedBox(height: 8),

              CardContainer(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    for (final m in members)
                      _ClanMemberTile(member: m),
                  ],
                ),
              ),
            ],

            Text(
              'Quick actions',
              style: text.labelMedium?.copyWith(
                color: Colors.white70,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 8),

            CardContainer(
              margin: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  if (isClan)
                    _InfoActionTile(
                      icon: Icons.person_add_alt_1_rounded,
                      label: 'Invite more members',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: open invite flow
                      },
                    ),
                  if (!isClan)
                    _InfoActionTile(
                      icon: Icons.flag_outlined,
                      label: 'Block / Report',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: block/report
                      },
                    ),
                  _InfoActionTile(
                    icon: isClan
                        ? Icons.logout_rounded
                        : Icons.delete_outline_rounded,
                    label: isClan ? 'Leave clan' : 'Delete chat',
                    danger: true,
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: leave / clear
                    },
                  ),
                ],
              ),
            ),

            Text(
              'Media, files & links',
              style: text.labelMedium?.copyWith(
                color: Colors.white70,
                letterSpacing: .3,
              ),
            ),
            const SizedBox(height: 8),

            CardContainer(
              child: Text(
                'Coming soon. You will see photos, files and links shared in this thread here.',
                style: text.bodySmall?.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool danger;
  final VoidCallback onTap;

  const _InfoActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFFF6B81) : Colors.white;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

/* ================== Helper model cho clan-info (demo) ================== */

class ClanMember {
  final String name;
  final String role;
  final String avatarUrl;

  const ClanMember({
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}

class _ClanMemberTile extends StatelessWidget {
  final ClanMember member;

  const _ClanMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF443A5B),
        backgroundImage: NetworkImage(member.avatarUrl),
      ),
      title: Text(
        member.name,
        style: text.bodyMedium?.copyWith(color: Colors.white),
      ),
      subtitle: Text(
        member.role,
        style: text.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}

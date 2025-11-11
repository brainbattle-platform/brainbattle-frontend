import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../data/models.dart';
import '../../widgets/thread_header.dart';
import '../../widgets/message_bubble.dart';

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

  // giả lập: mình là 'me'
  final _me = const UserLite(id: 'me', name: 'You', avatarUrl: 'https://i.pravatar.cc/150?img=3');

  // seed messages để xem UI
  final List<Message> _messages = [
    Message(
      id: '1',
      sender: const UserLite(id: 'u2', name: 'Linh', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
      text: 'Hey, welcome to BrainBattle! 🎯',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.delivered,
    ),
    Message(
      id: '2',
      sender: const UserLite(id: 'me', name: 'You', avatarUrl: 'https://i.pravatar.cc/150?img=3'),
      text: 'Hi Linh!',
      createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
      status: MessageStatus.read,
    ),
    Message(
      id: '3',
      sender: const UserLite(id: 'me', name: 'You', avatarUrl: 'https://i.pravatar.cc/150?img=3'),
      text:
          'This is a long message to demonstrate max bubble width. It should wrap nicely and not touch the opposite screen edge.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      status: MessageStatus.delivered,
    ),
    Message(
      id: '4',
      sender: const UserLite(id: 'u2', name: 'Linh', avatarUrl: 'https://i.pravatar.cc/150?img=5'),
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
    // Lấy title an toàn từ arguments (có/không có ThreadArgs đều ok)
    final args = ModalRoute.of(context)?.settings.arguments;
    String title = 'Thread';
    if (args is Map) {
      title = (args['title'] as String?) ?? title;
    }

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: Column(
        children: [
          ThreadHeader(
            title: title,
            avatarUrl: 'https://i.pravatar.cc/150?img=5',
            onBack: () => Navigator.pop(context),
          ),

          // ===== Messages =====
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              itemCount: _messages.length,
              itemBuilder: (_, i) {
                final m = _messages[_messages.length - 1 - i];
                final fromMe = m.sender.id == _me.id;
                final showAvatar = _shouldShowAvatar(i);

                return MessageBubble(
                  msg: m,
                  fromMe: fromMe,
                  showAvatar: showAvatar,
                );
              },
            ),
          ),

          const Divider(height: 1, color: Colors.white10),

          // ===== Composer =====
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Attach',
                    onPressed: _openAttachSheet,
                    icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message…',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2F2941),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  FloatingActionButton.small(
                    heroTag: 'send',
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    onPressed: _sendText,
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Ẩn avatar khi 2 tin liền kề cùng 1 người gửi (giống WhatsApp)
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
    _scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);

    // mô phỏng tiến trình trạng thái
    Future.delayed(const Duration(milliseconds: 600), () {
      final idx = _messages.lastIndexWhere((m) => m.status == MessageStatus.sending);
      if (idx != -1) {
        setState(() => _messages[idx] = _messages[idx].copyWith(status: MessageStatus.sent));
      }
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      final idx = _messages.lastIndexWhere((m) => m.status == MessageStatus.sent);
      if (idx != -1) {
        setState(() => _messages[idx] = _messages[idx].copyWith(status: MessageStatus.delivered));
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
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _Attach(icon: Icons.insert_photo_rounded, label: 'Image', onTap: _noop),
              _Attach(icon: Icons.attach_file_rounded, label: 'File', onTap: _noop),
              _Attach(icon: Icons.link_rounded, label: 'Link', onTap: _noop),
              _Attach(icon: Icons.camera_alt_rounded, label: 'Camera', onTap: _noop),
            ],
          ),
        ),
      ),
    );
  }
}

void _noop() {}

/* ===== bottom sheet item ===== */
class _Attach extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Attach({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFF3B4C3),
            child: Icon(Icons.add, color: Colors.black), // icon placeholder
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

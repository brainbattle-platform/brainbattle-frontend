import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../data/models.dart';
import '../../data/community_di.dart';
import '../../widgets/thread_header.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/card_container.dart';
import '../_helpers/dm_display_helper.dart';
import '../_helpers/datetime_helper.dart';

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
  final _repo = communityRepo();
  final _imagePicker = ImagePicker();

  String? _threadId;
  ThreadDetail? _threadDetail;
  List<Message> _messages = [];
  bool _loading = false;
  String? _error;
  Timer? _pollingTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)!.settings.arguments as ThreadArgs?;
    if (args == null || args.threadId.isEmpty) {
      // Invalid navigation - show error instead of crashing
      if (_threadId == null) {
        setState(() {
          _error = 'Missing thread ID';
        });
      }
      return;
    }

    if (_threadId != args.threadId) {
      _threadId = args.threadId;
      _loadData();
      _startPolling();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _loadMessages(silent: true);
    });
  }

  Future<void> _loadData() async {
    if (_loading) return;
    final threadId = _threadId;
    if (threadId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _repo.getThreadDetail(threadId),
        _repo.getMessages(threadId, limit: 50),
      ]);

      if (mounted) {
        setState(() {
          _threadDetail = results[0] as ThreadDetail;
          final messages = (results[1] as CursorPage<Message>).items;
          // Sort ascending by createdAt (oldest first)
          messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _messages = messages;
          _loading = false;
        });
        
        // Mark as read after loading and update UI
        try {
          await _repo.markRead(threadId);
          // Mark all messages sent by current user as Seen (MVP: after markRead succeeds)
          if (mounted) {
            setState(() {
              _messages = _messages.map((m) {
                if (m.sender?.id == 'me') {
                  return m.copyWith(status: MessageStatus.read);
                }
                return m;
              }).toList();
            });
          }
        } catch (_) {
          // Silent fail for markRead
        }
        
        // Scroll to bottom on first load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(0);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final threadId = _threadId;
    if (threadId == null) return;

    try {
      final page = await _repo.getMessages(threadId, limit: 50);
      if (mounted) {
        setState(() {
          // Merge and deduplicate by ID
          final existingIds = _messages.map((m) => m.id).toSet();
          final existingMap = {for (var m in _messages) m.id: m};
          
          final newMessages = page.items.where((m) => !existingIds.contains(m.id)).toList();
          
          // Merge: keep existing messages (preserves seen status), add new ones
          _messages = [..._messages, ...newMessages];
          // Sort ascending by createdAt (oldest first)
          _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        });
      }
    } catch (_) {
      // Silent fail for polling
    }
  }

  @override
  Widget build(BuildContext context) {
    // Safety: if threadId is missing, show error screen
    if (_threadId == null) {
      return Scaffold(
        backgroundColor: BBColors.darkBg,
        appBar: AppBar(
          backgroundColor: BBColors.darkBg,
          title: const Text('Thread'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Thread not found',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_loading && _threadDetail == null) {
      return Scaffold(
        backgroundColor: BBColors.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _threadDetail == null) {
      return Scaffold(
        backgroundColor: BBColors.darkBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final thread = _threadDetail!;
    final isClan = thread.isClan;
    final memberCount = thread.memberCount;

    // Get display name and avatar based on thread type
    final (displayName, dmAvatarUrl) = isClan
        ? (thread.title, thread.avatarUrl)
        : getDMCounterpartInfo(thread);

    final avatarUrl = dmAvatarUrl ?? 
        (isClan
            ? 'https://i.pravatar.cc/150?img=1'
            : 'https://i.pravatar.cc/150?img=5');

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: Column(
        children: [
          ThreadHeader(
            title: displayName,
            subtitle: isClan ? '$memberCount members' : null,
            avatarUrl: avatarUrl,
            onBack: () => Navigator.pop(context),
            onInfo: () => _openInfoSheet(
              title: displayName,
              avatarUrl: avatarUrl,
              isClan: isClan,
              memberCount: memberCount,
              members: thread.participants,
              messages: _messages,
            ),
          ),

          // ===== Message list / empty =====
          Expanded(
            child: _messages.isEmpty
                ? _ThreadEmptyState(
                    title: displayName,
                    isClan: isClan,
                    memberCount: memberCount,
                  )
                : ListView.builder(
                    controller: _scroll,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      // reverse:true displays from bottom, so access in reverse order
                      final m = _messages[_messages.length - 1 - i];
                      final fromMe = m.sender?.id == 'me';

                      String? seenByText;
                      if (isClan && i == 0 && thread.seenBySummary != null) {
                        seenByText = thread.seenBySummary;
                      }

                      final displayMsg = m.sender == null
                          ? m.copyWith(
                              sender: const UserLite(
                                id: 'system',
                                handle: 'system',
                                displayName: 'System',
                              ),
                            )
                          : m;

                      return MessageBubble(
                        msg: displayMsg,
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
      ),
    );
  }

  // ================= SEND TEXT =================

  Future<void> _sendText() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    final threadId = _threadId;
    if (threadId == null) return;

    _input.clear();

    try {
      await _repo.sendMessage(threadId, text: text);
      await _loadMessages(); // Refresh messages
      // Scroll to bottom after sending
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    switch (type) {
      case 'Image':
        _pickAndSendImages();
        break;
      case 'Camera':
        _captureAndSendImage();
        break;
      case 'File':
        _pickAndSendFiles();
        break;
      case 'Link':
        _promptAndSendLink();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$type attachment not supported')),
        );
    }
  }

  Future<void> _pickAndSendImages() async {
    final threadId = _threadId;
    if (threadId == null) return;

    try {
      final picked = await _imagePicker.pickMultiImage(
        maxWidth: 2048,
        imageQuality: 85,
      );

      if (picked.isEmpty) return;

      var files = picked;
      if (files.length > 10) {
        files = files.take(10).toList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can send up to 10 images at once'),
            ),
          );
        }
      }

      final attachments = <Map<String, dynamic>>[];
      for (final x in files) {
        if (x.path.isEmpty) continue;
        final fileName = x.name.isNotEmpty ? x.name : p.basename(x.path);
        final uploaded = await _repo.uploadAttachment(
          filePath: x.path,
          type: 'image',
          fileName: fileName,
        );
        attachments.add(_toAttachmentInput(uploaded));
      }

      if (attachments.isEmpty) return;

      final text = _input.text.trim();
      _input.clear();

      await _repo.sendMessage(
        threadId,
        text: text.isEmpty ? null : text,
        attachments: attachments,
      );
      await _loadMessages();
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending images: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _captureAndSendImage() async {
    final threadId = _threadId;
    if (threadId == null) return;

    try {
      final x = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        imageQuality: 85,
      );
      if (x == null || x.path.isEmpty) return;

      final fileName = x.name.isNotEmpty ? x.name : p.basename(x.path);
      final uploaded = await _repo.uploadAttachment(
        filePath: x.path,
        type: 'image',
        fileName: fileName,
      );
      final attachments = <Map<String, dynamic>>[_toAttachmentInput(uploaded)];

      final text = _input.text.trim();
      _input.clear();

      await _repo.sendMessage(
        threadId,
        text: text.isEmpty ? null : text,
        attachments: attachments,
      );
      await _loadMessages();
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending camera photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndSendFiles() async {
    final threadId = _threadId;
    if (threadId == null) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      var files = result.files;
      if (files.length > 10) {
        files = files.take(10).toList();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can send up to 10 files at once'),
            ),
          );
        }
      }

      final attachments = <Map<String, dynamic>>[];
      for (final f in files) {
        final path = f.path;
        if (path == null || path.isEmpty) continue;
        final fileName = f.name.isNotEmpty ? f.name : p.basename(path);
        final uploaded = await _repo.uploadAttachment(
          filePath: path,
          type: 'file',
          fileName: fileName,
        );
        attachments.add(_toAttachmentInput(uploaded));
      }

      if (attachments.isEmpty) return;

      final text = _input.text.trim();
      _input.clear();

      await _repo.sendMessage(
        threadId,
        text: text.isEmpty ? null : text,
        attachments: attachments,
      );
      await _loadMessages();
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _promptAndSendLink() async {
    final threadId = _threadId;
    if (threadId == null) return;

    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A243B),
          title: const Text('Add link', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'https://example.com',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || !uri.isAbsolute) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid URL')),
        );
      }
      return;
    }

    try {
      final attachments = <Map<String, dynamic>>[
        {
          'type': 'link',
          'url': url,
        },
      ];

      final text = _input.text.trim();
      _input.clear();

      await _repo.sendMessage(
        threadId,
        text: text.isEmpty ? null : text,
        attachments: attachments,
      );
      await _loadMessages();
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _toAttachmentInput(Attachment att) {
    return <String, dynamic>{
      'type': att.type,
      'url': att.url,
      if (att.thumbnailUrl != null) 'thumbnailUrl': att.thumbnailUrl,
      if (att.fileName != null) 'fileName': att.fileName,
      if (att.sizeBytes != null) 'sizeBytes': att.sizeBytes,
      if (att.mimeType != null) 'mimeType': att.mimeType,
      if (att.width != null) 'width': att.width,
      if (att.height != null) 'height': att.height,
    };
  }

  // ================= INFO SHEET =================

  void _openInfoSheet({
    required String title,
    required String avatarUrl,
    required bool isClan,
    required int memberCount,
    required List<UserLite> members,
    required List<Message> messages,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A243B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ThreadInfoSheet(
        title: title,
        avatarUrl: avatarUrl,
        isClan: isClan,
        memberCount: memberCount,
        members: members,
        messages: messages,
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

class _ThreadInfoSheet extends StatefulWidget {
  final String title;
  final String avatarUrl;
  final bool isClan;
  final int memberCount;
  final List<UserLite> members;
  final List<Message> messages;

  const _ThreadInfoSheet({
    required this.title,
    required this.avatarUrl,
    required this.isClan,
    required this.memberCount,
    required this.members,
    required this.messages,
  });

  @override
  State<_ThreadInfoSheet> createState() => _ThreadInfoSheetState();
}

class _ThreadInfoSheetState extends State<_ThreadInfoSheet> {
  String _selectedTab = 'info'; // 'info' or 'media'

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
            // ===== Header with avatar =====
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF443A5B),
              backgroundImage: NetworkImage(widget.avatarUrl),
              child: widget.avatarUrl.isEmpty
                  ? const Icon(Icons.people, color: Colors.white70, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(widget.title,
                style: text.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 6),
            Text('${widget.memberCount} member${widget.memberCount != 1 ? 's' : ''}',
                style: text.bodySmall?.copyWith(color: Colors.white54)),

            const SizedBox(height: 20),

            // ===== Tab selector (Info / Media) =====
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2F2941),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 'info'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'info'
                              ? const Color(0xFFF3B4C3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Info',
                          textAlign: TextAlign.center,
                          style: text.labelMedium?.copyWith(
                            color: _selectedTab == 'info'
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = 'media'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTab == 'media'
                              ? const Color(0xFFF3B4C3)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Media',
                          textAlign: TextAlign.center,
                          style: text.labelMedium?.copyWith(
                            color: _selectedTab == 'media'
                                ? Colors.black
                                : Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== Content based on tab =====
            if (_selectedTab == 'info') ...[
              if (widget.isClan)
                _buildClanInfo()
              else
                _buildDMInfo(),
            ] else ...[
              _buildMediaTab(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDMInfo() {
    final text = Theme.of(context).textTheme;
    final counterpart = widget.members.isNotEmpty ? widget.members.first : null;

    if (counterpart == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'User info not available',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CardContainer(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 20,
                  backgroundImage: counterpart.avatarUrl != null
                      ? NetworkImage(counterpart.avatarUrl!)
                      : null,
                  backgroundColor: const Color(0xFF443A5B),
                  child: counterpart.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white70)
                      : null,
                ),
                title: Text(
                  counterpart.displayName,
                  style: text.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '@${counterpart.handle}',
                  style: text.bodySmall?.copyWith(color: Colors.white54),
                ),
                trailing: counterpart.isActiveNow == true
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withAlpha(200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClanInfo() {
    final text = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Members',
            style: text.labelMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        CardContainer(
          child: Column(
            children: widget.members.map((m) {
              final isLeader = false; // TODO: Add leader info from API
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF443A5B),
                  backgroundImage: m.avatarUrl != null && m.avatarUrl!.isNotEmpty
                      ? NetworkImage(m.avatarUrl!)
                      : null,
                  child: m.avatarUrl == null || m.avatarUrl!.isEmpty
                      ? const Icon(Icons.person, color: Colors.white70, size: 18)
                      : null,
                ),
                title: Text(
                  m.displayName,
                  style: text.bodyMedium?.copyWith(color: Colors.white),
                ),
                subtitle: Text(
                  '@${m.handle}',
                  style: text.bodySmall?.copyWith(color: Colors.white54),
                ),
                trailing: isLeader
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3B4C3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Leader',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaTab() {
    final text = Theme.of(context).textTheme;
    
    // Collect all attachments from messages
    final allAttachments = <Map<String, dynamic>>[];
    for (final msg in widget.messages) {
      for (final att in msg.attachments) {
        allAttachments.add({
          'attachment': att,
          'message': msg,
          'timestamp': msg.createdAt,
        });
      }
    }

    if (allAttachments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported_outlined,
                color: Colors.white30, size: 48),
            const SizedBox(height: 12),
            Text(
              'No media yet',
              style: text.bodyMedium?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 6),
            Text(
              'Photos, files, and links will appear here',
              style: text.bodySmall?.copyWith(color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photos tab
          if (allAttachments.where((a) => a['attachment'].type == 'image').isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Photos',
                style: text.labelMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allAttachments
                  .where((a) => a['attachment'].type == 'image')
                  .length,
              itemBuilder: (_, i) {
                final item = allAttachments
                    .where((a) => a['attachment'].type == 'image')
                    .toList()[i];
                final att = item['attachment'] as Attachment;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(att.url),
                      fit: BoxFit.cover,
                    ),
                    color: const Color(0xFF2F2941),
                  ),
                  child: att.thumbnailUrl != null
                      ? Image.network(
                          att.thumbnailUrl!,
                          fit: BoxFit.cover,
                        )
                      : null,
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Files tab
          if (allAttachments.where((a) => a['attachment'].type == 'file').isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Files',
                style: text.labelMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CardContainer(
              child: Column(
                children: allAttachments
                    .where((a) => a['attachment'].type == 'file')
                    .map((item) {
                      final att = item['attachment'] as Attachment;
                      return ListTile(
                        leading: const Icon(Icons.attach_file,
                            color: Colors.white70),
                        title: Text(
                          att.fileName ?? 'File',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          att.sizeBytes != null
                              ? '${(att.sizeBytes! / 1024 / 1024).toStringAsFixed(2)} MB'
                              : '',
                          style: text.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                        ),
                        trailing: const Icon(Icons.download,
                            color: Colors.white54, size: 20),
                      );
                    })
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Links tab
          if (allAttachments.where((a) => a['attachment'].type == 'link').isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Links',
                style: text.labelMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CardContainer(
              child: Column(
                children: allAttachments
                    .where((a) => a['attachment'].type == 'link')
                    .map((item) {
                      final att = item['attachment'] as Attachment;
                      return ListTile(
                        leading: const Icon(Icons.link,
                            color: Colors.white70),
                        title: Text(
                          att.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(Icons.open_in_new,
                            color: Colors.white54, size: 18),
                      );
                    })
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

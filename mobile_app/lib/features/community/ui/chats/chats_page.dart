import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../widgets/active_now_strip.dart';
import '../../widgets/chat_empty_state.dart';
import '../../widgets/chat_search_field.dart';
import '../../widgets/thread_filter_bar.dart';
import '../../widgets/thread_list_tile.dart';
import '../../data/demo_store.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  static const _accent = Color(0xFFF3B4C3);

  final _search = TextEditingController();

  // Fake dữ liệu Active now
  final List<ActiveUser> _activeUsers = const [
    ActiveUser(name: 'Han'),
    ActiveUser(name: 'Linh'),
    ActiveUser(name: 'Diem'),
    ActiveUser(name: 'Vy'),
    ActiveUser(name: 'Quan'),
    ActiveUser(name: 'Anh'),
    ActiveUser(name: 'Khai'),
  ];

  // Fake danh sách thread (giữ nguyên)
  final List<_ThreadItem> _threads = const [
    _ThreadItem(
      id: 't1',
      title: 'BrainBattle Clan',
      isGroup: true,
      lastMessage: 'Han: Tối nay battle IELTS nhé?',
      timeLabel: '5m',
      unreadCount: 3,
    ),
    _ThreadItem(
      id: 't2',
      title: 'User Support',
      isGroup: false,
      lastMessage: 'This is to notify you that your password has been...',
      timeLabel: '22:03',
      activeStatus: 'Active now',
      isActiveNow: true,
    ),
    _ThreadItem(
      id: 't3',
      title: 'User Support',
      isGroup: false,
      lastMessage: 'Hello World! This is a test message.',
      timeLabel: '20:12',
      unreadCount: 1,
      activeStatus: 'Active 5m ago',
    ),
    _ThreadItem(
      id: 't4',
      title: 'Clan IELTS',
      isGroup: true,
      lastMessage: 'User Support: Image · 19:34',
      timeLabel: '19:34',
    ),
    _ThreadItem(
      id: 't5',
      title: 'User Support',
      isGroup: false,
      lastMessage: 'You: Nothing to text here.',
      timeLabel: '18:25',
      activeStatus: 'Active 1h ago',
    ),
    _ThreadItem(
      id: 't6',
      title: 'Clan TOEIC',
      isGroup: false,
      lastMessage: 'You: See you all in the next battle!',
      timeLabel: '15:02',
      unreadCount: 4,
    ),
  ];

  ThreadFilter _filter = ThreadFilter.all;

  @override
  void initState() {
    super.initState();
    // ✅ Demo mới: init 2 DM (David + Teacher), clan chỉ xuất hiện sau create
    DemoCommunityStore.I.ensureDemoDmThreads();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final query = _search.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: AnimatedBuilder(
        // ✅ LISTEN store để clan/incoming/unread update realtime
        animation: DemoCommunityStore.I,
        builder: (_, __) {
          final demoThreads = DemoCommunityStore.I.threads;

          final merged = [
            ...demoThreads.map(
              (t) => _ThreadItem(
                id: t.id,
                title: t.title,
                isGroup: t.isClan,
                lastMessage:
                    t.messages.isEmpty ? 'Start chatting' : t.messages.last.text,
                unreadCount: t.unread,
                timeLabel: t.messages.isEmpty
                    ? ''
                    : _formatTime(t.messages.last.createdAt),
              ),
            ),
            ..._threads, // giữ fake threads để list nhìn "thật"
          ];

          final filteredThreads = merged.where((t) {
            if (_filter == ThreadFilter.unread && t.unreadCount <= 0) {
              return false;
            }
            if (_filter == ThreadFilter.groups && !t.isGroup) return false;

            if (query.isNotEmpty) {
              final inTitle = t.title.toLowerCase().contains(query);
              final inPreview = t.lastMessage.toLowerCase().contains(query);
              if (!inTitle && !inPreview) return false;
            }
            return true;
          }).toList();

          final hasThreads = filteredThreads.isNotEmpty;

          return Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 12, 6),
                  child: Row(
                    children: [
                      Text(
                        'Community',
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: .2,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'New clan',
                        onPressed: _onNewClan,
                        icon: const Icon(
                          Icons.group_add_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Search
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                        child: ChatSearchField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),

                    // Active now
                    SliverToBoxAdapter(
                      child: ActiveNowStrip(
                        users: _activeUsers,
                        onUserTap: (_) {},
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 8)),

                    // Filter bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: ThreadFilterBar(
                          value: _filter,
                          accent: _accent,
                          onChanged: (f) => setState(() => _filter = f),
                        ),
                      ),
                    ),

                    // List / Empty
                    if (!hasThreads)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: ChatEmptyState(
                          accent: _accent,
                          onNewClan: _onNewClan,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                        sliver: SliverList.builder(
                          itemCount: filteredThreads.length,
                          itemBuilder: (_, i) {
                            final t = filteredThreads[i];
                            return ThreadListTile(
                              title: t.title,
                              lastMessage: t.lastMessage,
                              timeLabel: t.timeLabel,
                              isGroup: t.isGroup,
                              unreadCount: t.unreadCount,
                              isActiveNow: t.isActiveNow,
                              activeStatus: t.activeStatus,
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  CommunityRoutes.thread,
                                  arguments: ThreadArgs(t.id, title: t.title),
                                );
                                // vẫn để setState: refresh search/filter UI local
                                setState(() {});
                              },
                            );
                          },
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        onPressed: _onNewClan,
        child: const Icon(Icons.message_rounded),
      ),
    );
  }

  Future<void> _onNewClan() async {
    final result = await Navigator.pushNamed(
      context,
      CommunityRoutes.newClan,
    );

    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      await Navigator.pushNamed(
        context,
        CommunityRoutes.thread,
        arguments: ThreadArgs(result, title: 'New clan'),
      );
      setState(() {});
    }
  }

  String _formatTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  }
}

/* ========= Local model fake cho list ========= */

class _ThreadItem {
  final String id;
  final String title;
  final bool isGroup;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final String? activeStatus;
  final bool isActiveNow;

  const _ThreadItem({
    required this.id,
    required this.title,
    required this.isGroup,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
    this.activeStatus,
    this.isActiveNow = false,
  });
}

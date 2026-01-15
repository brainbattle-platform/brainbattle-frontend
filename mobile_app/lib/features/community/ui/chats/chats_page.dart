import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';
import '../../widgets/active_now_strip.dart';
import '../../widgets/chat_empty_state.dart';
import '../../widgets/chat_search_field.dart';
import '../../widgets/thread_filter_bar.dart';
import '../../widgets/thread_list_tile.dart';
import '../../data/community_di.dart';
import '../../data/models.dart';
import '../_helpers/dm_helper.dart';
import '../_helpers/datetime_helper.dart';
import '../_helpers/dm_display_helper.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  static const _accent = Color(0xFFF3B4C3);

  final _search = TextEditingController();
  final _repo = communityRepo();

  List<ThreadLiteApi> _threads = [];
  List<UserLite> _activeUsers = [];
  bool _loading = false;
  String? _error;
  String? _nextCursor;

  ThreadFilter _filter = ThreadFilter.all;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load threads and active users in parallel
      final results = await Future.wait([
        _repo.getThreads(
          type: _filterTypeParam(),
          filter: _filter == ThreadFilter.unread ? 'unread' : null,
          q: _search.text.trim().isNotEmpty ? _search.text.trim() : null,
          limit: 20,
        ),
        _repo.getActiveUsers(limit: 20),
      ]);

      if (mounted) {
        setState(() {
          _threads = results[0].items as List<ThreadLiteApi>;
          _nextCursor = results[0].nextCursor;
          _activeUsers = results[1].items as List<UserLite>;
          _loading = false;
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

  String _filterTypeParam() {
    switch (_filter) {
      case ThreadFilter.groups:
        return 'clan';
      default:
        return 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final hasThreads = _threads.isNotEmpty;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: Column(
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
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  // Search
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: ChatSearchField(
                        controller: _search,
                        onChanged: (value) {
                          // Debounced search
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_search.text.trim() == value) {
                              _loadData();
                            }
                          });
                        },
                      ),
                    ),
                  ),

                  // Active now
                  if (_activeUsers.isNotEmpty)
                    SliverToBoxAdapter(
                      child: ActiveNowStrip(
                        users: _activeUsers.map((u) => ActiveUser(
                          id: u.id,
                          handle: u.handle,
                          displayName: u.displayName,
                          avatarUrl: u.avatarUrl,
                          isActiveNow: u.isActiveNow,
                          lastActiveAt: u.lastActiveAt,
                        )).toList(),
                        onUserTap: (user) async {
                          try {
                            final threadId = await getOrCreateDMConversation(user.id);
                            if (!mounted) return;
                            await Navigator.pushNamed(
                              context,
                              CommunityRoutes.thread,
                              arguments: ThreadArgs(threadId, title: user.displayName),
                            );
                            _loadData(); // Refresh after returning
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Cannot open chat right now'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 8)),

                  // Filter bar (wrapped with padding + divider)
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                          child: ThreadFilterBar(
                            value: _filter,
                            accent: _accent,
                            onChanged: (f) {
                              setState(() => _filter = f);
                              _loadData();
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtle divider
                        Container(
                          height: 1,
                          color: Colors.white10,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Error
                  if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                  // Loading
                  if (_loading && _threads.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  // Empty
                  else if (!hasThreads && !_loading)
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
                        itemCount: _threads.length,
                        itemBuilder: (_, i) {
                          final t = _threads[i];
                          final displayName = t.isClan ? t.title : getDMCounterpartName(t);
                          final localTime = parseToLocal(t.lastMessageAt.toIso8601String());
                          return ThreadListTile(
                            title: displayName,
                            lastMessage: t.lastMessagePreview,
                            timeLabel: formatChatTime(localTime),
                            isGroup: t.isClan,
                            unreadCount: t.unreadCount,
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                CommunityRoutes.thread,
                                arguments: ThreadArgs(t.id, title: displayName),
                              );
                              _loadData(); // Refresh after returning
                            },
                          );
                        },
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                ],
              ),
            ),
          ),
        ],
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
      _loadData();
    }
  }
}

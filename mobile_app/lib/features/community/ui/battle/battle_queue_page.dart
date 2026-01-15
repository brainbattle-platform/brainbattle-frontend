// lib/features/community/ui/battle/battle_queue_page.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../community_routes.dart';
import '../../widgets/top_header.dart';
import '../_helpers/dm_helper.dart';

class BattleQueuePage extends StatefulWidget {
  const BattleQueuePage({super.key});

  @override
  State<BattleQueuePage> createState() => _BattleQueuePageState();
}

class _BattleQueuePageState extends State<BattleQueuePage> {
  static const _accent = Color(0xFFF3B4C3);
  final _search = TextEditingController();
  String _sortBy = 'az'; // 'az' or 'active'

  // TODO: Replace with account-service GET /users/search
  final List<UserLite> _allUsers = [];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<UserLite> _getFilteredAndSorted() {
    var users = _allUsers;
    final query = _search.text.toLowerCase();
    if (query.isNotEmpty) {
      users = users
          .where((u) =>
              u.displayName.toLowerCase().contains(query) ||
              u.handle.toLowerCase().contains(query))
          .toList();
    }

    if (_sortBy == 'az') {
      users.sort((a, b) => a.displayName.compareTo(b.displayName));
    } else if (_sortBy == 'active') {
      users.sort((a, b) {
        final aActive = a.isActiveNow == true ? 0 : 1;
        final bActive = b.isActiveNow == true ? 0 : 1;
        return aActive.compareTo(bActive);
      });
    }

    return users;
  }

  Future<void> _onUserTap(UserLite user) async {
    try {
      final threadId = await getOrCreateDMConversation(user.id);
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        CommunityRoutes.thread,
        arguments: ThreadArgs(threadId, title: user.displayName),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cannot open chat right now'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredAndSorted();

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: TopHeader(title: 'People'),
          ),
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or handle…',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF2F2941),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          // Sort bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text(
                    'Sort:',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('A–Z'),
                    selected: _sortBy == 'az',
                    onSelected: (_) => setState(() => _sortBy = 'az'),
                    backgroundColor: const Color(0xFF2F2941),
                    selectedColor: _accent.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: _sortBy == 'az' ? _accent : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: _sortBy == 'active',
                    onSelected: (_) => setState(() => _sortBy = 'active'),
                    backgroundColor: const Color(0xFF2F2941),
                    selectedColor: _accent.withOpacity(0.3),
                    labelStyle: TextStyle(
                      color: _sortBy == 'active' ? _accent : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // User list
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'No users found',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final user = filtered[i];
                  return _UserCard(
                    user: user,
                    onTap: () => _onUserTap(user),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

// User card widget
class _UserCard extends StatelessWidget {
  final UserLite user;
  final VoidCallback onTap;

  const _UserCard({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2F2941),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white10,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF443A5B),
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white70)
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and handle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '@${user.handle}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Online indicator
            if (user.isActiveNow == true)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

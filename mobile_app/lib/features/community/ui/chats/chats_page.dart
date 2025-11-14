import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../community_routes.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  static const _accent = Color(0xFFF3B4C3);
  final _search = TextEditingController();

  final _active = const [
    _ActiveUser('Han'),
    _ActiveUser('Linh'),
    _ActiveUser('Diem'),
    _ActiveUser('Vy'),
    _ActiveUser('Quan'),
    _ActiveUser('Anh'),
    _ActiveUser('Khai'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: Column(
        children: [
          // Header cố định như Messenger
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
                // Search kiểu WhatsApp: gọn, bo nhẹ, nền tối hơn bg một chút
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: _SearchField(
                      controller: _search,
                      onChanged: (q) => setState(() {}),
                    ),
                  ),
                ),

                // Active users: avatar tròn + tên, không có khung
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 86,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: _active.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (_, i) => _ActiveAvatar(
                        user: _active[i],
                        onTap: () {
                          // TODO: mở quick chat / thread 1-1
                        },
                      ),
                    ),
                  ),
                ),

                // Divider mảnh ngăn phần list
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8, bottom: 4),
                    child: Divider(height: 0, color: Colors.white10),
                  ),
                ),

                // Danh sách cuộc trò chuyện: ListTile phẳng + Divider như WhatsApp
                SliverList.separated(
                  itemCount: 12,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.white10),
                  itemBuilder: (_, i) => InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      CommunityRoutes.thread,
                      arguments: ThreadArgs(
                        't$i',
                        title: i.isEven ? 'BrainBattle Clan' : 'Ngoc Han',
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        leading: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              child: Icon(Icons.person),
                            ),
                            // chấm online (optional)
                            Positioned(
                              right: -1,
                              bottom: -1,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: BBColors.darkBg,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          i.isEven ? 'BrainBattle Clan' : 'Ngoc Han',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: .1,
                          ),
                        ),
                        subtitle: const Text(
                          'Last message preview…',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70),
                        ),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              '5m',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 6),
                            // badge unread (ẩn nếu 0)
                            // _UnreadBadge(count: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
        ],
      ),
      // FAB tuỳ chọn: giống WhatsApp có nút compose
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        foregroundColor: Colors.black,
        onPressed: _onNewClan,
        child: const Icon(Icons.message_rounded),
      ),
    );
  }

  // ĐỔI: new group -> new clan; điều hướng đến trang tạo clan và chờ threadId trả về.
  Future<void> _onNewClan() async {
    // Điều hướng tạo clan
    final result = await Navigator.pushNamed(context, CommunityRoutes.newClan);

    if (!mounted) return;
    // Kỳ vọng NewClanPage pop về một threadId (fake hoặc thật)
    if (result is String && result.isNotEmpty) {
      // Mở thẳng vào thread vừa tạo
      Navigator.pushNamed(
        context,
        CommunityRoutes.thread,
        arguments: ThreadArgs(
          result,
          title: 'New clan',
        ), // FE-only title; BE sẽ cung cấp thật sau
      );
    }
  }
}

/* ================== widgets nhỏ ================== */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _SearchField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search…',
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
        isDense: true,
        filled: true,
        fillColor: const Color(0xFF2F2941), // tối nhẹ, phẳng
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none, // phẳng đúng kiểu WhatsApp
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white70),
                onPressed: () {
                  controller.clear();
                  onChanged?.call('');
                },
              )
            : null,
      ),
    );
  }
}

class _ActiveUser {
  final String name;
  final String? avatarUrl;
  const _ActiveUser(this.name, {this.avatarUrl});
}

class _ActiveAvatar extends StatelessWidget {
  final _ActiveUser user;
  final VoidCallback onTap;
  const _ActiveAvatar({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF443A5B),
                backgroundImage: (user.avatarUrl != null)
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user.avatarUrl == null)
                    ? const Icon(Icons.person, color: Colors.white70)
                    : null,
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade400,
                    shape: BoxShape.circle,
                    border: Border.all(color: BBColors.darkBg, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            user.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF3B4C3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

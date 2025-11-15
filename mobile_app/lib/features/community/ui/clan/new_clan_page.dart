import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models.dart';

class NewClanPage extends StatefulWidget {
  const NewClanPage({super.key});
  static const routeName = '/community/new-clan';

  @override
  State<NewClanPage> createState() => _NewClanPageState();
}

class _NewClanPageState extends State<NewClanPage> {
  static const _accent = Color(0xFFF3B4C3);

  final _search = TextEditingController();
  final _clanName = TextEditingController();
  final _description = TextEditingController();
  final _scroll = ScrollController();

  // mock danh sách users – sau này bind từ BE
  final List<UserLite> _allUsers = const [
    UserLite(
      id: 'u1',
      name: 'Han',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    UserLite(
      id: 'u2',
      name: 'Linh',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    UserLite(
      id: 'u3',
      name: 'Vy',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
    ),
    UserLite(
      id: 'u4',
      name: 'Chi',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
    ),
    UserLite(
      id: 'u5',
      name: 'Thảo',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
    ),
    UserLite(
      id: 'u6',
      name: 'Hảo',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
    ),
    UserLite(id: 'u7', name: 'Vũ'),
    UserLite(id: 'u8', name: 'Quân'),
    UserLite(id: 'u9', name: 'Minh'),
    UserLite(id: 'u10', name: 'Anh'),
  ];

  // state
  final Set<String> _selectedIds = {};
  File? _pickedImage; // mock – chưa tích hợp picker thực

  @override
  void dispose() {
    _search.dispose();
    _clanName.dispose();
    _description.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final query = _search.text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? _allUsers
        : _allUsers.where((u) => u.name.toLowerCase().contains(query)).toList();

    final selectedUsers =
        _allUsers.where((u) => _selectedIds.contains(u.id)).toList();

    final canCreate =
        _clanName.text.trim().isNotEmpty && _selectedIds.length >= 2;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header phẳng (Back + Title) =====
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              decoration: const BoxDecoration(
                color: BBColors.darkBg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'New clan',
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .2,
                    ),
                  ),
                  const Spacer(),
                  if (canCreate)
                    TextButton(
                      onPressed: _onCreateClan,
                      child: const Text('Create'),
                    ),
                ],
              ),
            ),

            // ===== Info group: Avatar + Name + Description =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImageMock,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFF443A5B),
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : null,
                          child: _pickedImage == null
                              ? const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white70,
                                )
                              : null,
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: BBColors.darkBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _clanName,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Clan name',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF2F2941),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _description,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Describe your clan (optional)…',
                            hintStyle: const TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: const Color(0xFF2F2941),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Search members =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search members…',
                  hintStyle: const TextStyle(color: Colors.white60),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.white60,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2F2941),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ===== Selected chips (nếu có) =====
            if (selectedUsers.isNotEmpty)
              SizedBox(
                height: 46,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedUsers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final u = selectedUsers[i];
                    return InputChip(
                      onPressed: () {},
                      onDeleted: () => _toggleSelect(u.id),
                      label: Text(u.name),
                      deleteIcon: const Icon(Icons.close_rounded, size: 18),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: _accent,
                    );
                  },
                ),
              ),

            const SizedBox(height: 6),

            // ===== Members list (chọn nhiều) =====
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                itemCount: filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white10),
                itemBuilder: (_, i) {
                  final u = filtered[i];
                  final selected = _selectedIds.contains(u.id);
                  return SelectableUserTile(
                    user: u,
                    selected: selected,
                    onToggle: () => _toggleSelect(u.id),
                  );
                },
              ),
            ),

            // ===== Create Button (bottom) =====
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canCreate ? _onCreateClan : null,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Create Clan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSelect(String userId) {
    setState(() {
      if (_selectedIds.contains(userId)) {
        _selectedIds.remove(userId);
      } else {
        _selectedIds.add(userId);
      }
    });
  }

  void _pickImageMock() {
    // TODO: tích hợp image_picker / file_picker sau
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker not implemented yet')),
    );
  }

  void _onCreateClan() {
    final name = _clanName.text.trim();
    final desc = _description.text.trim();
    final members =
        _allUsers.where((u) => _selectedIds.contains(u.id)).toList();

    // TODO: gửi name, desc, members lên BE
    // FE-only: fake threadId
    final fakeThreadId = 't_${DateTime.now().millisecondsSinceEpoch}';

    // Trả về threadId để ChatsPage có thể điều hướng vào ThreadPage
    Navigator.pop(context, fakeThreadId);

    // Debug (nếu cần)
    // print('Create clan: $name / desc="$desc" with ${members.length} members');
  }
}

/* ================== WIDGET: selectable user tile ================== */

class SelectableUserTile extends StatelessWidget {
  final UserLite user;
  final bool selected;
  final VoidCallback onToggle;

  const SelectableUserTile({
    super.key,
    required this.user,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF443A5B),
            backgroundImage:
                (user.avatarUrl != null) ? NetworkImage(user.avatarUrl!) : null,
            child: (user.avatarUrl == null)
                ? const Icon(Icons.person, color: Colors.white70)
                : null,
          ),
          title: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF3B4C3) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected ? const Color(0xFFF3B4C3) : Colors.white38,
                width: 1.4,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.black)
                : null,
          ),
        ),
      ),
    );
  }
}

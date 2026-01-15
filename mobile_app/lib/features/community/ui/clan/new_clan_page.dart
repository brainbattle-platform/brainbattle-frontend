import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models.dart';
import '../../data/community_di.dart';

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

  // TODO: Integrate with account-service GET /users/search
  // For now, use empty list. Users will be added via API integration.
  final List<UserLite> _allUsers = const [];

  final Set<String> _selectedIds = {};
  File? _pickedImage;

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

    final filteredUsers = query.isEmpty
        ? _allUsers
        : _allUsers
            .where((u) => u.name.toLowerCase().contains(query))
            .toList();

    final selectedUsers =
        _allUsers.where((u) => _selectedIds.contains(u.id)).toList();

    final canCreate =
        _clanName.text.trim().isNotEmpty && selectedUsers.length >= 2;

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // ===== Header =====
            Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'New clan',
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
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

            // ===== Clan avatar + name + desc =====
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImageMock,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFF443A5B),
                      backgroundImage:
                          _pickedImage != null ? FileImage(_pickedImage!) : null,
                      child: _pickedImage == null
                          ? const Icon(Icons.camera_alt_rounded,
                              color: Colors.white70)
                          : null,
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
                          decoration: _inputDecoration('Clan name'),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _description,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                              'Describe your clan (optional)…'),
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
                decoration: _inputDecoration('Search members…',
                    prefix: Icons.search_rounded),
              ),
            ),

            // ===== Selected members chips =====
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
                      onDeleted: () => _toggleSelect(u.id),
                      label: Text(u.name),
                      backgroundColor: _accent,
                      deleteIcon:
                          const Icon(Icons.close_rounded, size: 18),
                      labelStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 6),

            // ===== Members list =====
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Colors.white10),
                itemBuilder: (_, i) {
                  final u = filteredUsers[i];
                  return SelectableUserTile(
                    user: u,
                    selected: _selectedIds.contains(u.id),
                    onToggle: () => _toggleSelect(u.id),
                  );
                },
              ),
            ),

            // ===== Create button =====
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

  // ===== Helpers =====

  InputDecoration _inputDecoration(String hint, {IconData? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white60),
      prefixIcon:
          prefix != null ? Icon(prefix, color: Colors.white60) : null,
      filled: true,
      fillColor: const Color(0xFF2F2941),
      isDense: true,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _toggleSelect(String userId) {
    setState(() {
      _selectedIds.contains(userId)
          ? _selectedIds.remove(userId)
          : _selectedIds.add(userId);
    });
  }

  void _pickImageMock() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker not implemented (demo)')),
    );
  }

  // ===== CORE LOGIC =====
  Future<void> _onCreateClan() async {
    final name = _clanName.text.trim();
    final description = _description.text.trim();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = communityRepo();
      final result = await repo.createClan(
        name: name,
        description: description.isNotEmpty ? description : null,
        avatarUrl: null, // TODO: upload _pickedImage if needed
        memberIds: _selectedIds.toList(),
      );

      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Return thread ID to navigate to chat
      Navigator.pop(context, result.thread.id);
    } catch (e) {
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating clan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/* ================= Selectable user tile ================= */

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
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFF443A5B),
          backgroundImage:
              user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
          child: user.avatarUrl == null
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
              color:
                  selected ? const Color(0xFFF3B4C3) : Colors.white38,
              width: 1.4,
            ),
          ),
          child: selected
              ? const Icon(Icons.check_rounded,
                  size: 16, color: Colors.black)
              : null,
        ),
      ),
    );
  }
}

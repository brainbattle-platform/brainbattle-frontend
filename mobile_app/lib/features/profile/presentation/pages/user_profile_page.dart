import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/profile_models.dart';
import '../../data/repositories/profile_repository.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_video_grid.dart';
import 'learning_profile_page.dart';
import 'battle_profile_page.dart';
import '../../ui/app_shell.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _repository = ProfileRepository();
  final String _userId = 'current_user'; // TODO: Get from auth service

  ProfileBasic? _profile;
  List<VideoPreview> _videos = [];
  int _selectedTab = 0; // 0 = Videos, 1 = Đã thích
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final profile = await _repository.getProfile(_userId);
      final videos = await _repository.getUserVideos(
        _userId,
        tab: _selectedTab == 0 ? 'videos' : 'liked',
      );
      if (mounted) {
        setState(() {
          _profile = profile;
          _videos = videos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
      _loadData();
    }
  }

  void _onBackPressed() {
    // Navigate back to Learning Map (index 1) in PageView
    AppShell.navigateToPage(1);
  }

  void _openLearningProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningProfilePage(userId: _userId),
      ),
    );
  }

  void _openBattleProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BattleProfilePage(userId: _userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? BBColors.darkBg : Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _onBackPressed,
        ),
        title: Text(_profile?.username ?? '@user1'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header card with avatar, username, bio, and pill buttons
                      ProfileHeader(
                        profile: _profile!,
                        onLearningProfileTap: _openLearningProfile,
                        onBattleProfileTap: _openBattleProfile,
                      ),
                      const SizedBox(height: 16),
                      // Tabs
                      Row(
                        children: [
                          Expanded(
                            child: _TabButton(
                              label: 'Videos',
                              active: _selectedTab == 0,
                              onTap: () => _onTabChanged(0),
                            ),
                          ),
                          Expanded(
                            child: _TabButton(
                              label: 'Đã thích',
                              active: _selectedTab == 1,
                              onTap: () => _onTabChanged(1),
                            ),
                          ),
                        ],
                      ),
                      // Video grid
                      ProfileVideoGrid(
                        videos: _videos,
                        onVideoTap: (video) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Open video detail: ${video.id} (todo)'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = const Color(0xFFFF8FAB); // Pink from theme

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? activeColor : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active
                ? activeColor
                : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}


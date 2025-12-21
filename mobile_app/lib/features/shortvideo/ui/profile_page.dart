import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../data/local_shorts_store.dart';
import '../core/follow_service.dart';
import '../shortvideo_routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = ShortVideoRoutes.profile;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FollowService _followService = FollowService.instance;
  final ShortVideoService _videoService = ShortVideoService();
  final LocalShortsStore _localStore = LocalShortsStore.instance;
  
  String? _userId;
  bool _following = false;
  bool _loading = true;
  List<ShortVideo> _videos = [];
  int _selectedTab = 0; // 0 = videos, 1 = liked

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _userId = args?['userId'] as String? ?? 'unknown';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    // Load follow state
    final following = await _followService.isFollowing(_userId!);
    
    // Load videos from local store first
    final localVideos = await _localStore.listMyPosts(_userId!);
    
    // Also load from API
    final allVideos = await _videoService.fetchFeed(page: 1);
    final userVideos = allVideos.where((v) => v.author == _userId).toList();
    
    // Merge: local first, then remote
    final allUserVideos = [...localVideos, ...userVideos];
    
    setState(() {
      _following = following;
      _videos = allUserVideos.isEmpty ? allVideos.take(6).toList() : allUserVideos;
      _loading = false;
    });
  }

  Future<void> _toggleFollow() async {
    final newState = await _followService.toggleFollow(_userId!);
    setState(() => _following = newState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('@$_userId'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=${_userId.hashCode % 70}',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '@$_userId',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bio của $_userId (stub)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _following
                                ? Colors.transparent
                                : Colors.pinkAccent,
                            foregroundColor: _following ? Colors.white : Colors.white,
                            side: BorderSide(
                              color: _following ? Colors.white : Colors.transparent,
                            ),
                          ),
                          child: Text(_following ? 'Đã follow' : 'Follow'),
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Videos',
                          active: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: 'Đã thích',
                          active: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                  // Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: _videos.length,
                    itemBuilder: (context, index) {
                      final video = _videos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            ShortVideoRoutes.player,
                            arguments: {
                              'videos': _videos,
                              'initialIndex': index,
                              'contextType': 'profile',
                              'userId': _userId,
                            },
                          );
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              video.thumbnailUrl,
                              fit: BoxFit.cover,
                            ),
                            const Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black54],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Row(
                                children: [
                                  const Icon(Icons.play_arrow, size: 14, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${video.likes}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? Colors.pinkAccent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.pinkAccent : Colors.white70,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../data/local_shorts_store.dart';
import '../core/hashtag_service.dart';
import '../shortvideo_routes.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';

class HashtagPage extends StatefulWidget {
  const HashtagPage({super.key});

  static const routeName = ShortVideoRoutes.hashtag;

  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  final ShortVideoService _service = ShortVideoService();
  final LocalShortsStore _localStore = LocalShortsStore.instance;
  final HashtagService _hashtagService = HashtagService.instance;

  String? _tag;
  bool _loading = true;
  bool _following = false;
  String? _errorMessage;
  int _selectedTab = 0; // 0 = Top, 1 = Recent (optional)
  List<ShortVideo> _topVideos = [];
  List<ShortVideo> _recentVideos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _tag = args?['tag'] as String? ?? '';
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Load follow state
      final following = await _hashtagService.isFollowing(_tag!);

      // Add to recent
      await _hashtagService.addRecent(_tag!);

      // Load videos from API and local
      final remoteVideos = await _service.fetchFeed(page: 1);
      final localVideos = await _localStore.listFeedPosts();
      final allVideos = [...localVideos, ...remoteVideos];

      // Filter by hashtag
      final tagLower = '#$_tag'.toLowerCase();
      final filtered = allVideos
          .where((v) => v.caption.toLowerCase().contains(tagLower))
          .toList();

      // Mock: split into top (by likes) and recent
      filtered.sort((a, b) => b.likes.compareTo(a.likes));
      final top = filtered.take(filtered.length ~/ 2 + 1).toList();
      final recent = filtered.skip(filtered.length ~/ 2 + 1).toList();

      if (mounted) {
        setState(() {
          _following = following;
          _topVideos = top.isEmpty ? filtered.take(6).toList() : top;
          _recentVideos = recent;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tải video: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _toggleFollow() async {
    final newState = await _hashtagService.toggleFollow(_tag!);
    setState(() => _following = newState);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('#$_tag'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? ShortsErrorState(message: _errorMessage!, onRetry: _loadVideos)
          : Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '#$_tag',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_topVideos.length + _recentVideos.length} videos',
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
                          foregroundColor: _following
                              ? Colors.white
                              : Colors.white,
                          side: BorderSide(
                            color: _following
                                ? Colors.white
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(_following ? 'Đã follow' : 'Follow'),
                      ),
                    ],
                  ),
                ),
                // Tabs (if recent videos exist)
                if (_recentVideos.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: _TabButton(
                          label: 'Top',
                          active: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                      ),
                      Expanded(
                        child: _TabButton(
                          label: 'Recent',
                          active: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ),
                    ],
                  ),
                // Grid
                Expanded(child: _buildGrid()),
              ],
            ),
    );
  }

  Widget _buildGrid() {
    final videos = _selectedTab == 0 ? _topVideos : _recentVideos;

    if (videos.isEmpty) {
      return ShortsEmptyState(message: 'Không có video');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              ShortVideoRoutes.player,
              arguments: {
                'videos': videos,
                'initialIndex': index,
                'contextType': 'hashtag',
                'hashtag': _tag,
              },
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(video.thumbnailUrl, fit: BoxFit.cover),
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
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            color: active
                ? Colors.pinkAccent
                : (isDark ? Colors.white70 : Colors.black54),
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../widgets/shortvideo_player.dart';
import '../widgets/top_tabs.dart';
import '../widgets/right_rail.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/comment_sheet.dart';
import '../widgets/share_sheet.dart';
import '../widgets/caption_widget.dart';
import '../core/mute_service.dart';
import '../core/follow_service.dart';
import '../core/save_service.dart';
import '../shortvideo_routes.dart';
import 'shorts_search_page.dart';
import 'shorts_recorder_page.dart';

class ShortVideoFeedPage extends StatefulWidget {
  const ShortVideoFeedPage({super.key});

  @override
  State<ShortVideoFeedPage> createState() => _ShortVideoFeedPageState();
}

class _ShortVideoFeedPageState extends State<ShortVideoFeedPage> {
  final _svc = ShortVideoService();
  final PageController _page = PageController();
  final MuteService _muteService = MuteService.instance;
  final FollowService _followService = FollowService.instance;
  final SaveService _saveService = SaveService.instance;

  final List<ShortVideo> _items = [];
  bool _loading = true;
  int _pageNum = 1;
  bool _muted = false;
  int _currentIndex = 0;

  // controller + duration per index (để seek/progress)
  final Map<int, Duration> _durations = {};
  final Map<int, Duration> _positions = {};
  final Map<int, VideoPlayerController?> _controllers = {}; // VideoPlayerController
  final Map<String, bool> _savedVideos = {}; // videoId -> saved
  final Map<String, bool> _followingUsers = {}; // userId -> following
  final Map<int, bool> _expandedCaptions = {}; // index -> expanded

  @override
  void initState() {
    super.initState();
    _loadMuteState();
    _load();
  }

  Future<void> _loadMuteState() async {
    final muted = await _muteService.isMuted();
    setState(() => _muted = muted);
  }

  Future<void> _toggleMute() async {
    final newMuted = await _muteService.toggle();
    setState(() => _muted = newMuted);
    // Update current video volume
    final controller = _controllers[_currentIndex];
    if (controller != null && controller.value.isInitialized) {
      await controller.setVolume(newMuted ? 0.0 : 1.0);
    }
  }

  Future<void> _load({bool append = true}) async {
    final data = await _svc.fetchFeed(page: _pageNum);
    setState(() {
      if (append) {
        _items.addAll(data);
      } else {
        _items
          ..clear()
          ..addAll(data);
      }
      _loading = false;
    });
  }

  Future<void> _loadMoreIfNeeded(int index) async {
    setState(() => _currentIndex = index);
    
    // Cleanup controllers that are far away (keep current + next only)
    _controllers.removeWhere((key, controller) {
      if ((key - index).abs() > 2) {
        controller?.dispose();
        return true;
      }
      return false;
    });

    if (index >= _items.length - 2) {
      _pageNum += 1;
      await _load(append: true);
    }
  }

  void _toggleLike(int index) {
    setState(() {
      final v = _items[index];
      _items[index] = v.copyWith(
        liked: !v.liked,
        likes: v.liked ? (v.likes - 1) : (v.likes + 1),
      );
    });
  }
  void _openComments(ShortVideo v, int index) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.92,
        child: CommentSheet(
          videoId: v.id,
          initialCount: v.comments,
          onCountChanged: (newCount) {
            setState(() {
              _items[index] = v.copyWith(comments: newCount);
            });
          },
        ),
      ),
    );
  }

  void _openShareSheet(ShortVideo v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSheet(
        videoId: v.id,
        videoUrl: v.videoUrl,
      ),
    );
  }

  Future<void> _toggleSave(int index) async {
    final video = _items[index];
    final saved = await _saveService.toggleSave(video.id);
    setState(() {
      _savedVideos[video.id] = saved;
    });
  }

  Future<void> _toggleFollow(String userId) async {
    final following = await _followService.toggleFollow(userId);
    setState(() {
      _followingUsers[userId] = following;
    });
  }

  void _navigateToProfile(String userId) {
    Navigator.pushNamed(
      context,
      ShortVideoRoutes.profile,
      arguments: {'userId': userId},
    );
  }

  // void _showCommentsSheet(ShortVideo v) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: const Color(0xFF111111),
  //     isScrollControlled: true,
  //     builder: (c) => DraggableScrollableSheet(
  //       initialChildSize: 0.7,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.95,
  //       expand: false,
  //       builder: (_, controller) => ListView.builder(
  //         controller: controller,
  //         itemCount: 18,
  //         itemBuilder: (_, i) => ListTile(
  //           leading: const CircleAvatar(child: Icon(Icons.person)),
  //           title: Text('User $i', style: const TextStyle(color: Colors.white)),
  //           subtitle: const Text('Very cool clip! 🔥',
  //               style: TextStyle(color: Colors.white70)),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _seekTo(int index, double valueSec) {
    final c = _controllers[index];
    if (c != null && c.value.isInitialized) {
      c.seekTo(Duration(milliseconds: (valueSec * 1000).toInt()));
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller?.dispose();
    }
    _controllers.clear();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            scrollDirection: Axis.vertical,
            itemCount: _items.length,
            onPageChanged: _loadMoreIfNeeded,
            itemBuilder: (context, index) {
              final item = _items[index];
              final dur = _durations[index]?.inSeconds.toDouble() ?? 0.0;
              final pos = _positions[index]?.inSeconds.toDouble() ?? 0.0;
              final saved = _savedVideos[item.id] ?? false;
              final following = _followingUsers[item.author] ?? false;

              return Stack(
                children: [
                  ShortVideoPlayer(
                    url: item.videoUrl,
                    thumbnail: item.thumbnailUrl,
                    muted: _muted,
                    onController: (c) {
                      _controllers[index] = c;
                      // Apply mute state immediately
                      if (c.value.isInitialized) {
                        c.setVolume(_muted ? 0.0 : 1.0);
                      }
                    },
                    onReady: (d) => setState(() => _durations[index] = d),
                    onProgress: (p) => setState(() => _positions[index] = p),
                    onError: (hasError) {
                      if (hasError) {
                        // Error handled in player widget
                      }
                    },
                    onRetry: () {
                      // Retry will be handled by player
                    },
                  ),
                  // Mute button (top-right)
                  Positioned(
                    top: 60,
                    right: 16,
                    child: IconButton(
                      icon: Icon(
                        _muted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                  ),
                  // top gradient + tabs
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [Colors.black45, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: TopTabs(
                      active: 'Đề xuất',
                      onSearchTap: () {
                        Navigator.pushNamed(context, ShortVideoRoutes.search);
                      },
                    ),
                  ),

                  // Banner + bubble (demo)
                  Positioned(
                    left: 12,
                    top: 80,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('➕ Thêm bài của bạn',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 140,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('Nhấp ngay\ncó thưởng',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),

                  // Right rail
                  Positioned(
                    right: 8,
                    bottom: 120,
                    child: RightRail(
                      avatarUrl: 'https://i.pravatar.cc/150?img=${item.author.hashCode % 70}',
                      liked: item.liked,
                      likes: item.likes,
                      comments: item.comments,
                      saves: saved ? 1631 : 1630,
                      shares: 327,
                      saved: saved,
                      following: following,
                      onAvatarTap: () => _navigateToProfile(item.author),
                      onUploadTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShortsRecorderPage()),
                        );
                      },
                      onLike: () => _toggleLike(index),
                      onComment: () => _openComments(item, index),
                      onSave: () => _toggleSave(index),
                      onShare: () => _openShareSheet(item),
                      onFollow: () => _toggleFollow(item.author),
                    ),
                  ),

                  // Caption + music + pill
                  Positioned(
                    left: 16,
                    right: 96,
                    bottom: 86,
                    child: CaptionWidget(
                      caption: item.caption,
                      music: 'THÀNH TRƯỞNG',
                      source: 'CapCut',
                      label: 'Thử mẫu này',
                    ),
                  ),

                  // progress seek bar (tap/drag)
                  if (dur > 0)
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 74,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.5,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                        ),
                        child: Slider(
                          min: 0,
                          max: dur,
                          value: pos.clamp(0, dur),
                          onChanged: (v) => _seekTo(index, v),
                          activeColor: Colors.white,
                          inactiveColor: Colors.white24,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Bottom nav bar (overlay)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomShortsBar(
              inboxBadge: 8,
             onTap: (i) {
                  if (i == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShortsRecorderPage()),
                    );
                  }
                },

            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
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
import '../core/video_controller_pool.dart';
import '../data/local_shorts_store.dart';
import '../shortvideo_routes.dart';
import 'moderation_sheet.dart';

/// Generic player page that can show videos from different contexts
class ShortVideoPlayerPage extends StatefulWidget {
  const ShortVideoPlayerPage({super.key});

  static const routeName = ShortVideoRoutes.player;

  @override
  State<ShortVideoPlayerPage> createState() => _ShortVideoPlayerPageState();
}

class _ShortVideoPlayerPageState extends State<ShortVideoPlayerPage> {
  final MuteService _muteService = MuteService.instance;
  final FollowService _followService = FollowService.instance;
  final SaveService _saveService = SaveService.instance;
  final VideoControllerPool _controllerPool = VideoControllerPool();
  final LocalShortsStore _localStore = LocalShortsStore.instance;

  List<ShortVideo> _videos = [];
  int _currentIndex = 0;
  String? _contextType; // 'feed', 'profile', 'hashtag', 'sound', 'search'
  bool _muted = false;

  final Map<int, Duration> _durations = {};
  final Map<int, Duration> _positions = {};
  final Map<String, bool> _savedVideos = {};
  final Map<String, bool> _followingUsers = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _videos = (args?['videos'] as List?)?.cast<ShortVideo>() ?? [];
    _currentIndex = args?['initialIndex'] as int? ?? 0;
    _contextType = args?['contextType'] as String? ?? 'feed';
    _loadMuteState();
  }

  Future<void> _loadMuteState() async {
    final muted = await _muteService.isMuted();
    setState(() => _muted = muted);
  }

  Future<void> _toggleMute() async {
    final newMuted = await _muteService.toggle();
    setState(() => _muted = newMuted);
  }

  void _loadMoreIfNeeded(int index) {
    setState(() => _currentIndex = index);
    _controllerPool.cleanupIdle();
  }

  void _toggleLike(int index) {
    setState(() {
      final v = _videos[index];
      _videos[index] = v.copyWith(
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
              _videos[index] = v.copyWith(comments: newCount);
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
    final video = _videos[index];
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

  void _showModerationSheet(ShortVideo video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ModerationSheet(
        videoId: video.id,
        creatorId: video.author,
      ),
    );
  }

  void _seekTo(int index, double valueSec) {
    final video = _videos[index];
    _controllerPool.getController(video.videoUrl).then((controller) {
      if (controller != null && controller.value.isInitialized) {
        controller.seekTo(Duration(milliseconds: (valueSec * 1000).toInt()));
      }
    });
  }

  @override
  void dispose() {
    _controllerPool.disposeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videos.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Video'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Không có video', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: PageController(initialPage: _currentIndex),
            scrollDirection: Axis.vertical,
            itemCount: _videos.length,
            onPageChanged: _loadMoreIfNeeded,
            itemBuilder: (context, index) {
              final item = _videos[index];
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
                    onController: (c) async {
                      final poolController = await _controllerPool.getController(item.videoUrl);
                      if (poolController != null && poolController.value.isInitialized) {
                        poolController.setVolume(_muted ? 0.0 : 1.0);
                      }
                    },
                    onReady: (d) => setState(() => _durations[index] = d),
                    onProgress: (p) => setState(() => _positions[index] = p),
                    onError: (hasError) {},
                    onRetry: () async {
                      await _controllerPool.getController(item.videoUrl);
                    },
                  ),
                  // Mute button
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
                  // Top tabs (only for feed context)
                  if (_contextType == 'feed')
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
                        Navigator.pushNamed(context, ShortVideoRoutes.upload);
                      },
                      onLike: () => _toggleLike(index),
                      onComment: () => _openComments(item, index),
                      onSave: () => _toggleSave(index),
                      onShare: () => _openShareSheet(item),
                      onFollow: () => _toggleFollow(item.author),
                      onMore: () => _showModerationSheet(item),
                    ),
                  ),
                  // Caption
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
                  // Progress bar
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
          // Bottom bar (only for feed context)
          if (_contextType == 'feed')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomShortsBar(
                inboxBadge: 8,
                onTap: (i) {
                  if (i == 2) {
                    Navigator.pushNamed(context, ShortVideoRoutes.upload);
                  } else if (i == 3) {
                    Navigator.pushNamed(context, ShortVideoRoutes.inbox);
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}


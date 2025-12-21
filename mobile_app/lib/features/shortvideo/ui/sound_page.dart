import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../data/local_shorts_store.dart';
import '../core/sound_service.dart';
import '../shortvideo_routes.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  static const routeName = ShortVideoRoutes.sound;

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final ShortVideoService _service = ShortVideoService();
  final LocalShortsStore _localStore = LocalShortsStore.instance;
  final SoundService _soundService = SoundService.instance;
  
  String? _soundId;
  String? _soundName;
  bool _loading = true;
  String? _errorMessage;
  List<ShortVideo> _videos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _soundId = args?['soundId'] as String?;
    _soundName = args?['soundName'] as String? ?? 
                  args?['soundId'] as String? ?? 
                  'BrainBattle Mix';
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Add to recent sounds
      if (_soundId != null) {
        await _soundService.addRecent(_soundId!, _soundName!);
      }

      // Load videos from API and local
      final remoteVideos = await _service.fetchFeed(page: 1);
      final localVideos = await _localStore.listFeedPosts();
      final allVideos = [...localVideos, ...remoteVideos];

      // Filter by sound (mock: all videos use same sound for now)
      // In real app, filter by soundId
      final filtered = allVideos.where((v) =>
          v.music.toLowerCase().contains(_soundName!.toLowerCase())).toList();

      if (mounted) {
        setState(() {
          _videos = filtered.isEmpty ? allVideos.take(6).toList() : filtered;
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

  void _useSound() {
    Navigator.pushNamed(
      context,
      ShortVideoRoutes.upload,
      arguments: {
        'preselectedSound': {
          'id': _soundId ?? _soundName,
          'name': _soundName,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Âm thanh'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? ShortsErrorState(
                  message: _errorMessage!,
                  onRetry: _loadVideos,
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.music_note, size: 64, color: Colors.pinkAccent),
                            const SizedBox(height: 16),
                            Text(
                              _soundName ?? 'Unknown Sound',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isDark ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_videos.length} videos',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _useSound,
                              icon: const Icon(Icons.add),
                              label: const Text('Sử dụng âm thanh này'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pinkAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Videos list
                      if (_videos.isEmpty)
                        ShortsEmptyState(message: 'Không có video sử dụng âm thanh này')
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _videos.length,
                          itemBuilder: (context, index) {
                            final video = _videos[index];
                            return ListTile(
                              leading: Image.network(
                                video.thumbnailUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.video_library),
                                ),
                              ),
                              title: Text(video.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                              subtitle: Text('@${video.author} · ${video.likes} likes'),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  ShortVideoRoutes.player,
                                  arguments: {
                                    'videos': _videos,
                                    'initialIndex': index,
                                    'contextType': 'sound',
                                    'soundId': _soundId,
                                  },
                                );
                              },
                            );
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}


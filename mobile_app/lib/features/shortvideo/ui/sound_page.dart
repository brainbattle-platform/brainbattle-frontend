import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../shortvideo_routes.dart';

class SoundPage extends StatefulWidget {
  const SoundPage({super.key});

  static const routeName = ShortVideoRoutes.sound;

  @override
  State<SoundPage> createState() => _SoundPageState();
}

class _SoundPageState extends State<SoundPage> {
  final ShortVideoService _service = ShortVideoService();
  String? _soundName;
  bool _loading = true;
  List<ShortVideo> _videos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _soundName = args?['soundName'] as String? ?? 
                  args?['soundId'] as String? ?? 
                  'BrainBattle Mix';
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _loading = true);
    // Mock: all videos use same sound
    final allVideos = await _service.fetchFeed(page: 1);
    
    setState(() {
      _videos = allVideos.take(6).toList();
      _loading = false;
    });
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
                          onPressed: () {
                            // TODO: Use this sound in recorder
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sử dụng âm thanh này (stub)')),
                            );
                          },
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
                        ),
                        title: Text(video.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('@${video.author} · ${video.likes} likes'),
                        onTap: () {
                          // TODO: Navigate to video in feed
                          Navigator.pop(context);
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


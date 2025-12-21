import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../shortvideo_routes.dart';

class HashtagPage extends StatefulWidget {
  const HashtagPage({super.key});

  static const routeName = ShortVideoRoutes.hashtag;

  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> {
  final ShortVideoService _service = ShortVideoService();
  String? _tag;
  bool _loading = true;
  List<ShortVideo> _videos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _tag = args?['tag'] as String? ?? '';
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    setState(() => _loading = true);
    // Mock: filter videos by hashtag
    final allVideos = await _service.fetchFeed(page: 1);
    final filtered = allVideos.where((v) =>
        v.caption.toLowerCase().contains('#$_tag'.toLowerCase())).toList();
    
    setState(() {
      _videos = filtered.isEmpty ? allVideos.take(6).toList() : filtered;
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
        title: Text('#$_tag'),
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
                        Text(
                          '#$_tag',
                          style: theme.textTheme.headlineMedium?.copyWith(
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
                      ],
                    ),
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
                          // TODO: Navigate to feed at this video
                          Navigator.pop(context);
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


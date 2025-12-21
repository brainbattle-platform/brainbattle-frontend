import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../shortvideo_routes.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({super.key});

  static const routeName = ShortVideoRoutes.editor;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  final Trimmer _trimmer = Trimmer();
  VideoPlayerController? _previewController;
  String? _videoPath;
  double _startValue = 0.0;
  double _endValue = 1.0;
  bool _isPlaying = false;
  bool _isExporting = false;
  String? _selectedCoverPath;
  List<String> _coverOptions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _videoPath = args?['videoPath'] as String?;
    if (_videoPath != null) {
      _loadVideo();
    }
  }

  Future<void> _loadVideo() async {
    if (_videoPath == null) return;

    await _trimmer.loadVideo(videoFile: File(_videoPath!));
    
    // Generate cover options
    await _generateCoverOptions();

    // Initialize preview with original video first
    _previewController = VideoPlayerController.file(File(_videoPath!))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });

    setState(() {});
  }

  Future<void> _generateCoverOptions() async {
    if (_videoPath == null) return;

    final videoFile = File(_videoPath!);
    if (!videoFile.existsSync()) return;

    _coverOptions.clear();
    final tempDir = await getTemporaryDirectory();

    // Generate 5 thumbnails at different timestamps
    for (int i = 0; i < 5; i++) {
      try {
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: _videoPath!,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          timeMs: (i * 1000).toInt(), // 0s, 1s, 2s, 3s, 4s
          quality: 75,
        );
        if (thumbnail != null) {
          _coverOptions.add(thumbnail);
        }
      } catch (e) {
        debugPrint('Error generating thumbnail: $e');
      }
    }

    if (_coverOptions.isNotEmpty) {
      _selectedCoverPath = _coverOptions[0];
    }

    setState(() {});
  }

  Future<void> _updatePreview() async {
    if (_videoPath == null) return;
    
    // Preview uses original video with trim values applied in UI
    // Actual trimming happens on export
    if (mounted && _isPlaying) {
      await _previewController?.play();
    }
  }

  Future<void> _exportVideo() async {
    if (_videoPath == null || _selectedCoverPath == null) return;

    setState(() => _isExporting = true);

    try {
      // Export trimmed video
      String? outputPath;
      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (path) {
          outputPath = path;
        },
      );
      
      if (outputPath != null && _selectedCoverPath != null) {
        // Copy to app directory with UUID
        final appDir = await getApplicationDocumentsDirectory();
        final videosDir = Directory('${appDir.path}/shorts_videos');
        if (!videosDir.existsSync()) {
          await videosDir.create(recursive: true);
        }

        final uuid = const Uuid().v4();
        final targetVideo = File('${videosDir.path}/$uuid.mp4');
        await File(outputPath!).copy(targetVideo.path);

        // Copy cover
        final coversDir = Directory('${appDir.path}/shorts_covers');
        if (!coversDir.existsSync()) {
          await coversDir.create(recursive: true);
        }
        final targetCover = File('${coversDir.path}/$uuid.jpg');
        await File(_selectedCoverPath!).copy(targetCover.path);

        if (mounted) {
          Navigator.pushNamed(
            context,
            ShortVideoRoutes.post,
            arguments: {
              'videoPath': targetVideo.path,
              'coverPath': targetCover.path,
              'videoId': uuid,
            },
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất video: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  void dispose() {
    _trimmer.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_videoPath == null) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(title: const Text('Editor')),
        body: const Center(child: Text('Không có video')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Chỉnh sửa video'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          if (_isExporting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _exportVideo,
              child: const Text('Tiếp tục'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Preview
          Expanded(
            child: _previewController != null &&
                    _previewController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _previewController!.value.aspectRatio,
                    child: VideoPlayer(_previewController!),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
          // Trim slider
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(seconds: 60),
                  onChangeStart: (value) {
                    setState(() => _startValue = value);
                    _updatePreview();
                  },
                  onChangeEnd: (value) {
                    setState(() => _endValue = value);
                    _updatePreview();
                  },
                  onChangePlaybackState: (value) {
                    setState(() => _isPlaying = value);
                    if (value) {
                      _previewController?.play();
                    } else {
                      _previewController?.pause();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Cover selection
                if (_coverOptions.isNotEmpty) ...[
                  const Text('Chọn ảnh bìa:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _coverOptions.length,
                      itemBuilder: (context, index) {
                        final coverPath = _coverOptions[index];
                        final isSelected = _selectedCoverPath == coverPath;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedCoverPath = coverPath);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.pinkAccent
                                    : Colors.transparent,
                                width: 3,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.file(
                                File(coverPath),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


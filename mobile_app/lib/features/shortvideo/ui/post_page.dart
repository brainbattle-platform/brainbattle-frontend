import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/video_post_model.dart';
import '../data/local_shorts_store.dart';
import '../shortvideo_routes.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  static const routeName = ShortVideoRoutes.post;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _captionController = TextEditingController();
  final LocalShortsStore _store = LocalShortsStore.instance;

  String? _videoPath;
  String? _coverPath;
  String? _videoId;
  PrivacyLevel _privacy = PrivacyLevel.public;
  bool _allowComments = true;
  bool _isPosting = false;

  // Mock current user ID (in real app, get from auth)
  final String _currentUserId = 'current_user';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _videoPath = args?['videoPath'] as String?;
    _coverPath = args?['coverPath'] as String?;
    _videoId = args?['videoId'] as String? ?? const Uuid().v4();
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!.substring(1)).toList();
  }

  Future<void> _post() async {
    if (_videoPath == null) return;

    final caption = _captionController.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mô tả')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final hashtags = _extractHashtags(caption);

      final post = VideoPost(
        id: _videoId!,
        videoPath: _videoPath!,
        coverPath: _coverPath,
        caption: caption,
        hashtags: hashtags,
        createdAt: DateTime.now(),
        creatorId: _currentUserId,
        privacy: _privacy,
        allowComments: _allowComments,
      );

      await _store.addPost(post);

      if (mounted) {
        // Navigate to profile to see new video
        Navigator.pushNamedAndRemoveUntil(
          context,
          ShortVideoRoutes.profile,
          (route) => route.isFirst,
          arguments: {'userId': _currentUserId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng video: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Đăng video'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        actions: [
          if (_isPosting)
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
              onPressed: _post,
              child: const Text('Đăng'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video preview
            if (_coverPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_coverPath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.video_library),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            // Caption
            TextField(
              controller: _captionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Viết mô tả...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1C1C1C) : Colors.grey[100],
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 24),
            // Privacy
            Text(
              'Quyền riêng tư',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PrivacyLevel>(
              value: _privacy,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1C1C1C) : Colors.grey[100],
              ),
              items: PrivacyLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _privacy = value);
                }
              },
            ),
            const SizedBox(height: 16),
            // Allow comments
            SwitchListTile(
              title: const Text('Cho phép bình luận'),
              value: _allowComments,
              onChanged: (value) => setState(() => _allowComments = value),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../data/models/profile_models.dart';

class ProfileVideoGrid extends StatelessWidget {
  final List<VideoPreview> videos;
  final ValueChanged<VideoPreview> onVideoTap;

  const ProfileVideoGrid({
    super.key,
    required this.videos,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text('No videos yet'),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return _VideoGridItem(
          video: video,
          onTap: () => onVideoTap(video),
        );
      },
    );
  }
}

class _VideoGridItem extends StatelessWidget {
  final VideoPreview video;
  final VoidCallback onTap;

  const _VideoGridItem({
    required this.video,
    required this.onTap,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFFF8FAB);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder thumbnail (pink background)
          Container(
            color: pinkColor.withOpacity(0.3),
            child: video.thumbnailUrl != null
                ? Image.network(
                    video.thumbnailUrl!,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.video_library,
                    color: Color(0xFFFF8FAB),
                    size: 32,
                  ),
          ),
          // Gradient overlay
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                ),
              ),
            ),
          ),
          // View count overlay (bottom left)
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_arrow,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatViewCount(video.viewCount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Duration overlay (bottom right, optional)
          if (video.durationSec > 0)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDuration(video.durationSec),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


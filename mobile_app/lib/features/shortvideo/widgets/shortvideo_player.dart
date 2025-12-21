import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class ShortVideoPlayer extends StatefulWidget {
  final String url;
  final String thumbnail;
  final bool muted; // Mute state from parent
  final VoidCallback? onRetry; // Retry callback for errors

  // báo cho parent biết tổng thời lượng & controller để seek/volume
  final ValueChanged<Duration>? onReady;
  final ValueChanged<VideoPlayerController>? onController;
  final ValueChanged<Duration>? onProgress;
  final ValueChanged<bool>? onError; // Report errors
  final VideoPlayerController? externalController; // Optional: use external pool controller

  const ShortVideoPlayer({
    super.key,
    required this.url,
    required this.thumbnail,
    this.muted = false,
    this.onRetry,
    this.onReady,
    this.onController,
    this.onProgress,
    this.onError,
    this.externalController,
  });

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  VideoPlayerController? _controller;
  bool _showHeart = false;
  bool _hasError = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    // Use external controller if provided
    if (widget.externalController != null) {
      _controller = widget.externalController;
      if (_controller!.value.isInitialized) {
        await _controller!.setVolume(widget.muted ? 0.0 : 1.0);
        widget.onController?.call(_controller!);
        widget.onReady?.call(_controller!.value.duration);
        _controller!.addListener(_onProgressUpdate);
        setState(() {
          _isInitializing = false;
        });
        return;
      }
    }

    if (_controller != null && widget.externalController == null) {
      await _controller!.dispose();
    }

    setState(() {
      _isInitializing = true;
      _hasError = false;
    });

    try {
      // Check if URL is file path (local) or network URL
      final isLocalFile = !widget.url.startsWith('http://') && !widget.url.startsWith('https://');
      
      if (isLocalFile) {
        _controller = VideoPlayerController.file(File(widget.url))
          ..setLooping(true);
      } else {
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
          ..setLooping(true);
      }

      await _controller!.initialize();
      
      if (!mounted) return;

      // Apply mute state
      await _controller!.setVolume(widget.muted ? 0.0 : 1.0);

      widget.onController?.call(_controller!);
      widget.onReady?.call(_controller!.value.duration);
      
      setState(() {
        _isInitializing = false;
      });

      await _controller!.play();

      _controller!.addListener(_onProgressUpdate);
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
        widget.onError?.call(true);
      }
    }
  }

  void _onProgressUpdate() {
    if (_controller != null && 
        _controller!.value.isInitialized && 
        widget.onProgress != null) {
      widget.onProgress!.call(_controller!.value.position);
    }
  }

  @override
  void didUpdateWidget(ShortVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update mute state if changed
    if (oldWidget.muted != widget.muted && _controller != null) {
      _controller!.setVolume(widget.muted ? 0.0 : 1.0);
    }
    // Retry if error and retry requested
    if (_hasError && widget.onRetry != null && oldWidget.onRetry == null) {
      _initController();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onProgressUpdate);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _handleRetry() async {
    await _initController();
  }

  void _doubleTapLike() {
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 700),
        () => mounted ? setState(() => _showHeart = false) : null);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('vp-${widget.url}'),
      onVisibilityChanged: (info) {
        if (_controller == null || !_controller!.value.isInitialized) return;
        final visible = info.visibleFraction > 0.6;
        if (visible && !_controller!.value.isPlaying) {
          _controller!.play();
        } else if (!visible && _controller!.value.isPlaying) {
          _controller!.pause();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(imageUrl: widget.thumbnail, fit: BoxFit.cover),
          if (_isInitializing)
            const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            ),
          if (_hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.white70),
                  const SizedBox(height: 16),
                  const Text(
                    'Không thể tải video',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          if (!_hasError && !_isInitializing && _controller != null && _controller!.value.isInitialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: VideoPlayer(_controller!),
              ),
            ),
          if (!_hasError)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _togglePlayPause,
              onDoubleTap: _doubleTapLike,
            ),
          if (!_hasError && _controller != null && !_controller!.value.isPlaying && !_isInitializing)
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: const Center(
                  child: Icon(Icons.play_arrow, size: 72, color: Colors.white70),
                ),
              ),
            ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showHeart ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: const Center(
                child: Icon(Icons.favorite,
                    color: Colors.pinkAccent, size: 120),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

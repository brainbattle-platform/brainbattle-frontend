import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';

/// Manages video controller pool for preloading and memory efficiency
class VideoControllerPool {
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, DateTime> _lastUsed = {};
  static const int _maxControllers = 3; // current + next + prev
  static const Duration _idleTimeout = Duration(seconds: 30);

  /// Get or create controller for video URL
  Future<VideoPlayerController?> getController(String url, {bool preload = false}) async {
    if (_controllers.containsKey(url)) {
      _lastUsed[url] = DateTime.now();
      return _controllers[url];
    }

    // Cleanup old controllers if pool is full
    if (_controllers.length >= _maxControllers) {
      await _cleanupOldest();
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url))
        ..setLooping(true);

      if (preload) {
        // Preload: initialize but don't play
        await controller.initialize();
      } else {
        await controller.initialize();
        await controller.play();
      }

      _controllers[url] = controller;
      _lastUsed[url] = DateTime.now();

      if (kDebugMode) {
        debugPrint('[VideoPool] Created controller for $url (total: ${_controllers.length})');
      }

      return controller;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[VideoPool] Failed to create controller for $url: $e');
      }
      return null;
    }
  }

  /// Dispose controller for URL
  Future<void> disposeController(String url) async {
    final controller = _controllers.remove(url);
    _lastUsed.remove(url);
    await controller?.dispose();

    if (kDebugMode) {
      debugPrint('[VideoPool] Disposed controller for $url (remaining: ${_controllers.length})');
    }
  }

  /// Cleanup oldest unused controller
  Future<void> _cleanupOldest() async {
    if (_controllers.isEmpty) return;

    // Find oldest unused
    String? oldestUrl;
    DateTime? oldestTime;

    for (final entry in _lastUsed.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestUrl = entry.key;
      }
    }

    if (oldestUrl != null) {
      await disposeController(oldestUrl);
    }
  }

  /// Cleanup idle controllers
  Future<void> cleanupIdle() async {
    final now = DateTime.now();
    final toRemove = <String>[];

    for (final entry in _lastUsed.entries) {
      if (now.difference(entry.value) > _idleTimeout) {
        toRemove.add(entry.key);
      }
    }

    for (final url in toRemove) {
      await disposeController(url);
    }
  }

  /// Dispose all controllers
  Future<void> disposeAll() async {
    for (final controller in _controllers.values) {
      await controller.dispose();
    }
    _controllers.clear();
    _lastUsed.clear();

    if (kDebugMode) {
      debugPrint('[VideoPool] Disposed all controllers');
    }
  }

  /// Get current controller count (for debugging)
  int get controllerCount => _controllers.length;
}


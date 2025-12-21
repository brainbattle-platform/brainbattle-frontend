import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../../core/theme/app_theme.dart';
import '../../../domain/exercise_model.dart';

class ListeningExercise extends StatefulWidget {
  final ExerciseItem exercise;
  final Function(String answer) onAnswer;

  const ListeningExercise({
    super.key,
    required this.exercise,
    required this.onAnswer,
  });

  @override
  State<ListeningExercise> createState() => _ListeningExerciseState();
}

class _ListeningExerciseState extends State<ListeningExercise> {
  String? _selectedAnswer;
  bool _isPlaying = false;
  AudioPlayer? _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  String? _audioError;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.questionAudio != null) {
      _initAudioPlayer();
    }
  }

  Future<void> _initAudioPlayer() async {
    if (widget.exercise.questionAudio == null) return;

    setState(() {
      _isLoading = true;
      _audioError = null;
    });

    _audioPlayer = AudioPlayer();
    try {
      await _audioPlayer!.setUrl(widget.exercise.questionAudio!);
      _audioPlayer!.durationStream.listen((duration) {
        if (mounted && duration != null) {
          setState(() => _duration = duration);
        }
      });
      _audioPlayer!.positionStream.listen((position) {
        if (mounted) {
          setState(() => _position = position);
        }
      });
      _audioPlayer!.playerStateStream.listen((state) {
        if (mounted) {
          if (state.processingState == ProcessingState.completed) {
            setState(() => _isPlaying = false);
          }
          if (state.processingState == ProcessingState.ready) {
            setState(() => _isLoading = false);
          }
        }
      });
    } catch (e) {
      debugPrint('Error loading audio: $e');
      if (mounted) {
        setState(() {
          _audioError = 'Failed to load audio';
          _isLoading = false;
        });
      }
      _audioPlayer?.dispose();
      _audioPlayer = null;
    }
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (widget.exercise.questionAudio == null) {
      // Stub mode - just toggle visual state
      setState(() => _isPlaying = !_isPlaying);
      return;
    }

    if (_audioError != null) {
      // Retry on error
      await _initAudioPlayer();
      return;
    }

    if (_audioPlayer == null) {
      await _initAudioPlayer();
      if (_audioPlayer == null) return; // Still failed
    }

    try {
      if (_isPlaying) {
        await _audioPlayer?.pause();
      } else {
        await _audioPlayer?.play();
      }
      if (mounted) {
        setState(() => _isPlaying = !_isPlaying);
      }
    } catch (e) {
      debugPrint('Error during playback: $e');
      if (mounted) {
        setState(() {
          _audioError = 'Playback error';
          _isPlaying = false;
        });
      }
    }
  }

  Future<void> _requestMicPermission() async {
    final status = await Permission.microphone.request();
    if (status.isDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
    } else if (status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission granted (speaking feature stub)')),
        );
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission'),
        content: const Text(
          'Microphone permission is required for speaking exercises. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? BBColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
            ),
          ),
          child: Column(
            children: [
              Text(
                widget.exercise.question,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              // Audio player
              if (widget.exercise.questionAudio != null) ...[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : IconButton(
                          icon: Icon(
                            _audioError != null
                                ? Icons.error_outline
                                : (_isPlaying ? Icons.pause : Icons.play_arrow),
                            size: 40,
                            color: _audioError != null
                                ? Colors.red
                                : theme.colorScheme.primary,
                          ),
                          onPressed: _togglePlayback,
                        ),
                ),
                if (_audioError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _audioError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: _togglePlayback,
                    child: const Text('Retry'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
                if (_duration.inSeconds > 0) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Slider(
                          value: _duration.inSeconds > 0
                              ? _position.inSeconds.toDouble()
                              : 0.0,
                          max: _duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            _audioPlayer?.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _requestMicPermission,
                  icon: const Icon(Icons.mic),
                  label: const Text('Speak (stub)'),
                ),
              ] else ...[
                // Stub UI when no audio
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () {
                      setState(() => _isPlaying = !_isPlaying);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Audio playback (stub)',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Options (same as MCQ)
        ...widget.exercise.options.map((option) {
          final isSelected = _selectedAnswer == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedAnswer = option);
                widget.onAnswer(option);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : (isDark ? BBColors.darkCard : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? Colors.white10 : Colors.black12),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.white30 : Colors.black26),
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}


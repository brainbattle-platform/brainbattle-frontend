import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../shortvideo_routes.dart';

enum CaptureLength { s15, s60, m10 }
enum CaptureMode { video, photo, text }

class ShortsRecorderPage extends StatefulWidget {
  const ShortsRecorderPage({super.key});

  @override
  State<ShortsRecorderPage> createState() => _ShortsRecorderPageState();
}

class _ShortsRecorderPageState extends State<ShortsRecorderPage> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0; // 0: back; 1: front (tuỳ máy)
  bool _flashOn = false;
  bool _recording = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  CaptureLength _length = CaptureLength.s15;
  CaptureMode _mode = CaptureMode.video;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(index: _cameraIndex);
    }
  }

  Future<void> _initCamera({int index = 0}) async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy camera')),
          );
        }
        return;
      }
      index = index.clamp(0, _cameras.length - 1);
      final cam = _cameras[index];
      final ctrl = CameraController(
        cam,
        ResolutionPreset.high,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await ctrl.initialize();
      await ctrl.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) return;
      setState(() {
        _controller?.dispose();
        _controller = ctrl;
        _cameraIndex = index;
      });
      await _applyFlash();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi camera: $e')),
        );
      }
    }
  }

  Future<void> _applyFlash() async {
  final c = _controller;
  if (c == null) return;
  try {
    // Một số máy không hỗ trợ torch ở camera đang dùng → sẽ ném CameraException
    await c.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
  } on CameraException {
    // Không hỗ trợ: tắt trạng thái flash để tránh lỗi lặp lại
    if (mounted) setState(() => _flashOn = false);
  }
}


  Duration get _maxDuration {
    switch (_length) {
      case CaptureLength.s15: return const Duration(seconds: 15);
      case CaptureLength.s60: return const Duration(seconds: 60);
      case CaptureLength.m10: return const Duration(minutes: 10);
    }
  }

  Future<void> _startRecord() async {
    final c = _controller;
    if (c == null || _recording) return;
    try {
      _elapsed = Duration.zero;
      setState(() => _recording = true);

      // Đếm thời gian
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 200), (t) async {
        _elapsed += const Duration(milliseconds: 200);
        if (_elapsed >= _maxDuration) {
          await _stopRecord();
        } else {
          setState(() {});
        }
      });

      await c.startVideoRecording();
    } catch (e) {
      setState(() => _recording = false);
    }
  }

  Future<void> _stopRecord() async {
    final c = _controller;
    if (c == null || !_recording) return;
    try {
      _timer?.cancel();
      final file = await c.stopVideoRecording();
      setState(() => _recording = false);

      final dir = await getTemporaryDirectory();
      final target = p.join(dir.path, 'bb_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await File(file.path).copy(target);

      if (!mounted) return;
      
      // Navigate to editor
      Navigator.pushNamed(
        context,
        ShortVideoRoutes.editor,
        arguments: {'videoPath': target},
      );
    } catch (e) {
      setState(() => _recording = false);
    }
  }

  Future<void> _takePhoto() async {
    final c = _controller;
    if (c == null || _recording) return;
    try {
      final x = await c.takePicture();
      final dir = await getTemporaryDirectory();
      final target = p.join(dir.path, 'bb_photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(x.path).copy(target);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã chụp ảnh tạm: $target')),
      );
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    final next = (_cameraIndex + 1) % _cameras.length;
    await _initCamera(index: next);
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: c == null || !c.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
              children: [
                // Preview full-screen (cover, không bị dồn lên trên)
                  Positioned.fill(
                    child: ClipRect(
                      child: Transform.scale(
                        // scale để cover theo tỉ lệ màn hình
                        scale: (() {
                          final device = MediaQuery.of(context).size.aspectRatio; // w/h (≈0.56)
                          final preview = c.value.aspectRatio;                      // (≈1.77)
                          final s = preview / device;                               // >1 là cần phóng
                          return s < 1 ? 1 / s : s;                                 // luôn >=1
                        })(),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: c.value.aspectRatio,
                            child: CameraPreview(c),
                          ),
                        ),
                      ),
                    ),
                  ),


                // Top: close + thêm âm thanh
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.music_note, color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text('Thêm âm thanh', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // cân đối
                      ],
                    ),
                  ),
                ),

                // Right vertical toolbar
                Positioned(
                  right: 10,
                  top: 120,
                  child: Column(
                    children: [
                      _roundIcon(
                        icon: Icons.cameraswitch,
                        onTap: _switchCamera,
                      ),
                      const SizedBox(height: 14),
                      _roundIcon(
                        icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                        onTap: () async {
                          setState(() => _flashOn = !_flashOn);
                          await _applyFlash();
                        },
                      ),
                      const SizedBox(height: 14),
                      _roundIcon(icon: Icons.grid_on, onTap: () {}), // lưới (demo)
                      const SizedBox(height: 14),
                      _roundIcon(icon: Icons.timer, onTap: () {}), // hẹn giờ (demo)
                      const SizedBox(height: 14),
                      _roundIcon(icon: Icons.auto_awesome, onTap: () {}), // beauty/effects
                    ],
                  ),
                ),

                // Length selector (15s/60s/10p)
                Positioned(
                  left: 12,
                  bottom: 210,
                  child: Row(
                    children: [
                      _lenChip('10 phút', CaptureLength.m10),
                      const SizedBox(width: 10),
                      _lenChip('60s', CaptureLength.s60),
                      const SizedBox(width: 10),
                      _lenChip('15s', CaptureLength.s15),
                    ],
                  ),
                ),

                // Bottom controls
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 22,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        // Mode selector: ẢNH / VĂN BẢN (demo)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _modeChip('ẢNH', CaptureMode.photo),
                            const SizedBox(width: 12),
                            _modeChip('VĂN BẢN', CaptureMode.text),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Capture row: gallery, button, effects avatars (demo)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _smallTile(icon: Icons.image, label: '', onTap: () {}),
                            GestureDetector(
                              onTap: () async {
                                if (_mode == CaptureMode.photo) {
                                  await _takePhoto();
                                } else {
                                  _recording ? await _stopRecord() : await _startRecord();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 84, height: 84,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 6),
                                    ),
                                  ),
                                  Container(
                                    width: 62, height: 62,
                                    decoration: BoxDecoration(
                                      color: _recording ? Colors.redAccent : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _smallTile(icon: Icons.face_retouching_natural, label: '', onTap: () {}),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Bottom Tab: BÀI ĐĂNG / LIVE / SÁNG TẠO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _BottomTabLabel(text: 'BÀI ĐĂNG', active: true),
                            _BottomTabLabel(text: 'LIVE'),
                            _BottomTabLabel(text: 'SÁNG TẠO'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Timer + progress khi đang quay
                if (_recording)
                  Positioned(
                    top: 70,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _format(_elapsed),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _lenChip(String label, CaptureLength value) {
    final sel = _length == value;
    return GestureDetector(
      onTap: () => setState(() => _length = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(sel ? 0.7 : 0.35),
          borderRadius: BorderRadius.circular(20),
          border: sel ? Border.all(color: Colors.white, width: 1.2) : null,
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _modeChip(String label, CaptureMode value) {
    final sel = _mode == value;
    return GestureDetector(
      onTap: () => setState(() => _mode = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(sel ? 0.75 : 0.35),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _smallTile({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          if (label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(label, style: const TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }
}
class _CoverPreview extends StatelessWidget {
  final CameraController controller;
  const _CoverPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // tỉ lệ khung hình do camera cung cấp (ví dụ 16/9 = 1.777...)
        final aspect = controller.value.aspectRatio;

        // Dùng FittedBox để phóng choáng toàn bộ khung theo chiều cao
        return FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxHeight * aspect,
            child: CameraPreview(controller),
          ),
        );
      },
    );
  }
}


class _BottomTabLabel extends StatelessWidget {
  final String text;
  final bool active;
  const _BottomTabLabel({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: active ? Colors.white : Colors.white70,
        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }
}

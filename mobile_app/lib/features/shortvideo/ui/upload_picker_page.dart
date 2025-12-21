import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../shortvideo_routes.dart';
import 'shorts_recorder_page.dart';

class UploadPickerPage extends StatefulWidget {
  const UploadPickerPage({super.key});

  static const routeName = ShortVideoRoutes.upload;

  @override
  State<UploadPickerPage> createState() => _UploadPickerPageState();
}

class _UploadPickerPageState extends State<UploadPickerPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _requestPermission() async {
    // Request video permission based on Android version
    PermissionStatus status;
    if (await Permission.videos.isGranted) {
      status = PermissionStatus.granted;
    } else {
      status = await Permission.videos.request();
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        _showPermissionDialog();
      }
      return;
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền truy cập'),
        content: const Text(
          'Ứng dụng cần quyền truy cập video để bạn có thể chọn video từ thư viện.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    await _requestPermission();

    final status = await Permission.videos.status;
    if (!status.isGranted) {
      return;
    }

    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );

      if (video != null && mounted) {
        Navigator.pushNamed(
          context,
          ShortVideoRoutes.editor,
          arguments: {'videoPath': video.path},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi chọn video: $e')),
        );
      }
    }
  }

  void _openRecorder() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ShortsRecorderPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Tạo video'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Record option
            _OptionCard(
              icon: Icons.videocam,
              title: 'Quay video',
              subtitle: 'Quay video mới',
              onTap: _openRecorder,
            ),
            const SizedBox(height: 24),
            // Gallery option
            _OptionCard(
              icon: Icons.photo_library,
              title: 'Chọn từ thư viện',
              subtitle: 'Chọn video có sẵn',
              onTap: _pickFromGallery,
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1C) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.pinkAccent),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


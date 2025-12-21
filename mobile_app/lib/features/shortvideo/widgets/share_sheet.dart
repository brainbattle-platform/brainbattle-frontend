import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShareSheet extends StatelessWidget {
  final String videoId;
  final String videoUrl;

  const ShareSheet({
    super.key,
    required this.videoId,
    required this.videoUrl,
  });

  Future<void> _copyLink(BuildContext context) async {
    // TODO: Generate real shareable link
    final link = 'https://brainbattle.app/shorts/$videoId';
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép liên kết'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _shareTo(BuildContext context, String platform) {
    // TODO: Implement platform-specific sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chia sẻ đến $platform (stub)')),
    );
    Navigator.pop(context);
  }

  void _report(BuildContext context) {
    // TODO: Implement report flow
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo'),
        content: const Text('Tính năng báo cáo đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Chia sẻ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Options
            ListTile(
              leading: const Icon(Icons.link, color: Colors.blue),
              title: const Text('Sao chép liên kết'),
              onTap: () => _copyLink(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: const Text('Chia sẻ đến...'),
              subtitle: const Text('Facebook, WhatsApp, v.v. (stub)'),
              onTap: () => _shareTo(context, 'Social'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Báo cáo'),
              onTap: () {
                Navigator.pop(context);
                _report(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


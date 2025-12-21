import 'package:flutter/material.dart';
import '../data/local_shorts_store.dart';

class ModerationSheet extends StatelessWidget {
  final String videoId;
  final String? creatorId;

  const ModerationSheet({
    super.key,
    required this.videoId,
    this.creatorId,
  });

  Future<void> _report(BuildContext context, String reason) async {
    final store = LocalShortsStore.instance;
    await store.addReport(
      videoId: videoId,
      reason: reason,
      userId: creatorId,
    );

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi báo cáo')),
      );
    }
  }

  Future<void> _blockUser(BuildContext context) async {
    if (creatorId == null) return;

    final store = LocalShortsStore.instance;
    await store.blockUser(creatorId!);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chặn người dùng')),
      );
    }
  }

  Future<void> _notInterested(BuildContext context) async {
    final store = LocalShortsStore.instance;
    await store.hideVideo(videoId);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã ẩn video')),
      );
    }
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
                    'Tùy chọn',
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
            // Not interested
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.grey),
              title: const Text('Không quan tâm'),
              onTap: () => _notInterested(context),
            ),
            // Report
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.red),
              title: const Text('Báo cáo'),
              onTap: () => _showReportDialog(context),
            ),
            // Block user
            if (creatorId != null)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Chặn người dùng'),
                onTap: () => _blockUser(context),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final reasons = [
      'Nội dung không phù hợp',
      'Spam',
      'Bạo lực',
      'Quấy rối',
      'Khác',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Báo cáo video'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reasons.map((reason) {
            return ListTile(
              title: Text(reason),
              onTap: () {
                Navigator.pop(context);
                _report(context, reason);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}


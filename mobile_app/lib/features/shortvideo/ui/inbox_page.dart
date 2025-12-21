import 'package:flutter/material.dart';
import '../data/local_shorts_store.dart';
import '../shortvideo_routes.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  static const routeName = ShortVideoRoutes.inbox;

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final LocalShortsStore _store = LocalShortsStore.instance;
  final List<NotificationItem> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _store.init();
    
    // Mock notifications + local events
    final mock = [
      NotificationItem(
        id: '1',
        type: NotificationType.like,
        message: '5 người đã thích video của bạn',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      NotificationItem(
        id: '2',
        type: NotificationType.comment,
        message: 'user123 đã bình luận: "Hay quá!"',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: '3',
        type: NotificationType.follow,
        message: 'user456 đã follow bạn',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: '4',
        type: NotificationType.videoLive,
        message: 'Video của bạn đã được đăng',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    setState(() {
      _notifications.addAll(mock);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text('Hộp thư'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có thông báo',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notif = _notifications[index];
                    return _NotificationTile(notification: notif);
                  },
                ),
    );
  }
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String message;
  final DateTime createdAt;

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.createdAt,
  });
}

enum NotificationType {
  like,
  comment,
  follow,
  videoLive,
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationTile({required this.notification});

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.follow:
        return Icons.person_add;
      case NotificationType.videoLive:
        return Icons.video_library;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.like:
        return Colors.pinkAccent;
      case NotificationType.comment:
        return Colors.blue;
      case NotificationType.follow:
        return Colors.green;
      case NotificationType.videoLive:
        return Colors.orange;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút';
    if (diff.inHours < 24) return '${diff.inHours} giờ';
    return '${diff.inDays} ngày';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getColor().withOpacity(0.2),
        child: Icon(_getIcon(), color: _getColor()),
      ),
      title: Text(
        notification.message,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        _timeAgo(notification.createdAt),
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black54,
          fontSize: 12,
        ),
      ),
    );
  }
}


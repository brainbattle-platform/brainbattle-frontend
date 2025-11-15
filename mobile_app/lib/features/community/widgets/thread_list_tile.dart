import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'unread_badge.dart';

class ThreadListTile extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String timeLabel;
  final bool isGroup;
  final int unreadCount;
  final bool isActiveNow;
  final String? activeStatus;
  final VoidCallback? onTap;

  const ThreadListTile({
    super.key,
    required this.title,
    required this.lastMessage,
    required this.timeLabel,
    required this.isGroup,
    this.unreadCount = 0,
    this.isActiveNow = false,
    this.activeStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            // avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF443A5B),
                  child: Icon(
                    isGroup ? Icons.groups_rounded : Icons.person,
                    color: Colors.white70,
                  ),
                ),
                if (isActiveNow)
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: BBColors.darkBg, width: 2),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // title + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: .1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isUnread ? Colors.white : Colors.white70,
                      fontWeight: isUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // time + unread / active status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 6),
                if (unreadCount > 0)
                  UnreadBadge(count: unreadCount)
                else if (activeStatus != null)
                  Text(
                    activeStatus!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

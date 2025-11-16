import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1A27),
          borderRadius: BorderRadius.circular(16),
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFF45355A),
                  child: Icon(
                    isGroup ? Icons.groups_rounded : Icons.person_rounded,
                    color: Colors.white,
                  ),
                ),

                if (isActiveNow)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BBColors.darkBg,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên thread
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Preview message
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13.5,
                      height: 1.2,
                    ),
                  ),

                  // Trạng thái active
                  if (activeStatus != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      activeStatus!,
                      style: const TextStyle(
                        color: Colors.white30,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Time + unread
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeLabel,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 6),

                if (unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 2, horizontal: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3B4C3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

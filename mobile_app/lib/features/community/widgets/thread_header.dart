import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ThreadHeader extends StatelessWidget {
  final String title;
  final String? subtitle; // ví dụ: "5 members"
  final String? avatarUrl;
  final VoidCallback onBack;
  final VoidCallback? onInfo;

  const ThreadHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    required this.onBack,
    this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      bottom: false,
      child: Container(
        color: BBColors.darkBg,
        padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF443A5B),
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white70)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Info',
              onPressed: onInfo,
              icon: const Icon(Icons.info_outline, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

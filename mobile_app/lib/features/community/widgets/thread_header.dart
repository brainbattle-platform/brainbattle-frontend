import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ThreadHeader extends StatelessWidget {
  final String title;
  final String? avatarUrl;
  final VoidCallback onBack;

  const ThreadHeader({
    super.key,
    required this.title,
    this.avatarUrl,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: BBColors.darkBg,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            CircleAvatar(
              radius: 18,
              backgroundImage: (avatarUrl != null)
                  ? NetworkImage(avatarUrl!)
                  : const AssetImage('assets/images/default_user.png') as ImageProvider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: .2,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Info',
              onPressed: () {},
              icon: const Icon(Icons.info_outline, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

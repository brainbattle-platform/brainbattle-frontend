import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models.dart';

typedef ActiveUserTap = void Function(UserLite user);

class ActiveNowStrip extends StatelessWidget {
  final List<UserLite> users;
  final ActiveUserTap onUserTap;

  const ActiveNowStrip({
    super.key,
    required this.users,
    required this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final u = users[i];
          return InkWell(
            onTap: () => onUserTap(u),
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundImage: u.avatarUrl != null
                          ? NetworkImage(u.avatarUrl!)
                          : const AssetImage('assets/images/default_user.png') as ImageProvider,
                    ),
                    // chấm online
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 12, height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF54D86C),
                          shape: BoxShape.circle,
                          border: Border.all(color: BBColors.darkBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 62,
                  child: Text(
                    u.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: users.length,
      ),
    );
  }
}

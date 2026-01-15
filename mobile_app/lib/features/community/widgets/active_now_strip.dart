import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/models.dart';
import 'avatar_name.dart';

class ActiveUser implements UserLite {
  @override
  final String id;
  @override
  final String handle;
  @override
  final String displayName;
  @override
  final String? avatarUrl;
  @override
  final bool? isActiveNow;
  @override
  final DateTime? lastActiveAt;

  const ActiveUser({
    required this.id,
    required this.handle,
    required this.displayName,
    this.avatarUrl,
    this.isActiveNow,
    this.lastActiveAt,
  });

  // Deprecated: kept for backward compatibility
  @Deprecated('Use displayName instead')
  String get name => displayName;
}

typedef ActiveUserTap = void Function(ActiveUser user);

class ActiveNowStrip extends StatelessWidget {
  final List<ActiveUser> users;
  final ActiveUserTap? onUserTap;

  const ActiveNowStrip({
    super.key,
    required this.users,
    this.onUserTap,
  });

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final u = users[i];
          return InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => onUserTap?.call(u),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarName(user: u),
                Positioned(
                  right: 2,
                  bottom: 18,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: BBColors.darkBg,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

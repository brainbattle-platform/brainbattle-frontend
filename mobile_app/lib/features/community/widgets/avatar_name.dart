import 'package:flutter/material.dart';
import '../data/models.dart';

class AvatarName extends StatelessWidget {
  final UserLite user;
  final double radius;

  const AvatarName({
    super.key,
    required this.user,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    // Display name with fallback to handle
    final displayName = user.displayName.isNotEmpty 
        ? user.displayName 
        : user.handle;

    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF443A5B),
          backgroundImage:
              user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                  ? NetworkImage(user.avatarUrl!)
                  : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? const Icon(Icons.person, color: Colors.white70)
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: radius * 2.4,
          child: Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

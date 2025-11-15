import 'package:flutter/material.dart';

class AvatarName extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double radius;

  const AvatarName({
    super.key,
    required this.name,
    this.avatarUrl,
    this.radius = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xFF443A5B),
          backgroundImage:
              avatarUrl != null ? NetworkImage(avatarUrl!) : null,
          child: avatarUrl == null
              ? const Icon(Icons.person, color: Colors.white70)
              : null,
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: radius * 2.4,
          child: Text(
            name,
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

// lib/features/community/widgets/avatar_name.dart
import 'package:flutter/material.dart';

class AvatarName extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const AvatarName({super.key, required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(radius: 16, backgroundImage: (avatarUrl!=null)? NetworkImage(avatarUrl!) : null),
      const SizedBox(width: 8),
      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    ]);
  }
}

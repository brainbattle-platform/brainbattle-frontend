import 'package:flutter/material.dart';
import '../../data/models/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  final ProfileBasic profile;
  final VoidCallback onLearningProfileTap;
  final VoidCallback onBattleProfileTap;

  const ProfileHeader({
    super.key,
    required this.profile,
    required this.onLearningProfileTap,
    required this.onBattleProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinkColor = const Color(0xFFFF8FAB);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B222A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar with optional rank badge
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: pinkColor.withOpacity(0.2),
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFFFF8FAB),
                      )
                    : null,
              ),
              // Rank badge overlay (bottom-right, 26x26)
              if (profile.rankBadgeAsset != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B222A) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      profile.rankBadgeAsset!,
                      width: 26,
                      height: 26,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            '@${profile.username}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          // Bio
          if (profile.bio != null)
            Text(
              profile.bio!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
          const SizedBox(height: 20),
          // Stats row: Following, Followers, Likes
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  value: '${profile.following}',
                  label: 'Following',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              Expanded(
                child: _StatColumn(
                  value: '${profile.followers}',
                  label: 'Followers',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              Expanded(
                child: _StatColumn(
                  value: '${profile.totalLikes}',
                  label: 'Likes',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pill buttons
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  label: 'Learning profile',
                  onTap: onLearningProfileTap,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PillButton(
                  label: 'Battle profile',
                  onTap: onBattleProfileTap,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _PillButton({
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFFF8FAB);

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? pinkColor : Colors.transparent,
        foregroundColor: isPrimary ? Colors.white : pinkColor,
        side: BorderSide(
          color: pinkColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}


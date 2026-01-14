class UserProfile {
  final String id;
  final String displayName;
  final String avatarUrl;
  final String email;
  final DateTime createdAt;
  final int followersCount;
  final int followingCount;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.email,
    required this.createdAt,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] ?? '',
    displayName: json['displayName'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    email: json['email'] ?? '',
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    followersCount: json['followersCount'] ?? 0,
    followingCount: json['followingCount'] ?? 0,
  );
}

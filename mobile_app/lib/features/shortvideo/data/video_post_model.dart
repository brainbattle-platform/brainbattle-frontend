/// Model for a video post (local or remote)
class VideoPost {
  final String id;
  final String videoPath; // Local file path or remote URL
  final String? coverPath; // Local cover image path
  final String caption;
  final List<String> hashtags; // Extracted from caption
  final DateTime createdAt;
  final String creatorId;
  final PrivacyLevel privacy;
  final bool allowComments;
  final String? musicId;
  final String? musicName;

  VideoPost({
    required this.id,
    required this.videoPath,
    this.coverPath,
    required this.caption,
    required this.hashtags,
    required this.createdAt,
    required this.creatorId,
    this.privacy = PrivacyLevel.public,
    this.allowComments = true,
    this.musicId,
    this.musicName,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'videoPath': videoPath,
        'coverPath': coverPath,
        'caption': caption,
        'hashtags': hashtags,
        'createdAt': createdAt.toIso8601String(),
        'creatorId': creatorId,
        'privacy': privacy.name,
        'allowComments': allowComments,
        'musicId': musicId,
        'musicName': musicName,
      };

  factory VideoPost.fromJson(Map<String, dynamic> json) => VideoPost(
        id: json['id'] as String,
        videoPath: json['videoPath'] as String,
        coverPath: json['coverPath'] as String?,
        caption: json['caption'] as String,
        hashtags: (json['hashtags'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        creatorId: json['creatorId'] as String,
        privacy: PrivacyLevel.values.firstWhere(
          (e) => e.name == json['privacy'],
          orElse: () => PrivacyLevel.public,
        ),
        allowComments: json['allowComments'] as bool? ?? true,
        musicId: json['musicId'] as String?,
        musicName: json['musicName'] as String?,
      );
}

enum PrivacyLevel {
  public,
  friends,
  private,
}

extension PrivacyLevelX on PrivacyLevel {
  String get label {
    switch (this) {
      case PrivacyLevel.public:
        return 'Công khai';
      case PrivacyLevel.friends:
        return 'Bạn bè';
      case PrivacyLevel.private:
        return 'Riêng tư';
    }
  }
}


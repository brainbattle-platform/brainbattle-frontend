class ShortVideo {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String author;
  final String caption;
  final String music;

  int likes;
  int comments;
  bool liked;

  ShortVideo({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.author,
    required this.caption,
    required this.music,
    this.likes = 0,
    this.comments = 0,
    this.liked = false,
  });

  ShortVideo copyWith({
    int? likes,
    int? comments,
    bool? liked,
  }) => ShortVideo(
        id: id,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        author: author,
        caption: caption,
        music: music,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
        liked: liked ?? this.liked,
      );
    factory ShortVideo.fromJson(Map<String, dynamic> json) {
    final idStr = json['id'].toString();
    return ShortVideo(
      id: idStr,
      videoUrl: json['url'] ?? '',
      thumbnailUrl:
          'https://picsum.photos/seed/short$idStr/600/900', // fake thumb
      author: json['author'] ?? 'Unknown',
      caption: json['caption'] ?? '',
      music: 'BrainBattle Mix',
      likes: json['likes'] ?? 0,
      comments: 0,
      liked: false,
    );
  }

}

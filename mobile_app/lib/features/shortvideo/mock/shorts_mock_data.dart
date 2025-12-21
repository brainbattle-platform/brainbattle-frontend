import '../data/shortvideo_model.dart';
import '../data/discovery_repository.dart';

/// High-quality mock data for ShortVideo UI (Figma/screenshots)
class ShortsMockData {
  // Creators
  static final List<MockCreator> creators = [
    MockCreator(
      id: 'creator_1',
      name: 'Alex Nguyen',
      handle: 'alex_nguyen',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
      bio: 'English teacher & content creator 🎓',
    ),
    MockCreator(
      id: 'creator_2',
      name: 'Sarah Kim',
      handle: 'sarah_kim',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      bio: 'Learning languages one video at a time 🌍',
    ),
    MockCreator(
      id: 'creator_3',
      name: 'Mike Chen',
      handle: 'mike_chen',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      bio: 'Tech enthusiast & educator 💻',
    ),
    MockCreator(
      id: 'creator_4',
      name: 'Emma Wilson',
      handle: 'emma_wilson',
      avatarUrl: 'https://i.pravatar.cc/150?img=20',
      bio: 'Sharing knowledge daily 📚',
    ),
    MockCreator(
      id: 'creator_5',
      name: 'David Lee',
      handle: 'david_lee',
      avatarUrl: 'https://i.pravatar.cc/150?img=33',
      bio: 'Making learning fun 🎯',
    ),
    MockCreator(
      id: 'creator_6',
      name: 'Lisa Park',
      handle: 'lisa_park',
      avatarUrl: 'https://i.pravatar.cc/150?img=45',
      bio: 'Language lover & traveler ✈️',
    ),
    MockCreator(
      id: 'creator_7',
      name: 'Tom Brown',
      handle: 'tom_brown',
      avatarUrl: 'https://i.pravatar.cc/150?img=50',
      bio: 'Teaching English with passion 🎤',
    ),
    MockCreator(
      id: 'creator_8',
      name: 'Anna White',
      handle: 'anna_white',
      avatarUrl: 'https://i.pravatar.cc/150?img=60',
      bio: 'Content creator & educator 📱',
    ),
  ];

  // Sounds
  static final List<MockSound> sounds = [
    MockSound(
      id: 'sound_1',
      title: 'Epic Battle Music',
      author: 'BrainBattle',
    ),
    MockSound(
      id: 'sound_2',
      title: 'Chill Vibes',
      author: 'BrainBattle',
    ),
    MockSound(
      id: 'sound_3',
      title: 'Happy Day',
      author: 'BrainBattle',
    ),
    MockSound(
      id: 'sound_4',
      title: 'She Share Story (for Vlog)',
      author: 'BrainBattle',
    ),
    MockSound(
      id: 'sound_5',
      title: 'Motivational Mix',
      author: 'BrainBattle',
    ),
  ];

  // Hashtags
  static final List<MockHashtag> hashtags = [
    MockHashtag(tag: 'learnenglish', viewsCount: 123456789),
    MockHashtag(tag: 'brainbattle', viewsCount: 98765432),
    MockHashtag(tag: 'trending', viewsCount: 50000000),
    MockHashtag(tag: 'viral', viewsCount: 30000000),
    MockHashtag(tag: 'challenge', viewsCount: 20000000),
    MockHashtag(tag: 'funny', viewsCount: 15000000),
    MockHashtag(tag: 'dance', viewsCount: 10000000),
    MockHashtag(tag: 'education', viewsCount: 8000000),
    MockHashtag(tag: 'motivation', viewsCount: 6000000),
    MockHashtag(tag: 'tips', viewsCount: 5000000),
    MockHashtag(tag: 'study', viewsCount: 4000000),
    MockHashtag(tag: 'learning', viewsCount: 3000000),
  ];

  // Video posts (20-30 videos)
  static List<ShortVideo> getPosts() {
    final captions = [
      'Just learned a new word today! #learnenglish #brainbattle',
      'Practice makes perfect! Keep learning 💪 #education #motivation',
      'Fun way to remember vocabulary! #trending #viral',
      'Daily English tip! Follow for more 📚 #tips #study',
      'Challenge yourself every day! #challenge #learning',
      'This grammar rule confused me at first 😅 #learnenglish #funny',
      'Quick pronunciation practice! #brainbattle #education',
      'Learning English through music 🎵 #trending #dance',
      'Common mistakes to avoid! #tips #study',
      'Motivational Monday! Start your week strong 💪 #motivation #learning',
      'Fun fact about English! #learnenglish #viral',
      'Practice speaking with me! #brainbattle #education',
      'New vocabulary every day! #trending #study',
      'Grammar made easy! #tips #learning',
      'Challenge: Can you pronounce this? #challenge #learnenglish',
      'Study tips that actually work! #education #motivation',
      'English idioms explained! #learnenglish #brainbattle',
      'Quick grammar quiz! #trending #study',
      'Pronunciation practice! #tips #learning',
      'Motivational quote for learners! #motivation #education',
      'Common phrases you need to know! #learnenglish #viral',
      'Study routine that works! #brainbattle #tips',
      'English through stories! #trending #education',
      'Quick vocabulary boost! #study #learning',
      'Grammar tips for beginners! #learnenglish #tips',
      'Practice makes perfect! #motivation #challenge',
      'Fun way to learn! #viral #trending',
      'Daily English practice! #brainbattle #education',
      'Study smarter, not harder! #tips #learning',
      'Keep pushing forward! #motivation #study',
    ];

    final posts = <ShortVideo>[];
    for (int i = 0; i < 30; i++) {
      final creator = creators[i % creators.length];
      final sound = sounds[i % sounds.length];
      final caption = captions[i % captions.length];
      
      // Use network video URL (public stable) or asset placeholder
      // For now, using a placeholder that can be replaced with actual video
      final videoUrl = 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
      final thumbnailUrl = 'https://i.pravatar.cc/400?img=${i + 1}';

      posts.add(ShortVideo(
        id: 'mock_video_$i',
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
        author: creator.handle,
        caption: caption,
        music: sound.title,
        likes: (1000 + i * 123) % 50000,
        comments: (50 + i * 5) % 1000,
        liked: i % 3 == 0,
      ));
    }
    return posts;
  }

  // Get posts by creator
  static List<ShortVideo> getPostsByCreator(String creatorId) {
    return getPosts().where((p) => p.author == creatorId).toList();
  }

  // Get posts by hashtag
  static List<ShortVideo> getPostsByHashtag(String tag) {
    final tagLower = tag.toLowerCase().replaceAll('#', '');
    return getPosts().where((p) => p.caption.toLowerCase().contains('#$tagLower')).toList();
  }

  // Get posts by sound
  static List<ShortVideo> getPostsBySound(String soundId) {
    final sound = sounds.firstWhere((s) => s.id == soundId, orElse: () => sounds[0]);
    return getPosts().where((p) => p.music == sound.title).toList();
  }

  // Search results
  static SearchResults search(String query) {
    final q = query.toLowerCase();
    final allPosts = getPosts();
    
    final videos = allPosts.where((p) =>
        p.caption.toLowerCase().contains(q) ||
        p.author.toLowerCase().contains(q)).toList();

    final users = creators
        .where((c) => c.handle.toLowerCase().contains(q) || c.name.toLowerCase().contains(q))
        .map((c) => c.handle)
        .toList();

    final hashtags = ShortsMockData.hashtags
        .where((h) => h.tag.toLowerCase().contains(q))
        .map((h) => '#${h.tag}')
        .toList();

    return SearchResults(
      videos: videos,
      users: users,
      hashtags: hashtags,
    );
  }

  // Trending content
  static TrendingContent getTrending() {
    return TrendingContent(
      hashtags: hashtags.take(5).map((h) => h.tag).toList(),
      sounds: sounds.take(3).map((s) => s.title).toList(),
      creators: creators.take(3).map((c) => c.handle).toList(),
    );
  }

  // Inbox notifications
  static List<NotificationItem> getInbox() {
    return [
      NotificationItem(
        id: 'notif_1',
        type: 'like',
        message: '${creators[0].name} liked your video',
        userId: creators[0].id,
        videoId: 'mock_video_1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationItem(
        id: 'notif_2',
        type: 'comment',
        message: '${creators[1].name} commented on your video',
        userId: creators[1].id,
        videoId: 'mock_video_2',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      NotificationItem(
        id: 'notif_3',
        type: 'follow',
        message: '${creators[2].name} started following you',
        userId: creators[2].id,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: 'notif_4',
        type: 'like',
        message: '${creators[3].name} and 5 others liked your video',
        userId: creators[3].id,
        videoId: 'mock_video_3',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }
}

// Helper classes
class MockCreator {
  final String id;
  final String name;
  final String handle;
  final String avatarUrl;
  final String bio;

  MockCreator({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarUrl,
    required this.bio,
  });
}

class MockSound {
  final String id;
  final String title;
  final String author;

  MockSound({
    required this.id,
    required this.title,
    required this.author,
  });
}

class MockHashtag {
  final String tag;
  final int viewsCount;

  MockHashtag({
    required this.tag,
    required this.viewsCount,
  });
}

// Notification model (if not exists)
class NotificationItem {
  final String id;
  final String type; // 'like', 'comment', 'follow'
  final String message;
  final String? userId;
  final String? videoId;
  final DateTime timestamp;

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    this.userId,
    this.videoId,
    required this.timestamp,
  });
}


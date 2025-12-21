import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/shortvideo_service.dart';
import '../shortvideo_routes.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  static const routeName = ShortVideoRoutes.searchResults;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ShortVideoService _service = ShortVideoService();
  String? _query;
  int _selectedTab = 0; // 0=Top, 1=Videos, 2=Users, 3=Hashtags
  bool _loading = true;
  List<ShortVideo> _videos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _query = args?['query'] as String? ?? '';
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _loading = true);
    // Mock: filter videos by query
    final allVideos = await _service.fetchFeed(page: 1);
    final filtered = _query!.isEmpty
        ? allVideos
        : allVideos.where((v) =>
            v.caption.toLowerCase().contains(_query!.toLowerCase()) ||
            v.author.toLowerCase().contains(_query!.toLowerCase())).toList();
    
    setState(() {
      _videos = filtered;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('Kết quả: "$_query"'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            color: isDark ? const Color(0xFF1C1C1C) : Colors.grey[100],
            child: Row(
              children: [
                _TabChip('Top', 0),
                _TabChip('Videos', 1),
                _TabChip('Users', 2),
                _TabChip('Hashtags', 3),
              ],
            ),
          ),
          // Results
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    switch (_selectedTab) {
      case 0:
      case 1:
        return _buildVideosList();
      case 2:
        return _buildUsersList();
      case 3:
        return _buildHashtagsList();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVideosList() {
    if (_videos.isEmpty) {
      return const Center(child: Text('Không tìm thấy video'));
    }
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return ListTile(
          leading: Image.network(video.thumbnailUrl, width: 80, height: 80, fit: BoxFit.cover),
          title: Text(video.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text('@${video.author} · ${video.likes} likes'),
          onTap: () {
            // TODO: Navigate to video in feed
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Widget _buildUsersList() {
    // Mock users
    final users = ['user1', 'user2', 'user3'];
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${user.hashCode % 70}'),
          ),
          title: Text('@$user'),
          subtitle: const Text('Creator'),
          onTap: () {
            Navigator.pushNamed(
              context,
              ShortVideoRoutes.profile,
              arguments: {'userId': user},
            );
          },
        );
      },
    );
  }

  Widget _buildHashtagsList() {
    // Mock hashtags
    final hashtags = ['#trending', '#viral', '#funny'];
    return ListView.builder(
      itemCount: hashtags.length,
      itemBuilder: (context, index) {
        final tag = hashtags[index];
        return ListTile(
          leading: const Icon(Icons.tag),
          title: Text(tag),
          subtitle: const Text('123 videos'),
          onTap: () {
            Navigator.pushNamed(
              context,
              ShortVideoRoutes.hashtag,
              arguments: {'tag': tag.substring(1)},
            );
          },
        );
      },
    );
  }

  Widget _TabChip(String label, int index) {
    final active = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? Colors.pinkAccent : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.pinkAccent : Colors.white70,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}


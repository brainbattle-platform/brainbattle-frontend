import 'package:flutter/material.dart';
import '../data/shortvideo_model.dart';
import '../data/discovery_repository.dart';
import '../shortvideo_routes.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key});

  static const routeName = ShortVideoRoutes.searchResults;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ShortsDiscoveryRepository _discoveryRepo = ShortsDiscoveryRepository();
  String? _query;
  int _selectedTab = 0; // 0=Top, 1=Videos, 2=Users, 3=Hashtags
  bool _loading = true;
  String? _errorMessage;
  SearchResults? _results;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    _query = args?['query'] as String? ?? '';
    _loadResults();
  }

  Future<void> _loadResults() async {
    if (_query == null || _query!.isEmpty) {
      setState(() {
        _loading = false;
        _errorMessage = 'Vui lòng nhập từ khóa tìm kiếm';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final results = await _discoveryRepo.search(_query!);
      if (mounted) {
        setState(() {
          _results = results;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi tìm kiếm: $e';
          _loading = false;
        });
      }
    }
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
                : _errorMessage != null
                    ? ShortsErrorState(
                        message: _errorMessage!,
                        onRetry: _loadResults,
                      )
                    : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_results == null) {
      return ShortsEmptyState(message: 'Không có kết quả');
    }

    switch (_selectedTab) {
      case 0:
        return _buildTopResults();
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

  Widget _buildTopResults() {
    // Top = mix of videos, users, hashtags
    return ListView(
      children: [
        if (_results!.videos.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Videos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ..._results!.videos.take(3).map((video) => _videoTile(video)),
        ],
        if (_results!.users.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ..._results!.users.take(3).map((user) => _userTile(user)),
        ],
        if (_results!.hashtags.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Hashtags', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ..._results!.hashtags.take(3).map((tag) => _hashtagTile(tag)),
        ],
        if (_results!.videos.isEmpty && _results!.users.isEmpty && _results!.hashtags.isEmpty)
          ShortsEmptyState(message: 'Không tìm thấy kết quả cho "$_query"'),
      ],
    );
  }

  Widget _buildVideosList() {
    if (_results!.videos.isEmpty) {
      return ShortsEmptyState(message: 'Không tìm thấy video');
    }
    return ListView.builder(
      itemCount: _results!.videos.length,
      itemBuilder: (context, index) => _videoTile(_results!.videos[index]),
    );
  }

  Widget _videoTile(ShortVideo video) {
    return ListTile(
      leading: Image.network(
        video.thumbnailUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 80,
          height: 80,
          color: Colors.grey[300],
          child: const Icon(Icons.video_library),
        ),
      ),
      title: Text(video.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text('@${video.author} · ${video.likes} likes'),
      onTap: () {
        // Get all videos for this search to allow swiping
        final allVideos = _results!.videos;
        final videoIndex = allVideos.indexOf(video);
        Navigator.pushNamed(
          context,
          ShortVideoRoutes.player,
          arguments: {
            'videos': allVideos,
            'initialIndex': videoIndex >= 0 ? videoIndex : 0,
            'contextType': 'search',
            'query': _query,
          },
        );
      },
    );
  }

  Widget _buildUsersList() {
    if (_results!.users.isEmpty) {
      return ShortsEmptyState(message: 'Không tìm thấy người dùng');
    }
    return ListView.builder(
      itemCount: _results!.users.length,
      itemBuilder: (context, index) => _userTile(_results!.users[index]),
    );
  }

  Widget _userTile(String user) {
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
  }

  Widget _buildHashtagsList() {
    if (_results!.hashtags.isEmpty) {
      return ShortsEmptyState(message: 'Không tìm thấy hashtag');
    }
    return ListView.builder(
      itemCount: _results!.hashtags.length,
      itemBuilder: (context, index) => _hashtagTile(_results!.hashtags[index]),
    );
  }

  Widget _hashtagTile(String tag) {
    return ListTile(
      leading: const Icon(Icons.tag),
      title: Text('#$tag'),
      subtitle: const Text('123 videos'), // Mock count
      onTap: () {
        Navigator.pushNamed(
          context,
          ShortVideoRoutes.hashtag,
          arguments: {'tag': tag},
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


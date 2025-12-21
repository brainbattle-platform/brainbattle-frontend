import 'dart:async';
import 'package:flutter/material.dart';
import '../data/search_service.dart';
import '../data/discovery_repository.dart';
import '../shortvideo_routes.dart';

class ShortsSearchPage extends StatefulWidget {
  const ShortsSearchPage({super.key});

  @override
  State<ShortsSearchPage> createState() => _ShortsSearchPageState();
}

class _ShortsSearchPageState extends State<ShortsSearchPage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _discoveryRepo = ShortsDiscoveryRepository();

  List<String> _history = [];
  List<String> _suggestions = [];
  TrendingContent? _trending;
  bool _expandedHistory = false;
  bool _loadingTrending = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _history = ShortsSearchService.instance.getHistory();
    _focus.requestFocus();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    try {
      final trending = await _discoveryRepo.trending();
      if (mounted) {
        setState(() {
          _trending = trending;
          _loadingTrending = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingTrending = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (q.trim().isEmpty) {
        setState(() => _suggestions = []);
        return;
      }
      final s = await _discoveryRepo.suggestions(q);
      if (!mounted) return;
      setState(() => _suggestions = s);
    });
  }

  void _submit(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    ShortsSearchService.instance.addHistory(query);
    setState(() {
      _history = ShortsSearchService.instance.getHistory();
    });
    // Navigate to search results
    Navigator.pushNamed(
      context,
      ShortVideoRoutes.searchResults,
      arguments: {'query': query},
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _controller.text;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top search bar like screenshot
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 12, 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 246, 191, 218),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          const Icon(Icons.search, color: Colors.black54),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focus,
                              onChanged: _onChanged,
                              onSubmitted: _submit,
                              textInputAction: TextInputAction.search,
                              decoration: const InputDecoration(
                                hintText: 'Tìm kiếm',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          if (q.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _controller.clear();
                                _onChanged('');
                                setState(() {});
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.camera_alt_outlined),
                            onPressed: () {}, // TODO: mở camera
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _submit(_controller.text),
                    child: const Text('Tìm kiếm',
                        style: TextStyle(color: Color(0xFFFF2D55), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            // body
            Expanded(
              child: q.isEmpty ? _buildIdle() : _buildSuggest(q),
            ),
          ],
        ),
      ),
    );
  }

  // Màn hình khi chưa gõ gì
  Widget _buildIdle() {
    final visible = _expandedHistory ? _history : _history.take(3).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trending section
          if (_loadingTrending)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_trending != null) ...[
            const Text('Đang thịnh hành',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 12),
            // Trending hashtags
            if (_trending!.hashtags.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trending!.hashtags.map((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    onDeleted: () {},
                    onPressed: () => _submit('#$tag'),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            // Trending sounds
            if (_trending!.sounds.isNotEmpty) ...[
              ..._trending!.sounds.map((sound) {
                return _itemRow(
                  leading: const Icon(Icons.music_note, color: Colors.black54),
                  title: Text(sound, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Âm thanh'),
                  trailing: const Icon(Icons.close, size: 18),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ShortVideoRoutes.sound,
                      arguments: {'soundName': sound},
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
            // Trending creators
            if (_trending!.creators.isNotEmpty) ...[
              const Text('Creators đang thịnh hành',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 8),
              ..._trending!.creators.map((creator) {
                return _itemRow(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=${creator.hashCode % 70}',
                    ),
                  ),
                  title: Text('@$creator'),
                  subtitle: const Text('Creator'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      ShortVideoRoutes.profile,
                      arguments: {'userId': creator},
                    );
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ],

          // Lịch sử
          ...visible.map((h) => _historyTile(h)).toList(),
          if (_history.length > 3)
            Center(
              child: TextButton(
                onPressed: () => setState(() => _expandedHistory = !_expandedHistory),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_expandedHistory ? 'Thu gọn' : 'Xem thêm'),
                    const Icon(Icons.expand_more, size: 18),
                  ],
                ),
              ),
            ),

          // Banner điểm
          Container(
            margin: const EdgeInsets.only(top: 6, bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.monetization_on, color: Color(0xFFFFAA00)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tìm kiếm 12 lần để nhận 360 điểm — hãy tiếp tục để mở khóa tới 600 điểm hôm nay!',
                    style: TextStyle(color: Color(0xFF5C4300)),
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.close, color: Color(0xFF5C4300), size: 18),
              ],
            ),
          ),

          const SizedBox(height: 120),
        ],
      ),
    );
  }

  // Khi đang gõ: gợi ý realtime
  Widget _buildSuggest(String q) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6),
      itemCount: _suggestions.length,
      itemBuilder: (c, i) {
        final s = _suggestions[i];
        return ListTile(
          leading: const Icon(Icons.search, color: Colors.black54),
          title: _highlight(s, q),
          onTap: () => _submit(s),
          trailing: IconButton(
            icon: const Icon(Icons.north_east, size: 18),
            onPressed: () => _submit(s),
          ),
        );
      },
    );
  }

  // --- tiles helpers ---
  Widget _historyTile(String h) {
    return ListTile(
      leading: const Icon(Icons.history, color: Colors.black54),
      title: Text(h),
      onTap: () => _submit(h),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () {
          ShortsSearchService.instance.removeHistory(h);
          setState(() => _history = ShortsSearchService.instance.getHistory());
        },
      ),
    );
  }


  Widget _itemRow({
    Widget? leading,
    required Widget title,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  // tô đậm phần khớp
  Widget _highlight(String full, String q) {
    final idx = full.toLowerCase().indexOf(q.toLowerCase());
    if (idx < 0) return Text(full);
    final a = full.substring(0, idx);
    final b = full.substring(idx, idx + q.length);
    final c = full.substring(idx + q.length);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: a, style: const TextStyle(color: Colors.pink)),
          TextSpan(text: b, style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w700)),
          TextSpan(text: c, style: const TextStyle(color: Colors.pink)),
        ],
      ),
    );
  }
}

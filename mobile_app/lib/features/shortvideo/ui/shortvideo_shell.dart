import 'package:flutter/material.dart';

// Short-video FE chính
import '../shortvideo.dart'; // ShortVideoFeedPage()

// Các feature còn lại
import '../../battle/ui/battle_shell.dart';
import '../../community/ui/community_view.dart';
import '../../learning/ui/galaxy_map_screen.dart'; // hoặc màn Lesson khác

class ShortVideoShell extends StatefulWidget {
  const ShortVideoShell({super.key});
  static const routeName = '/shorts-shell';

  @override
  State<ShortVideoShell> createState() => _ShortVideoShellState();
}

class _ShortVideoShellState extends State<ShortVideoShell> {
  late final PageController _controller;

  // 0 = battle, 1 = community, 2 = shorts, 3 = learning
  int _index = 2;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read route arguments after context is available
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args.containsKey('initialTab')) {
        final tab = args['initialTab'] as int?;
        if (tab != null && tab >= 0 && tab <= 3) {
          _index = tab;
          _controller.jumpToPage(_index);
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shorts ở giữa → để full black giống TikTok
    final bg = _index == 2
        ? Colors.black
        : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          // Trang cực trái: Battle
          BattleShell(),

          // Trái: Community
          CommunityView(),

          // Giữa: Short video feed (vuốt dọc đổi video)
          ShortVideoFeedPage(),

          // Phải: Learning / Galaxy
          GalaxyMapScreen(),
        ],
      ),
    );
  }
}

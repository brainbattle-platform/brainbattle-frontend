import 'package:flutter/material.dart';
import '../shortvideo.dart';                       // ShortVideoFeedPage()
import '../../learning/ui/galaxy_map_screen.dart';   // hoặc trang Lesson bạn muốn
import '../../community/ui/shell/community_shell.dart';

class ShortVideoShell extends StatefulWidget {
  const ShortVideoShell({super.key});
  static const routeName = '/shorts-shell';

  @override
  State<ShortVideoShell> createState() => _ShortVideoShellState();
}

class _ShortVideoShellState extends State<ShortVideoShell> {
  late final PageController _controller;
  int _index = 1; // 0 = chat, 1 = shorts, 2 = lessons

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gợi ý: để shorts “full black” + hai trang còn lại dùng theme mặc định
    final bg = _index == 1 ? Colors.black : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (i) => setState(() => _index = i),
        children: const [
          // ← Trang Trái: Community
          CommunityShell(),

          // Giữa: Short video feed (vuốt dọc đổi video)
          ShortVideoFeedPage(),

          // → Trang Phải: Lesson / Galaxy
          GalaxyMapScreen(),
        ],
      ),
    );
  }
}

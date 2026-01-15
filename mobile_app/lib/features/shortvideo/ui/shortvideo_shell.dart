import 'package:flutter/material.dart';

// Short-video FE chính
import '../shortvideo.dart'; // ShortVideoFeedPage()

// Các feature còn lại
import '../../battle/ui/battle_shell.dart';
import '../../community/ui/community_view.dart';
import '../../learning/ui/galaxy_map_screen.dart'; // hoặc màn Lesson khác

class ShortVideoShell extends StatefulWidget {
  const ShortVideoShell({
    super.key,
    this.initialTab,
  });
  
  static const routeName = '/shorts-shell';
  
  /// Initial tab index when used directly (not via route)
  /// Priority: constructor parameter > route arguments
  /// If null, will read from route arguments or default to 2 (shorts feed)
  final int? initialTab;

  @override
  State<ShortVideoShell> createState() => _ShortVideoShellState();
}

class _ShortVideoShellState extends State<ShortVideoShell> {
  late final PageController _controller;

  // 0 = battle, 1 = community, 2 = shorts, 3 = learning
  int _index = 2;
  int? _targetIndex; // Store target index from initialTab
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Read initialTab from constructor first (if available)
    if (widget.initialTab != null && widget.initialTab! >= 0 && widget.initialTab! <= 3) {
      _index = widget.initialTab!;
      // Store target index to jump after PageView is built
      _targetIndex = widget.initialTab;
    }
    _controller = PageController(initialPage: _index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read initialTab from route arguments if not set from constructor
    if (!_initialized) {
      if (_targetIndex == null) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is Map && args.containsKey('initialTab')) {
          final tab = args['initialTab'] as int?;
          if (tab != null && tab >= 0 && tab <= 3) {
            _targetIndex = tab;
            _index = tab;
          }
        }
      }
      
      // Safe jump to target index after PageView is built
      // Only jump if target index is different from current index
      if (_targetIndex != null && _targetIndex != _index) {
        _index = _targetIndex!;
        _safeJump(_targetIndex!);
      }
      
      _initialized = true;
    }
  }

  @override
  void didUpdateWidget(ShortVideoShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle when initialTab changes (e.g., widget is reused with different initialTab)
    if (widget.initialTab != oldWidget.initialTab) {
      final newTab = widget.initialTab;
      if (newTab != null && newTab >= 0 && newTab <= 3 && newTab != _index) {
        _targetIndex = newTab;
        _index = newTab;
        _safeJump(newTab);
      }
    }
  }

  /// Safely jump to page index, checking if controller is attached first
  void _safeJump(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      if (_controller.hasClients) {
        _controller.jumpToPage(index);
      } else {
        // Fallback: schedule another frame if controller not ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.hasClients) {
            _controller.jumpToPage(index);
          }
        });
      }
    });
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

    // Check if this ShortVideoShell is nested in MainShell's PageView
    // If route arguments exist, it means it's being used in MainShell
    final args = ModalRoute.of(context)?.settings.arguments;
    final isNestedInMainShell = args is Map && args.containsKey('initialTab');
    
    return Scaffold(
      backgroundColor: bg,
      body: PageView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        onPageChanged: (i) => setState(() => _index = i),
        // Disable horizontal scroll when nested in MainShell to prevent conflicts
        // MainShell's PageView will handle the horizontal scrolling
        physics: isNestedInMainShell
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
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

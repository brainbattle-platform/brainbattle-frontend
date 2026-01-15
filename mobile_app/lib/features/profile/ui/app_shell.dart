import 'package:flutter/material.dart';
import '../../shortvideo/ui/shortvideo_feed_page.dart';
import '../../learning/ui/galaxy_map_screen.dart';
import '../presentation/pages/user_profile_page.dart';

/// Main app shell with horizontal swipe between 3 pages:
/// 0: ShortVideo Feed
/// 1: Learning Map
/// 2: User Profile
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  
  static const routeName = '/app-shell';
  
  // Static reference to access state from child pages
  static _AppShellState? _instance;
  
  static void navigateToPage(int index) {
    _instance?.navigateToPage(index);
  }

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final PageController _pageController;
  int _currentIndex = 0; // Default: Feed (index 0)

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    AppShell._instance = this;
  }
  
  @override
  void dispose() {
    if (AppShell._instance == this) {
      AppShell._instance = null;
    }
    _pageController.dispose();
    super.dispose();
  }


  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Navigate to a specific page index
  void navigateToPage(int index) {
    if (index >= 0 && index <= 2) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Feed page uses black background
    final bg = _currentIndex == 0
        ? Colors.black
        : Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        onPageChanged: _onPageChanged,
        children: const [
          // Page 0: ShortVideo Feed
          ShortVideoFeedPage(),
          // Page 1: Learning Map
          GalaxyMapScreen(),
          // Page 2: User Profile
          UserProfilePage(),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../battle/ui/battle_flow.dart';
import '../../learning/ui/galaxy_map_screen.dart';
import '../../shortvideo/ui/shortvideo_shell.dart';
import '../presentation/pages/user_profile_page.dart';

/// Main shell with horizontal PageView (5 pages) + bottom navigation
/// Pages: 0=Clan, 1=Battle, 2=Feed, 3=Learn, 4=Profile
class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    this.initialIndex = 2,
  });

  static const routeName = '/main';

  /// Initial page index (default: 2 = Feed/Home)
  /// Can be overridden by route arguments
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Use constructor parameter as default
    _currentIndex = widget.initialIndex.clamp(0, 4);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read initialIndex from route arguments if available (priority over constructor)
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args.containsKey('initialIndex')) {
        final routeIndex = args['initialIndex'] as int?;
        if (routeIndex != null) {
          final validIndex = routeIndex.clamp(0, 4);
          if (validIndex != _currentIndex) {
            _currentIndex = validIndex;
            _pageController.jumpToPage(_currentIndex);
          }
        }
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Main PageView - direct child, no Sliver wrappers
          PageView(
            controller: _pageController,
            scrollDirection: Axis.horizontal,
            onPageChanged: _onPageChanged,
            // Disable physics to prevent nested PageView conflicts
            physics: const PageScrollPhysics(),
            children: [
              // Page 0: Clan (ShortVideoShell with community tab)
              // ShortVideoShell tabs: 0=battle, 1=community, 2=shorts, 3=learning
              _ShortVideoShellWithTab(
                key: const PageStorageKey('clan_shell'),
                initialTab: 1, // Community tab
              ),
              // Page 1: Battle
              const BattleFlow(),
              // Page 2: Feed/Home (ShortVideoShell with shorts feed tab)
              // ShortVideoShell tabs: 0=battle, 1=community, 2=shorts, 3=learning
              _ShortVideoShellWithTab(
                key: const PageStorageKey('feed_shell'),
                initialTab: 2, // Shorts feed tab (not 0!)
              ),
              // Page 3: Learn (GalaxyMapScreen)
              const GalaxyMapScreen(),
              // Page 4: Profile
              const UserProfilePage(),
            ],
          ),
          // Edge swipe zones for Learn/Map page (index 3)
          if (_currentIndex == 3) ...[
            // Left edge zone (swipe right -> prev page)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 200) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            // Right edge zone (swipe left -> next page)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 20,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < -200) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF8FAB), // Pink theme
        unselectedItemColor: isDark ? Colors.white60 : Colors.black54,
        backgroundColor: isDark ? const Color(0xFF1B222A) : Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Clan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Battle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Wrapper to create independent ShortVideoShell instances with specific initialTab
/// Passes initialTab directly via constructor to avoid Navigator conflicts
/// Each instance has a unique key to ensure state independence
class _ShortVideoShellWithTab extends StatelessWidget {
  final int initialTab;

  const _ShortVideoShellWithTab({
    super.key,
    required this.initialTab,
  });

  @override
  Widget build(BuildContext context) {
    // Pass initialTab directly via constructor - no Navigator needed
    // This avoids RenderViewport conflicts with CustomScrollView in ChatsPage
    // Use unique keys for Feed (tab=2) and Clan (tab=1) to ensure state independence
    // Key is already provided by parent (PageStorageKey), but add ValueKey for extra safety
    final uniqueKey = initialTab == 2 
        ? const ValueKey('shorts_feed_tab2')
        : const ValueKey('shorts_clan_tab1');
    
    // Do NOT use const here - each instance needs its own state
    return ShortVideoShell(
      key: uniqueKey,
      initialTab: initialTab,
    );
  }
}


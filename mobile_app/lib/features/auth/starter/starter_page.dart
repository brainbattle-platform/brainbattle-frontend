// lib/features/auth/starter/starter_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../community/community_shell.dart';
import '../../auth/login/login_page.dart';
import '../../shortvideo/shortvideo.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});
  static const routeName = '/starter';

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _Brand {
  static const pinkBrain = Color(0xFFFF8FAB);
  static const pinkBattle = Color(0xFFF3B4C3);

  static const fontFamily = 'Poppins';
}

class _PopupPalette {
  static const plumA = Color(0xFF281E2C);
  static const plumB = Color(0xFF34233B);
  static const pinkBorder = Color(0x33FF8FAB); // 20% alpha
  static const pinkGlow = Color(0x22FB6F92); // glow nhẹ
  static const exploreGradA = Color(0xFFFFB3C6);
  static const exploreGradB = Color(0xFFFB6F92);
}

class _Slide {
  final String title;
  final String subtitle;
  const _Slide(this.title, this.subtitle);
}

class _StarterPageState extends State<StarterPage> {
  final _pageCtrl = PageController();
  int _current = 0;

  static const List<_Slide> _slides = [
    _Slide(
      '🌟 Learn English - Play - Connect',
      'Discover a new way to learn English through games, videos, and a vibrant social community — every lesson feels like an adventure!',
    ),
    _Slide(
      '🔥 Level Up - Join the Battle!',
      'Turn learning into a quest. Level up, form clans, chat with friends, and climb the leaderboard today!',
    ),
    _Slide(
      '💬 Study Less, Live More',
      'Experience personalized learning that adapts to your pace — connect, share, and grow with learners worldwide.',
    ),
    _Slide(
      '🚀 Unlock Your World',
      'Begin your English journey today — where skills, emotion, and community unite in one powerful experience.',
    ),
    _Slide(
      '⚔️ Compete - Learning Together!',
      'Collect achievements that reflect your growth.',
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final w = MediaQuery.of(context).size.width;
    final h = size.height;

    final titleSize = (w * 0.10).clamp(26.0, 40.0).toDouble();
    final subSize = (titleSize * 0.38).clamp(10.0, 16.0).toDouble();

    final cardMinHeight = (h * 0.44).clamp(330.0, 540.0);

    return Scaffold(
      backgroundColor: BBColors.darkBg,
      body: SafeArea(
        child: Stack(
          children: [
            _Header(titleSize: titleSize, subSize: subSize),
            _Popup(
              minHeight: cardMinHeight,
              pageCtrl: _pageCtrl,
              currentIndex: _current,
              onPageChanged: (i) => setState(() => _current = i),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.titleSize, required this.subSize});

  final double titleSize;
  final double subSize;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      top: 24,
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Image(
              image: AssetImage('assets/brainbattle_logo_light_pink.png'),
              width: 92,
              height: 92,
            ),
            const SizedBox(height: 28),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'BRAIN ',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans', // = Splash
                      fontFamilyFallback: const ['Poppins', 'Roboto'],
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0, // = Splash
                      height: 1.08, // = Splash
                      color: _Brand.pinkBrain, // = Splash
                    ),
                  ),
                  TextSpan(
                    text: 'BATTLE',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontFamilyFallback: const ['Poppins', 'Roboto'],
                      fontSize: titleSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.0,
                      height: 1.08,
                      color: _Brand.pinkBattle, // = Splash
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'LANGUAGE LEARNING',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontFamilyFallback: const ['Poppins', 'Roboto'],
                fontSize: subSize,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.2, // = Splash
                height: 1.1, // = Splash
                color: const Color(0xFFFFC4D6), // = Splash
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Popup extends StatelessWidget {
  const _Popup({
    required this.minHeight,
    required this.pageCtrl,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final double minHeight;
  final PageController pageCtrl;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        constraints: BoxConstraints(minHeight: minHeight),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_PopupPalette.plumA, _PopupPalette.plumB],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _PopupPalette.pinkBorder, width: 1),
          boxShadow: const [
            BoxShadow(
              blurRadius: 22,
              offset: Offset(0, 10),
              color: _PopupPalette.pinkGlow,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Grabber(),
            const SizedBox(height: 18),
            _Slides(
              controller: pageCtrl,
              currentIndex: currentIndex,
              onPageChanged: onPageChanged,
            ),
            const SizedBox(height: 12),
            _Dots(
              length: _StarterPageState._slides.length,
              current: currentIndex,
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: _OutlinedPinkButton(
                    icon: Icons.person_add_alt_1_rounded,
                    label: 'Sign up',
                    onPressed: () =>
                        Navigator.pushNamed(context, CommunityShell.routeName),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FilledPinkButton(
                    icon: Icons.lock_open_rounded,
                    label: 'Login',
                    onPressed: () =>
                        Navigator.pushNamed(context, LoginPage.routeName),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ExploreGradientButton(
              onPressed: () =>
                  Navigator.pushNamed(context, ShortVideoShell.routeName),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _Slides extends StatelessWidget {
  const _Slides({
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SizedBox(
      height: 112,
      child: PageView.builder(
        controller: controller,
        itemCount: _StarterPageState._slides.length,
        onPageChanged: onPageChanged,
        itemBuilder: (_, i) {
          final slide = _StarterPageState._slides[i];
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: text.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                slide.subtitle,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.length, required this.current});
  final int length;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}

class _OutlinedPinkButton extends StatelessWidget {
  const _OutlinedPinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: _Brand.pinkBrain,
        side: const BorderSide(color: _Brand.pinkBrain, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        backgroundColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _FilledPinkButton extends StatelessWidget {
  const _FilledPinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _Brand.pinkBattle,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
    );
  }
}

class _ExploreGradientButton extends StatelessWidget {
  const _ExploreGradientButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_PopupPalette.exploreGradA, _PopupPalette.exploreGradB],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 8),
              color: _PopupPalette.pinkGlow,
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onPressed: onPressed,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.explore_outlined, size: 18),
              SizedBox(width: 6),
              Text('Explore'),
            ],
          ),
        ),
      ),
    );
  }
}

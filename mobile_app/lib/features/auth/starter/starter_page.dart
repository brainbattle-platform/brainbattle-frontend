// lib/features/auth/starter/starter_page.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
// keep your imports; routes can stay TODO for now
import '../../community/community_shell.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});
  static const routeName = '/starter';

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> {
  // Brand pinks (match logo)
  static const _pinkBrain  = Color(0xFFFF8FAB); // brighter
  static const _pinkBattle = Color(0xFFF3B4C3); // softer

  // Popup colors tuned to logo/buttons (deep plum + pink tint)
  static const _plumDark   = Color(0xFF211924); // background canvas stays dark
  static const _plumCardA  = Color(0xFF281E2C);
  static const _plumCardB  = Color(0xFF34233B);
  static const _pinkBorder = Color(0x33FF8FAB); // 20% alpha border
  static const _pinkGlow   = Color(0x22FB6F92); // soft glow

  final _pageCtrl = PageController();
  int _current = 0;

  final List<String> _messages = const [
    'Keep your daily streak — progress you can feel.',
    'Join a clan and learn together.',
    'Real-time challenges and mini games.',
    'Personalized paths powered by AI.',
    'Collect badges and show your growth.',
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
    final w = size.width, h = size.height;
    final titleSize = (w * 0.09).clamp(24.0, 34.0).toDouble();
    final cardMinHeight = (h * 0.44).clamp(330.0, 540.0);

    return Scaffold(
      backgroundColor: BBColors.darkBg, // keep your dark canvas
      body: SafeArea(
        child: Stack(
          children: [
            // Header: logo + title
            Positioned.fill(
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
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.0,
                              color: _pinkBrain,
                            ),
                          ),
                          TextSpan(
                            text: 'BATTLE',
                            style: TextStyle(
                              fontSize: titleSize,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4.0,
                              color: _pinkBattle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Popup card (recolored to match logo & buttons)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                constraints: BoxConstraints(minHeight: cardMinHeight),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_plumCardA, _plumCardB], // deep plum with pink undertone
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _pinkBorder, width: 1),
                  boxShadow: const [
                    BoxShadow(blurRadius: 22, offset: Offset(0, 10), color: _pinkGlow),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // grabber
                    Container(
                      width: 64, height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Swipe text (only text changes)
                    SizedBox(
                      height: 112,
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: _messages.length,
                        onPageChanged: (i) => setState(() => _current = i),
                        itemBuilder: (_, i) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Learn local languages for free!',
                                textAlign: TextAlign.center,
                                style: text.titleMedium!.copyWith(
                                  color: Colors.white,
                                  fontSize: 20,
                                  height: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _messages[i],
                                textAlign: TextAlign.center,
                                style: text.bodyMedium!.copyWith(
                                  color: Colors.white70,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_messages.length, (i) {
                        final active = i == _current;
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
                    ),
                    const SizedBox(height: 26),

                    // Buttons row (icons updated)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _pinkBrain,
                              side: const BorderSide(color: _pinkBrain, width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {
                              // TODO: your real sign-up route
                              Navigator.pushNamed(context, CommunityShell.routeName);
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_add_alt_1_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Sign up'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pinkBattle,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            onPressed: () {
                              // TODO: your real login route
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_open_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Login'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Explore CTA (keep your pink gradient)
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB3C6), Color(0xFFFB6F92)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: _pinkGlow),
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
                          onPressed: () {
                            Navigator.pushNamed(context, '/explore'); // hook later
                          },
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
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

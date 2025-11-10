// lib/features/auth/splash/splash_page.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../starter/starter_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  static const routeName = '/';

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _navigated = false;
  bool _lottieReady = false;

  // Brand colors (giữ nguyên)
  static const _black = Color(0xFF000000);
  static const _pinkBrain = Color(0xFFFF8FAB);
  static const _pinkBattle = Color(0xFFF3B4C3);

  void _goNext() {
    if (!mounted || _navigated) return;
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const StarterPage(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Giữ nguyên logic: trì hoãn 3s rồi mới chạy animation (nếu đã ready)
    Future.delayed(const Duration(seconds: 3), () {
      if (_lottieReady && mounted) {
        _controller.forward(from: 0);
      }
    });

    // Khi chạy xong 1 vòng → điều hướng
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _goNext();
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
    final w = MediaQuery.of(context).size.width;
    final titleSize = (w * 0.10).clamp(26.0, 40.0).toDouble();
    final subSize = (titleSize * 0.38).clamp(10.0, 16.0).toDouble();
    final lottieHeight = (w * 1.00).clamp(200.0, 280.0);

    return Scaffold(
      backgroundColor: _black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: lottieHeight,
                child: Lottie.asset(
                  'assets/animations/logo_animation_light.json',
                  controller: _controller,
                  frameRate: FrameRate.max,
                  repeat: false,
                  animate: false,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration
                      ..value = 0.0;
                    _lottieReady = true;
                  },
                ),
              ),
              const SizedBox(height: 28),

              // ====== BRAND TITLE ======
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'BRAIN ',
                      style: _BrandTypography.title(
                        size: titleSize,
                        color: _pinkBrain,
                      ),
                    ),
                    TextSpan(
                      text: 'BATTLE',
                      style: _BrandTypography.title(
                        size: titleSize,
                        color: _pinkBattle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'LANGUAGE LEARNING',
                style: _BrandTypography.subtitle(size: subSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================
/// Typography (single source of truth)
/// =======================
class _Fonts {
  // Đổi font tại đây nếu bạn thích font khác.
  // Gợi ý: 'PlusJakartaSans' → tròn & mềm; fallback 'Poppins' → hệ thống.
  static const primary = 'PlusJakartaSans';
  static const fallback = <String>['Poppins', 'Roboto'];
}

class _BrandTypography {
  /// Tiêu đề "BRAIN BATTLE"
  static TextStyle title({required double size, required Color color}) {
    return TextStyle(
      fontFamily: _Fonts.primary,
      fontFamilyFallback: _Fonts.fallback,
      fontSize: size,
      fontWeight: FontWeight.w900, // đậm & tròn
      letterSpacing: 3.0,          // giảm nhẹ cho cân logo
      height: 1.08,                // giữ tổng chiều cao không thay đổi
      color: color,
    );
  }

  /// Subtitle "LANGUAGE LEARNING"
  static TextStyle subtitle({required double size}) {
    return TextStyle(
      fontFamily: _Fonts.primary,
      fontFamilyFallback: _Fonts.fallback,
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.2,          // nhịp đều, cảm giác brandy
      height: 1.1,
      color: const Color(0xFFFFC4D6), // giữ nguyên màu bạn dùng
    );
  }
}

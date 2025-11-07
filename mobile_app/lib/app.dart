import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/splash/splash_page.dart';
import 'features/auth/starter/starter_page.dart';
import 'features/auth/login/login_page.dart';
import 'features/auth/signup/sign_up_page.dart';
import 'features/auth/verify/verify_otp_page.dart';
import 'features/auth/complete/complete_profile_page.dart';

import 'features/learning/learning.dart';

import 'features/community/community_shell.dart';
import 'features/shortvideo/shortvideo.dart';

class BrainBattleApp extends StatelessWidget {
  const BrainBattleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrainBattle',
      debugShowCheckedModeBanner: false,
      theme: bbLightTheme(),
      darkTheme: bbDarkTheme(),
      themeMode: ThemeMode.dark,
      home: const SplashPage(),
      routes: {
        StarterPage.routeName: (_) => const StarterPage(),
        CommunityShell.routeName: (_) => const CommunityShell(),
        LessonsScreen.routeName: (_) => const LessonsScreen(),
        ShortVideoShell.routeName: (c) => const ShortVideoShell(),
        LoginPage.routeName: (_) => const LoginPage(),
        SignUpPage.routeName: (_) => const SignUpPage(),
        VerifyOtpPage.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as Map?;
          // Bạn có thể dùng push(MaterialPageRoute) như trong code nên routeName optional
          return VerifyOtpPage(email: (args?['email'] as String?) ?? '');
        },
        CompleteProfilePage.routeName: (ctx) {
          final args = ModalRoute.of(ctx)!.settings.arguments as Map?;
          return CompleteProfilePage(
            email: (args?['email'] as String?) ?? '',
            otp: (args?['otp'] as String?) ?? '',
          );
        },
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const StarterPage()),
    );
  }
}

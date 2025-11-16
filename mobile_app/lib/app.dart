import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/splash/splash_page.dart';
import 'features/auth/starter/starter_page.dart';
import 'features/auth/login/login_page.dart';
import 'features/auth/signup/sign_up_page.dart';
import 'features/auth/verify/verify_otp_page.dart';
import 'features/auth/complete/complete_profile_page.dart';
import 'features/auth/forgot/forgot_start_page.dart';
import 'features/auth/forgot/forgot_otp_page.dart';
import 'features/auth/forgot/forgot_new_password_page.dart';

import 'package:mobile_app/core/network/api_base.dart';

import 'features/learning/learning.dart';

import 'features/community/ui/shell/community_shell.dart';
import 'features/community/ui/thread/thread_page.dart';
import 'features/community/ui/clan/new_clan_page.dart';
import 'features/shortvideo/shortvideo.dart';

import 'features/battle/ui/battle_flow.dart';
import 'features/battle/battle_routes.dart';

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
        NewClanPage.routeName: (_) => const NewClanPage(),
        ThreadPage.routeName: (_) => const ThreadPage(),
        LessonsScreen.routeName: (_) => const LessonsScreen(),
        ShortVideoShell.routeName: (c) => const ShortVideoShell(),
        BattleRoutes.root: (_) => const BattleFlow(),
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
        ForgotStartPage.routeName: (ctx) {
          final raw = apiBase(); // ví dụ: '192.168.1.34:3000' hoặc đã có http
          final baseUrl = raw.startsWith('http') ? raw : 'http://$raw';
          return ForgotStartPage(baseUrl: baseUrl);
        },
        ForgotOtpPage.routeName: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map?;
          final baseUrl = (args?['baseUrl'] as String?) ?? '';
          final email = (args?['email'] as String?) ?? '';
          return ForgotOtpPage(baseUrl: baseUrl, email: email);
        },
        ForgotNewPasswordPage.routeName: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map?;
          final baseUrl = (args?['baseUrl'] as String?) ?? '';
          final email = (args?['email'] as String?) ?? '';
          final otp = (args?['otp'] as String?) ?? '';
          return ForgotNewPasswordPage(
            baseUrl: baseUrl,
            email: email,
            otp: otp,
          );
        },
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const StarterPage()),
    );
  }
}

import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

import 'features/auth/splash/splash_page.dart';
import 'features/auth/starter/starter_page.dart';
import 'features/auth/login/login_page.dart';
import 'features/auth/signup/sign_up_page.dart';

import 'features/messaging/ui/conversations_page.dart';

import 'features/learning/learning.dart';
import 'features/learning/ui/galaxy_map_screen.dart';

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
      },
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const StarterPage()),
    );
  }
}

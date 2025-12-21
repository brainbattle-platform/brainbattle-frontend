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
import 'features/learning/learning_routes.dart';
import 'features/learning/ui/unit_detail_page.dart';
import 'features/learning/ui/lesson_start_page.dart';
import 'features/learning/ui/exercise_player_page.dart';
import 'features/learning/ui/lesson_summary_page.dart';
import 'features/learning/ui/unit_completion_page.dart';
import 'features/learning/ui/practice_hub_page.dart';
import 'features/learning/ui/mistakes_review_page.dart';
import 'features/learning/ui/review_queue_page.dart';
import 'features/learning/ui/daily_goal_picker_page.dart';
import 'features/learning/ui/streak_page.dart';
import 'features/learning/ui/league_page.dart';
import 'features/learning/ui/achievements_page.dart';
import 'features/learning/ui/learning_stats_page.dart';
import 'features/learning/ui/learning_settings_page.dart';
import 'features/learning/ui/curriculum_browser_page.dart';
import 'features/learning/ui/placement_test_page.dart';

import 'features/community/ui/thread/thread_page.dart';
import 'features/community/ui/clan/new_clan_page.dart';
import 'features/shortvideo/shortvideo.dart';
import 'features/shortvideo/shortvideo_routes.dart';
import 'features/shortvideo/ui/profile_page.dart';
import 'features/shortvideo/ui/search_results_page.dart';
import 'features/shortvideo/ui/hashtag_page.dart';
import 'features/shortvideo/ui/sound_page.dart';
import 'features/shortvideo/ui/upload_picker_page.dart';
import 'features/shortvideo/ui/video_editor_page.dart';
import 'features/shortvideo/ui/post_page.dart';
import 'features/shortvideo/ui/inbox_page.dart';
import 'features/shortvideo/ui/short_video_player_page.dart';

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
        // DEPRECATED: /community route - redirects to ShortVideoShell with community tab
        // Use ShortVideoShell.routeName instead
        '/community': (context) {
          // Redirect to ShortVideoShell and open community tab (index 1)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(
              ShortVideoShell.routeName,
              arguments: {'initialTab': 1},
            );
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
        NewClanPage.routeName: (_) => const NewClanPage(),
        ThreadPage.routeName: (_) => const ThreadPage(),
        LessonsScreen.routeName: (_) => const LessonsScreen(),
        ShortVideoShell.routeName: (c) => const ShortVideoShell(),
        // ShortVideo routes
        ShortVideoRoutes.profile: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map?;
          return ProfilePage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.search: (_) => const ShortsSearchPage(),
        ShortVideoRoutes.searchResults: (ctx) {
          return SearchResultsPage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.hashtag: (ctx) {
          return HashtagPage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.sound: (ctx) {
          return SoundPage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.upload: (_) => const UploadPickerPage(),
        ShortVideoRoutes.editor: (ctx) {
          return VideoEditorPage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.post: (ctx) {
          return PostPage(); // Will read args in didChangeDependencies
        },
        ShortVideoRoutes.inbox: (_) => const InboxPage(),
        ShortVideoRoutes.player: (ctx) {
          return ShortVideoPlayerPage(); // Will read args in didChangeDependencies
        },
        // Learning routes
        LearningRoutes.practiceHub: (_) => const PracticeHubPage(),
        LearningRoutes.mistakesReview: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments as Map?;
          return MistakesReviewPage(
            lesson: args?['lesson'] as Lesson,
            mistakeIds: (args?['mistakeIds'] as List?)?.cast<String>() ?? [],
          );
        },
        LearningRoutes.reviewQueue: (_) => const ReviewQueuePage(),
        LearningRoutes.dailyGoalPicker: (_) => const DailyGoalPickerPage(),
        LearningRoutes.streak: (_) => const StreakPage(),
        LearningRoutes.league: (_) => const LeaguePage(),
        LearningRoutes.achievements: (_) => const AchievementsPage(),
        LearningRoutes.learningStats: (_) => const LearningStatsPage(),
        LearningRoutes.learningSettings: (_) => const LearningSettingsPage(),
        LearningRoutes.curriculumBrowser: (_) => const CurriculumBrowserPage(),
        LearningRoutes.placementTest: (_) => const PlacementTestPage(),
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

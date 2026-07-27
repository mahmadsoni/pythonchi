import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/ai/presentation/screens/ai_assistant_screen.dart';
import '../../features/certificate/presentation/screens/certificate_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/lesson/presentation/screens/lesson_detail_screen.dart';
import '../../features/lesson/presentation/screens/lessons_list_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/playground/presentation/screens/playground_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../shared/widgets/home_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      // Splash always allowed through (it decides where to go next itself).
      if (state.matchedLocation == '/splash') return null;

      final prefs = await SharedPreferences.getInstance();
      final completedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

      if (!completedOnboarding && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (completedOnboarding && state.matchedLocation == '/onboarding') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

      // Full-screen routes reachable from any tab (pushed above the shell).
      GoRoute(
        path: '/lesson/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LessonDetailScreen(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        path: '/quiz/:lessonId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => QuizScreen(lessonId: state.pathParameters['lessonId']!),
      ),
      GoRoute(
        path: '/lessons/:moduleId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LessonsListScreen(moduleId: state.pathParameters['moduleId']!),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/certificate/:courseId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CertificateScreen(courseId: state.pathParameters['courseId']!),
      ),
      GoRoute(
        path: '/ai-assistant',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Bottom-nav shell: 5 persistent tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => _ShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lessons',
              builder: (context, state) => const LessonsListScreen(moduleId: 'python_basics'),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/playground', builder: (context, state) => const PlaygroundScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/leaderboard', builder: (context, state) => const LeaderboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
}

class _ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const _ShellScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return HomeShell(
      currentIndex: navigationShell.currentIndex,
      onTap: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
      child: navigationShell,
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';

import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/career_path/career_path_screen.dart';
import 'presentation/screens/career_path/milestone_detail_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/analytics/analytics_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'presentation/screens/skills/skills_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profile = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      // While auth is being established (or revalidated), don't force redirects.
      // This prevents redirect loops / blank navigation during emulator startup.
      if (authState.isLoading || authState.isRefreshing) {
        return null;
      }

      // On auth errors, stay on auth routes.
      if (authState.hasError) {
        return isAuthRoute ? null : '/login';
      }

      final isAuthenticated = authState.valueOrNull?.session != null;

      // If not authenticated and not on auth route, go to login.
      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      // If authenticated and on auth route, check onboarding.
      if (isAuthenticated && isAuthRoute) {
        final profileData = profile.valueOrNull;

        // Profile may still be loading; avoid premature routing.
        if (profile.isLoading || profile.isRefreshing || profileData == null) {
          return null;
        }

        if (!profileData.isOnboardingComplete) {
          return '/onboarding';
        }
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/career-path/:id',
        builder: (context, state) {
          final pathId = state.pathParameters['id']!;
          return CareerPathScreen(careerPathId: pathId);
        },
      ),
      GoRoute(
        path: '/milestone/:id',
        builder: (context, state) {
          final milestoneId = state.pathParameters['id']!;
          final extra = state.extra as Map<String, dynamic>?;
          return MilestoneDetailScreen(
            milestoneId: milestoneId,
            careerPathId: extra?['careerPathId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/skills',
        builder: (context, state) => const SkillsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

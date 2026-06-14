import 'package:flutter/material.dart';
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
import 'presentation/screens/jobs/jobs_screen.dart';
import 'presentation/screens/jobs/job_detail_screen.dart';
import 'presentation/screens/jobs/job_applicants_screen.dart';
import 'presentation/screens/jobs/saved_jobs_screen.dart';
import 'presentation/screens/jobs/post_job_screen.dart';
import 'presentation/screens/profile/edit_profile_screen.dart';
import 'presentation/screens/feed/feed_screen.dart';
import 'presentation/screens/network/network_screen.dart';
import 'presentation/widgets/common/main_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _homeKey = GlobalKey<NavigatorState>();
final _jobsKey = GlobalKey<NavigatorState>();
final _careerKey = GlobalKey<NavigatorState>();
final _networkKey = GlobalKey<NavigatorState>();
final _profileKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profile = ref.watch(profileProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/login',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/login' || loc == '/signup';

      // While auth is being established (or revalidated), don't force redirects.
      if (authState.isLoading || authState.isRefreshing) {
        return null;
      }

      // On auth errors, stay on auth routes.
      if (authState.hasError) {
        return isAuthRoute ? null : '/login';
      }

      final isAuthenticated = authState.valueOrNull?.session != null;

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && (isAuthRoute || loc == '/')) {
        final profileData = profile.valueOrNull;
        if (profile.isLoading || profile.isRefreshing || profileData == null) {
          return null;
        }
        if (!profileData.isOnboardingComplete) {
          return '/onboarding';
        }
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main app shell with the 5 primary tabs.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(path: '/home', builder: (context, state) => const FeedScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _jobsKey,
            routes: [
              GoRoute(path: '/jobs', builder: (context, state) => const JobsScreen()),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _careerKey,
            routes: [
              GoRoute(
                path: '/career',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _networkKey,
            routes: [
              GoRoute(
                path: '/network',
                builder: (context, state) => const NetworkScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen detail routes (cover the shell / bottom nav).
      GoRoute(
        path: '/job/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/job/:id/applicants',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            JobApplicantsScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/saved-jobs',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SavedJobsScreen(),
      ),
      GoRoute(
        path: '/post-job',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const PostJobScreen(),
      ),
      GoRoute(
        path: '/career-path/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            CareerPathScreen(careerPathId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/milestone/:id',
        parentNavigatorKey: _rootKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return MilestoneDetailScreen(
            milestoneId: state.pathParameters['id']!,
            careerPathId: extra?['careerPathId'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/analytics',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/skills',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SkillsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

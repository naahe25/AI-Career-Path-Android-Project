import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/signup_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/career_path/career_path_screen.dart';
import 'presentation/screens/career_path/milestone_detail_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profile = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      if (isLoading) return '/splash';

      final isAuthenticated = authState.value?.session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';
      final isSplash = state.matchedLocation == '/splash';

      if (!isAuthenticated && !isAuthRoute && !isSplash) {
        return '/login';
      }

      if (isAuthenticated && isAuthRoute) {
        final profileData = profile.value;
        if (profileData != null && !profileData.isOnboardingComplete) {
          return '/onboarding';
        }
        return '/dashboard';
      }

      if (isAuthenticated && isSplash) {
        final profileData = profile.value;
        if (profileData != null && !profileData.isOnboardingComplete) {
          return '/onboarding';
        }
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
    ],
  );
});

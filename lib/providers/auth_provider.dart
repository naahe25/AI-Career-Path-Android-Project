import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/app_config.dart';
import '../data/models/profile_model.dart';
import '../data/demo/demo_data.dart';
import '../data/services/auth_service.dart';
import '../core/utils/logger.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges
      .timeout(const Duration(seconds: 5))
      .handleError((error, stackTrace) {
    appLogger.e('Auth state error: $error');
  });
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Profile state
class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel?>> {
  final AuthService _authService;
  final String? _userId;

  ProfileNotifier(this._authService, this._userId)
    : super(const AsyncValue.loading()) {
    if (AppConfig.demoMode) {
      state = AsyncValue.data(DemoData.profile());
    } else if (_userId != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
    if (AppConfig.demoMode) {
      state = AsyncValue.data(DemoData.profile());
      return;
    }
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      final profile = await _authService.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      appLogger.e('Load profile error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    if (AppConfig.demoMode) {
      final current = state.value ?? DemoData.profile();
      state = AsyncValue.data(
        current.copyWith(
          fullName: updates['full_name'] as String?,
          avatarUrl: updates['avatar_url'] as String?,
          currentSkills: (updates['current_skills'] as List<dynamic>?)
              ?.map((skill) => skill.toString())
              .toList(),
          educationLevel: updates['education_level'] as String?,
          yearsOfExperience: updates['years_of_experience'] as int?,
          currentRole: updates['user_current_role'] as String?,
          desiredField: updates['desired_field'] as String?,
        ),
      );
      return;
    }
    if (_userId == null) return;
    try {
      final updated = await _authService.updateProfile(_userId, updates);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      appLogger.e('Update profile error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel?>>((ref) {
      if (AppConfig.demoMode) {
        final authService = ref.watch(authServiceProvider);
        return ProfileNotifier(authService, AppConfig.demoUserId);
      }
      final user = ref.watch(currentUserProvider);
      final authService = ref.watch(authServiceProvider);
      return ProfileNotifier(authService, user?.id);
    });

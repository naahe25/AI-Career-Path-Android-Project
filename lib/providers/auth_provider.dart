import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/models/profile_model.dart';
import '../data/services/auth_service.dart';
import '../core/utils/logger.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
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
    if (_userId != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
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
      final user = ref.watch(currentUserProvider);
      final authService = ref.watch(authServiceProvider);
      return ProfileNotifier(authService, user?.id);
    });

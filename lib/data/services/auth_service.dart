import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'supabase_service.dart';
import '../../core/utils/logger.dart';

class AuthService {
  final _client = SupabaseService.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );
      appLogger.i('SignUp success: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      appLogger.e('SignUp error: ${e.message}');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      appLogger.i('SignIn success: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      appLogger.e('SignIn error: ${e.message}');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      appLogger.i('SignOut success');
    } on AuthException catch (e) {
      appLogger.e('SignOut error: ${e.message}');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      appLogger.e('Get profile error: $e');
      return null;
    }
  }

  Future<ProfileModel?> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      appLogger.e('Update profile error: $e');
      rethrow;
    }
  }
}

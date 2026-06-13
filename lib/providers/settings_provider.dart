import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_settings_model.dart';
import '../data/services/settings_service.dart';
import '../providers/auth_provider.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) => SettingsService());

class SettingsNotifier extends StateNotifier<AsyncValue<UserSettingsModel>> {
  final SettingsService _service;
  final String? _userId;

  SettingsNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (_userId == null) {
      state = const AsyncValue.data(null) as AsyncValue<UserSettingsModel>;
      return;
    }

    try {
      state = const AsyncValue.loading();
      var settings = await _service.getUserSettings(_userId);
      settings ??= await _service.initializeSettings(_userId);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    if (_userId == null) return;
    try {
      await _service.updateSettings(_userId, settings);
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTheme(String theme) async {
    if (_userId == null) return;
    try {
      await _service.updateTheme(_userId, theme);
      final current = state.value;
      if (current != null) {
        state = AsyncValue.data(current.copyWith(theme: theme));
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateNotifications({
    bool? enabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? newsletter,
  }) async {
    if (_userId == null) return;
    try {
      await _service.updateNotificationPreferences(
        _userId,
        enabled: enabled,
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        newsletter: newsletter,
      );
      await _loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePrivacy(String level) async {
    if (_userId == null) return;
    try {
      await _service.updatePrivacy(_userId, level);
      await _loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLanguage(String language) async {
    if (_userId == null) return;
    try {
      await _service.updateLanguage(_userId, language);
      await _loadSettings();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<UserSettingsModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service, user?.id);
});

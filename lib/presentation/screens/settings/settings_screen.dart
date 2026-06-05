import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: settingsAsync.when(
        data: (settings) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appearance
              const Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingsTile(
                'Theme',
                settings.theme.toUpperCase(),
                () => _showThemeDialog(context, settings, ref),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Notifications
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildToggleTile(
                'All Notifications',
                settings.notificationsEnabled,
                (value) => ref.read(settingsNotifierProvider.notifier)
                    .updateNotifications(enabled: value),
              ),
              _buildToggleTile(
                'Email Notifications',
                settings.emailNotifications,
                (value) => ref.read(settingsNotifierProvider.notifier)
                    .updateNotifications(emailNotifications: value),
              ),
              _buildToggleTile(
                'Push Notifications',
                settings.pushNotifications,
                (value) => ref.read(settingsNotifierProvider.notifier)
                    .updateNotifications(pushNotifications: value),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Privacy
              const Text(
                'Privacy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingsTile(
                'Privacy Level',
                settings.privacyLevel.toUpperCase(),
                () => _showPrivacyDialog(context, settings, ref),
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Account
              const Text(
                'Account',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              _buildSettingsTile(
                'Language',
                settings.language.toUpperCase(),
                () {},
              ),
              _buildToggleTile(
                'Two-Factor Authentication',
                settings.twoFactorEnabled,
                (value) {
                  if (value) {
                    ref.read(settingsNotifierProvider.notifier)
                        .updateSettings(settings.copyWith(twoFactorEnabled: true));
                  }
                },
              ),
              const SizedBox(height: AppDimensions.paddingL),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingL),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSettingsTile(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard.withOpacity(0.5),
          border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withOpacity(0.5),
        border: Border.all(color: AppColors.textMuted.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    dynamic settings,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Select Theme'),
          ),
          ...['system', 'light', 'dark'].map(
            (theme) => ListTile(
              title: Text(theme.toUpperCase()),
              trailing: settings.theme == theme
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(settingsNotifierProvider.notifier).updateTheme(theme);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(
    BuildContext context,
    dynamic settings,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Privacy Level'),
          ),
          ...['private', 'friends', 'public'].map(
            (level) => ListTile(
              title: Text(level.toUpperCase()),
              trailing: settings.privacyLevel == level
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                ref.read(settingsNotifierProvider.notifier).updatePrivacy(level);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.pop(context);
                context.go('/login');
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

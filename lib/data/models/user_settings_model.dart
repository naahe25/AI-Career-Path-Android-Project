class UserSettingsModel {
  final String id;
  final String userId;
  final String theme;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool pushNotifications;
  final bool newsletterSubscribed;
  final String language;
  final String privacyLevel;
  final bool twoFactorEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserSettingsModel({
    required this.id,
    required this.userId,
    required this.theme,
    required this.notificationsEnabled,
    required this.emailNotifications,
    required this.pushNotifications,
    required this.newsletterSubscribed,
    required this.language,
    required this.privacyLevel,
    required this.twoFactorEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      theme: json['theme'] as String? ?? 'system',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      emailNotifications: json['email_notifications'] as bool? ?? true,
      pushNotifications: json['push_notifications'] as bool? ?? true,
      newsletterSubscribed: json['newsletter_subscribed'] as bool? ?? true,
      language: json['language'] as String? ?? 'en',
      privacyLevel: json['privacy_level'] as String? ?? 'private',
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'theme': theme,
    'notifications_enabled': notificationsEnabled,
    'email_notifications': emailNotifications,
    'push_notifications': pushNotifications,
    'newsletter_subscribed': newsletterSubscribed,
    'language': language,
    'privacy_level': privacyLevel,
    'two_factor_enabled': twoFactorEnabled,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  UserSettingsModel copyWith({
    String? id,
    String? userId,
    String? theme,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? newsletterSubscribed,
    String? language,
    String? privacyLevel,
    bool? twoFactorEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      newsletterSubscribed: newsletterSubscribed ?? this.newsletterSubscribed,
      language: language ?? this.language,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NotificationSettingsModel {
  final bool milestonesUnlocked;
  final bool achievementsEarned;
  final bool streakReminders;
  final bool weeklyReports;
  final bool recommendedResources;
  final bool careerInsights;

  NotificationSettingsModel({
    required this.milestonesUnlocked,
    required this.achievementsEarned,
    required this.streakReminders,
    required this.weeklyReports,
    required this.recommendedResources,
    required this.careerInsights,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      milestonesUnlocked: json['milestones_unlocked'] as bool? ?? true,
      achievementsEarned: json['achievements_earned'] as bool? ?? true,
      streakReminders: json['streak_reminders'] as bool? ?? true,
      weeklyReports: json['weekly_reports'] as bool? ?? true,
      recommendedResources: json['recommended_resources'] as bool? ?? true,
      careerInsights: json['career_insights'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'milestones_unlocked': milestonesUnlocked,
    'achievements_earned': achievementsEarned,
    'streak_reminders': streakReminders,
    'weekly_reports': weeklyReports,
    'recommended_resources': recommendedResources,
    'career_insights': careerInsights,
  };

  NotificationSettingsModel copyWith({
    bool? milestonesUnlocked,
    bool? achievementsEarned,
    bool? streakReminders,
    bool? weeklyReports,
    bool? recommendedResources,
    bool? careerInsights,
  }) {
    return NotificationSettingsModel(
      milestonesUnlocked: milestonesUnlocked ?? this.milestonesUnlocked,
      achievementsEarned: achievementsEarned ?? this.achievementsEarned,
      streakReminders: streakReminders ?? this.streakReminders,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      recommendedResources: recommendedResources ?? this.recommendedResources,
      careerInsights: careerInsights ?? this.careerInsights,
    );
  }
}

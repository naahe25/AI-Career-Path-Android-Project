class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String? iconUrl;
  final int? threshold;
  final String type;
  final DateTime createdAt;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconUrl,
    this.threshold,
    required this.type,
    required this.createdAt,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String?,
      threshold: json['threshold'] as int?,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'icon_url': iconUrl,
    'threshold': threshold,
    'type': type,
    'created_at': createdAt.toIso8601String(),
  };
}

class UserAchievementModel {
  final String id;
  final String userId;
  final String achievementId;
  final DateTime earnedAt;
  final AchievementModel? achievement;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
    this.achievement,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      achievementId: json['achievement_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      achievement: json['achievements'] != null
        ? AchievementModel.fromJson(json['achievements'] as Map<String, dynamic>)
        : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'achievement_id': achievementId,
    'earned_at': earnedAt.toIso8601String(),
  };
}

class BadgeModel {
  final String id;
  final String userId;
  final String title;
  final int level;
  final int progress;
  final int maxProgress;
  final DateTime createdAt;

  BadgeModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.level,
    required this.progress,
    required this.maxProgress,
    required this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      level: json['level'] as int? ?? 1,
      progress: json['progress'] as int? ?? 0,
      maxProgress: json['max_progress'] as int? ?? 100,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'level': level,
    'progress': progress,
    'max_progress': maxProgress,
    'created_at': createdAt.toIso8601String(),
  };

  double get progressPercentage => (progress / maxProgress) * 100;

  BadgeModel copyWith({
    String? id,
    String? userId,
    String? title,
    int? level,
    int? progress,
    int? maxProgress,
    DateTime? createdAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      level: level ?? this.level,
      progress: progress ?? this.progress,
      maxProgress: maxProgress ?? this.maxProgress,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

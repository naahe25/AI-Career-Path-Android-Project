import 'package:intl/intl.dart';

class AnalyticsModel {
  final String id;
  final String userId;
  final int learningHours;
  final int milestonesCompleted;
  final int skillsAcquired;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final Map<String, dynamic>? weeklyProgress;
  final Map<String, dynamic>? monthlyProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnalyticsModel({
    required this.id,
    required this.userId,
    required this.learningHours,
    required this.milestonesCompleted,
    required this.skillsAcquired,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    this.weeklyProgress,
    this.monthlyProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AnalyticsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      learningHours: json['learning_hours'] as int? ?? 0,
      milestonesCompleted: json['milestones_completed'] as int? ?? 0,
      skillsAcquired: json['skills_acquired'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastActivityDate: json['last_activity_date'] != null
        ? DateTime.parse(json['last_activity_date'] as String)
        : null,
      weeklyProgress: json['weekly_progress'] as Map<String, dynamic>?,
      monthlyProgress: json['monthly_progress'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'learning_hours': learningHours,
    'milestones_completed': milestonesCompleted,
    'skills_acquired': skillsAcquired,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'last_activity_date': lastActivityDate?.toIso8601String(),
    'weekly_progress': weeklyProgress,
    'monthly_progress': monthlyProgress,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  AnalyticsModel copyWith({
    String? id,
    String? userId,
    int? learningHours,
    int? milestonesCompleted,
    int? skillsAcquired,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    Map<String, dynamic>? weeklyProgress,
    Map<String, dynamic>? monthlyProgress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalyticsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      learningHours: learningHours ?? this.learningHours,
      milestonesCompleted: milestonesCompleted ?? this.milestonesCompleted,
      skillsAcquired: skillsAcquired ?? this.skillsAcquired,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      monthlyProgress: monthlyProgress ?? this.monthlyProgress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get formattedLearningHours {
    return '${learningHours}h';
  }

  String get formattedLastActive {
    if (lastActivityDate == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate!);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return DateFormat('MMM d').format(lastActivityDate!);
  }

  double get averageHoursPerMilestone {
    if (milestonesCompleted == 0) return 0;
    return learningHours / milestonesCompleted;
  }
}

class DailyProgressModel {
  final String id;
  final String userId;
  final DateTime date;
  final int milestonesWorked;
  final int learningMinutes;
  final int skillsWorkedOn;
  final DateTime createdAt;

  DailyProgressModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.milestonesWorked,
    required this.learningMinutes,
    required this.skillsWorkedOn,
    required this.createdAt,
  });

  factory DailyProgressModel.fromJson(Map<String, dynamic> json) {
    return DailyProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      milestonesWorked: json['milestones_worked'] as int? ?? 0,
      learningMinutes: json['learning_minutes'] as int? ?? 0,
      skillsWorkedOn: json['skills_worked_on'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'date': date.toIso8601String(),
    'milestones_worked': milestonesWorked,
    'learning_minutes': learningMinutes,
    'skills_worked_on': skillsWorkedOn,
    'created_at': createdAt.toIso8601String(),
  };
}

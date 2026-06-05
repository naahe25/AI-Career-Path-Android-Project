class SkillModel {
  final String id;
  final String name;
  final String? description;
  final String? category;
  final String difficulty;
  final int estimatedHours;
  final String? iconUrl;
  final DateTime createdAt;

  SkillModel({
    required this.id,
    required this.name,
    this.description,
    this.category,
    required this.difficulty,
    required this.estimatedHours,
    this.iconUrl,
    required this.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String? ?? 'intermediate',
      estimatedHours: json['estimated_hours'] as int? ?? 0,
      iconUrl: json['icon_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'estimated_hours': estimatedHours,
    'icon_url': iconUrl,
    'created_at': createdAt.toIso8601String(),
  };
}

class UserSkillModel {
  final String id;
  final String userId;
  final String skillId;
  final int proficiencyLevel;
  final int hoursInvested;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final SkillModel? skill;

  UserSkillModel({
    required this.id,
    required this.userId,
    required this.skillId,
    required this.proficiencyLevel,
    required this.hoursInvested,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    this.skill,
  });

  factory UserSkillModel.fromJson(Map<String, dynamic> json) {
    return UserSkillModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      skillId: json['skill_id'] as String,
      proficiencyLevel: json['proficiency_level'] as int? ?? 0,
      hoursInvested: json['hours_invested'] as int? ?? 0,
      startedAt: json['started_at'] != null
        ? DateTime.parse(json['started_at'] as String)
        : null,
      completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'] as String)
        : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      skill: json['skills'] != null
        ? SkillModel.fromJson(json['skills'] as Map<String, dynamic>)
        : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'skill_id': skillId,
    'proficiency_level': proficiencyLevel,
    'hours_invested': hoursInvested,
    'started_at': startedAt?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

  bool get isCompleted => completedAt != null;

  String get proficiencyLabel {
    if (proficiencyLevel < 25) return 'Beginner';
    if (proficiencyLevel < 50) return 'Intermediate';
    if (proficiencyLevel < 75) return 'Advanced';
    return 'Expert';
  }

  UserSkillModel copyWith({
    String? id,
    String? userId,
    String? skillId,
    int? proficiencyLevel,
    int? hoursInvested,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? createdAt,
    SkillModel? skill,
  }) {
    return UserSkillModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      skillId: skillId ?? this.skillId,
      proficiencyLevel: proficiencyLevel ?? this.proficiencyLevel,
      hoursInvested: hoursInvested ?? this.hoursInvested,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      skill: skill ?? this.skill,
    );
  }
}

class SkillResourceModel {
  final String id;
  final String skillId;
  final String resourceType;
  final String title;
  final String? url;
  final String? difficulty;
  final int? durationHours;
  final DateTime createdAt;

  SkillResourceModel({
    required this.id,
    required this.skillId,
    required this.resourceType,
    required this.title,
    this.url,
    this.difficulty,
    this.durationHours,
    required this.createdAt,
  });

  factory SkillResourceModel.fromJson(Map<String, dynamic> json) {
    return SkillResourceModel(
      id: json['id'] as String,
      skillId: json['skill_id'] as String,
      resourceType: json['resource_type'] as String,
      title: json['title'] as String,
      url: json['url'] as String?,
      difficulty: json['difficulty'] as String?,
      durationHours: json['duration_hours'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'skill_id': skillId,
    'resource_type': resourceType,
    'title': title,
    'url': url,
    'difficulty': difficulty,
    'duration_hours': durationHours,
    'created_at': createdAt.toIso8601String(),
  };
}

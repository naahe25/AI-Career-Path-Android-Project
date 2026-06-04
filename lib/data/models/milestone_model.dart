class ResourceModel {
  final String title;
  final String url;
  final String type;

  ResourceModel({required this.title, required this.url, required this.type});

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      title: json['title'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? 'link',
    );
  }

  Map<String, dynamic> toJson() => {'title': title, 'url': url, 'type': type};
}

class MilestoneModel {
  final String id;
  final String careerPathId;
  final String title;
  final String? description;
  final int orderIndex;
  final bool isCompleted;
  final List<ResourceModel> resources;
  final List<String> skillsGained;
  final int? estimatedWeeks;
  final DateTime? completedAt;
  final DateTime createdAt;

  MilestoneModel({
    required this.id,
    required this.careerPathId,
    required this.title,
    this.description,
    required this.orderIndex,
    this.isCompleted = false,
    this.resources = const [],
    this.skillsGained = const [],
    this.estimatedWeeks,
    this.completedAt,
    required this.createdAt,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    List<ResourceModel> resources = [];
    if (json['resources'] != null) {
      final resourcesList = json['resources'] as List<dynamic>;
      resources = resourcesList
          .map((r) => ResourceModel.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    return MilestoneModel(
      id: json['id'] as String,
      careerPathId: json['career_path_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      orderIndex: json['order_index'] as int,
      isCompleted: json['is_completed'] as bool? ?? false,
      resources: resources,
      skillsGained:
          (json['skills_gained'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      estimatedWeeks: json['estimated_weeks'] as int?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'career_path_id': careerPathId,
    'title': title,
    'description': description,
    'order_index': orderIndex,
    'is_completed': isCompleted,
    'resources': resources.map((r) => r.toJson()).toList(),
    'skills_gained': skillsGained,
    'estimated_weeks': estimatedWeeks,
  };

  MilestoneModel copyWith({bool? isCompleted, DateTime? completedAt}) {
    return MilestoneModel(
      id: id,
      careerPathId: careerPathId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      resources: resources,
      skillsGained: skillsGained,
      estimatedWeeks: estimatedWeeks,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}

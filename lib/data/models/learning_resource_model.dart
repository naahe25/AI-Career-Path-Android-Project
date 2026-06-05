class LearningResourceModel {
  final String id;
  final String title;
  final String? description;
  final String resourceType;
  final String? url;
  final String? provider;
  final String? difficulty;
  final int? estimatedHours;
  final double? rating;
  final int reviewsCount;
  final String? thumbnailUrl;
  final DateTime createdAt;

  LearningResourceModel({
    required this.id,
    required this.title,
    this.description,
    required this.resourceType,
    this.url,
    this.provider,
    this.difficulty,
    this.estimatedHours,
    this.rating,
    required this.reviewsCount,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory LearningResourceModel.fromJson(Map<String, dynamic> json) {
    return LearningResourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      resourceType: json['resource_type'] as String,
      url: json['url'] as String?,
      provider: json['provider'] as String?,
      difficulty: json['difficulty'] as String?,
      estimatedHours: json['estimated_hours'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: json['reviews_count'] as int? ?? 0,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'resource_type': resourceType,
    'url': url,
    'provider': provider,
    'difficulty': difficulty,
    'estimated_hours': estimatedHours,
    'rating': rating,
    'reviews_count': reviewsCount,
    'thumbnail_url': thumbnailUrl,
    'created_at': createdAt.toIso8601String(),
  };

  String get resourceIcon {
    switch (resourceType.toLowerCase()) {
      case 'course':
        return '📚';
      case 'book':
        return '📖';
      case 'video':
        return '📹';
      case 'article':
        return '📄';
      case 'project':
        return '💻';
      default:
        return '📌';
    }
  }

  String get ratingDisplay {
    if (rating == null) return 'No rating';
    return '${rating!.toStringAsFixed(1)} ⭐ (${reviewsCount} reviews)';
  }
}

class UserResourceModel {
  final String id;
  final String userId;
  final String resourceId;
  final bool isBookmarked;
  final DateTime? completedAt;
  final String? notes;
  final DateTime createdAt;
  final LearningResourceModel? resource;

  UserResourceModel({
    required this.id,
    required this.userId,
    required this.resourceId,
    required this.isBookmarked,
    this.completedAt,
    this.notes,
    required this.createdAt,
    this.resource,
  });

  factory UserResourceModel.fromJson(Map<String, dynamic> json) {
    return UserResourceModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      resourceId: json['resource_id'] as String,
      isBookmarked: json['is_bookmarked'] as bool? ?? false,
      completedAt: json['completed_at'] != null
        ? DateTime.parse(json['completed_at'] as String)
        : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      resource: json['learning_resources'] != null
        ? LearningResourceModel.fromJson(json['learning_resources'] as Map<String, dynamic>)
        : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'resource_id': resourceId,
    'is_bookmarked': isBookmarked,
    'completed_at': completedAt?.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isCompleted => completedAt != null;
}

import 'milestone_model.dart';

class CareerPathModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final String targetRole;
  final int? estimatedDurationMonths;
  final String? difficultyLevel;
  final bool isActive;
  final List<MilestoneModel> milestones;
  final DateTime createdAt;
  final DateTime updatedAt;

  CareerPathModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.targetRole,
    this.estimatedDurationMonths,
    this.difficultyLevel,
    this.isActive = true,
    this.milestones = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CareerPathModel.fromJson(Map<String, dynamic> json) {
    List<MilestoneModel> milestones = [];
    if (json['milestones'] != null) {
      final milestonesList = json['milestones'] as List<dynamic>;
      milestones = milestonesList
          .map((m) => MilestoneModel.fromJson(m as Map<String, dynamic>))
          .toList();
      milestones.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    }

    return CareerPathModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      targetRole: json['target_role'] as String,
      estimatedDurationMonths: json['estimated_duration_months'] as int?,
      difficultyLevel: json['difficulty_level'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      milestones: milestones,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  double get completionPercentage {
    if (milestones.isEmpty) return 0.0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return (completed / milestones.length) * 100;
  }

  int get completedMilestones => milestones.where((m) => m.isCompleted).length;

  MilestoneModel? get nextMilestone {
    try {
      return milestones.firstWhere((m) => !m.isCompleted);
    } catch (_) {
      return null;
    }
  }
}

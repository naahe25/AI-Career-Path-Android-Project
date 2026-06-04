import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'supabase_service.dart';
import '../../core/utils/logger.dart';

class GeneratedPath {
  final String title;
  final String description;
  final String targetRole;
  final int estimatedDurationMonths;
  final String difficultyLevel;
  final List<Map<String, dynamic>> milestones;

  GeneratedPath({
    required this.title,
    required this.description,
    required this.targetRole,
    required this.estimatedDurationMonths,
    required this.difficultyLevel,
    required this.milestones,
  });

  factory GeneratedPath.fromJson(Map<String, dynamic> json) {
    final milestonesList =
        (json['milestones'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
        [];
    return GeneratedPath(
      title: json['title'] as String? ?? 'Career Path',
      description: json['description'] as String? ?? '',
      targetRole: json['target_role'] as String? ?? 'Professional',
      estimatedDurationMonths: json['estimated_duration_months'] as int? ?? 12,
      difficultyLevel: json['difficulty_level'] as String? ?? 'intermediate',
      milestones: milestonesList,
    );
  }
}

class AiService {
  Future<List<GeneratedPath>> generateCareerPaths(ProfileModel profile) async {
    try {
      final session = SupabaseService.auth.currentSession;
      if (session == null) throw Exception('Not authenticated');

      final response = await SupabaseService.client.functions.invoke(
        'generate-career-path',
        body: {
          'full_name': profile.fullName ?? 'User',
          'current_skills': profile.currentSkills,
          'education_level': profile.educationLevel ?? '',
          'years_of_experience': profile.yearsOfExperience,
          'current_role': profile.currentRole ?? '',
          'desired_field': profile.desiredField ?? '',
        },
      );

      if (response.status != 200) {
        throw Exception('AI service returned status ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception(data['error'] ?? 'Unknown AI error');
      }

      final pathsList = data['data'] as List<dynamic>;
      final paths = pathsList
          .map((p) => GeneratedPath.fromJson(p as Map<String, dynamic>))
          .toList();

      appLogger.i('Generated ${paths.length} career paths');
      return paths;
    } on FunctionException catch (e) {
      appLogger.e('Edge function error: ${e.details}');
      rethrow;
    } catch (e) {
      appLogger.e('AI service error: $e');
      rethrow;
    }
  }
}

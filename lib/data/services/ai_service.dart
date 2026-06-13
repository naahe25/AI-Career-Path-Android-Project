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
    // Make the app usable even when Edge/AI service is temporarily unavailable.
    // The UI will still work using fallback demo paths.
    try {

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
      return _fallbackCareerPaths(profile);
    } on Exception catch (e) {
      appLogger.e('AI service error: $e');
      // If user is not authenticated, also return fallback so the app keeps working.
      return _fallbackCareerPaths(profile);
    } catch (e) {
      appLogger.e('AI service error: $e');
      return _fallbackCareerPaths(profile);
    }
  }

  List<GeneratedPath> _fallbackCareerPaths(ProfileModel profile) {
    final targetField = (profile.desiredField ?? '').trim();
    final baseTitle = targetField.isNotEmpty
        ? targetField
        : 'Software Engineering';

    return [
      GeneratedPath(
        title: '$baseTitle - Career Path (Starter)',
        description:
            'Demo fallback path generated locally because the AI service is unavailable.',
        targetRole: 'Professional',
        estimatedDurationMonths: 12,
        difficultyLevel: 'beginner',
        milestones: [
          {
            'title': 'Foundations',
            'description': 'Core concepts & fundamentals',
            'completed': false,
          },
          {
            'title': 'Projects',
            'description': 'Build 2-3 portfolio projects',
            'completed': false,
          },
          {
            'title': 'Interview Prep',
            'description': 'Practice behavioral + technical rounds',
            'completed': false,
          },
        ],
      ),
      GeneratedPath(
        title: '$baseTitle - Career Path (Intermediate)',
        description:
            'A second demo fallback option to keep the app fully usable without backend.',
        targetRole: 'Senior',
        estimatedDurationMonths: 18,
        difficultyLevel: 'intermediate',
        milestones: [
          {
            'title': 'Specialization',
            'description': 'Pick one specialization track',
            'completed': false,
          },
          {
            'title': 'Advanced Projects',
            'description': 'Ship one production-like project',
            'completed': false,
          },
          {
            'title': 'Leadership & Impact',
            'description': 'Show impact, metrics, and collaboration',
            'completed': false,
          },
        ],
      ),
    ];
  }
}

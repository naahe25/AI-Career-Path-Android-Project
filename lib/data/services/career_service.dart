import '../models/career_path_model.dart';
import '../models/milestone_model.dart';
import 'supabase_service.dart';
import '../../core/utils/logger.dart';

class CareerService {
  get _client => SupabaseService.client;

  Future<List<CareerPathModel>> getUserCareerPaths(String userId) async {
    try {
      final data = await _client
          .from('career_paths')
          .select('*, milestones(*)')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .map((json) => CareerPathModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      appLogger.e('Get career paths error: $e');
      rethrow;
    }
  }

  Future<CareerPathModel> createCareerPath({
    required String userId,
    required String title,
    required String description,
    required String targetRole,
    required int estimatedDurationMonths,
    required String difficultyLevel,
    required List<Map<String, dynamic>> milestones,
  }) async {
    try {
      // Insert career path
      final pathData = await _client
          .from('career_paths')
          .insert({
            'user_id': userId,
            'title': title,
            'description': description,
            'target_role': targetRole,
            'estimated_duration_months': estimatedDurationMonths,
            'difficulty_level': difficultyLevel,
          })
          .select()
          .single();

      final pathId = pathData['id'] as String;

      // Insert milestones
      final milestonesData = milestones.asMap().entries.map((entry) {
        final index = entry.key;
        final milestone = entry.value;
        return {
          'career_path_id': pathId,
          'title': milestone['title'],
          'description': milestone['description'],
          'order_index': index,
          'resources': milestone['resources'] ?? [],
          'skills_gained': milestone['skills_gained'] ?? [],
          'estimated_weeks': milestone['estimated_weeks'],
        };
      }).toList();

      await _client.from('milestones').insert(milestonesData);

      // Fetch complete path with milestones
      final completeData = await _client
          .from('career_paths')
          .select('*, milestones(*)')
          .eq('id', pathId)
          .single();

      // Initialize progress tracking
      await _client.from('user_progress').insert({
        'user_id': userId,
        'career_path_id': pathId,
        'completion_percentage': 0.0,
      });

      appLogger.i('Career path created: $pathId');
      return CareerPathModel.fromJson(completeData);
    } catch (e) {
      appLogger.e('Create career path error: $e');
      rethrow;
    }
  }

  Future<MilestoneModel> toggleMilestoneComplete(
    String milestoneId,
    bool isCompleted,
  ) async {
    try {
      final data = await _client
          .from('milestones')
          .update({
            'is_completed': isCompleted,
            'completed_at': isCompleted
                ? DateTime.now().toIso8601String()
                : null,
          })
          .eq('id', milestoneId)
          .select()
          .single();

      final milestone = MilestoneModel.fromJson(data);

      // Update progress percentage
      await _updateProgress(milestone.careerPathId);

      return milestone;
    } catch (e) {
      appLogger.e('Toggle milestone error: $e');
      rethrow;
    }
  }

  Future<void> _updateProgress(String careerPathId) async {
    try {
      final milestonesData = await _client
          .from('milestones')
          .select('is_completed')
          .eq('career_path_id', careerPathId);

      final milestones = milestonesData as List<dynamic>;
      if (milestones.isEmpty) return;

      final completed = milestones
          .where((m) => m['is_completed'] == true)
          .length;
      final percentage = (completed / milestones.length) * 100;

      final userId = SupabaseService.currentUserId;
      if (userId == null) return;

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'career_path_id': careerPathId,
        'completion_percentage': percentage,
        'last_activity_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      appLogger.e('Update progress error: $e');
    }
  }

  Future<void> deleteCareerPath(String pathId) async {
    await _client
        .from('career_paths')
        .update({'is_active': false})
        .eq('id', pathId);
  }
}

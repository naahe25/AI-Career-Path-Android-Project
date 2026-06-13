import '../models/skill_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class SkillService {
  final _client = SupabaseService.client;

  Future<List<SkillModel>> getAllSkills({String? category, String? difficulty}) async {
    try {
      var query = _client.from('skills').select();
      if (category != null) query = query.eq('category', category);
      if (difficulty != null) query = query.eq('difficulty', difficulty);

      final data = await query.order('name', ascending: true);
      return List<SkillModel>.from(
        (data as List).map((x) => SkillModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get all skills error: $e');
      throw ServerException(
        message: 'Failed to fetch skills',
        originalException: e,
      );
    }
  }

  Future<SkillModel?> getSkillById(String skillId) async {
    try {
      final data = await _client
          .from('skills')
          .select()
          .eq('id', skillId)
          .maybeSingle();

      return data != null ? SkillModel.fromJson(data) : null;
    } catch (e) {
      appLogger.e('Get skill error: $e');
      throw ServerException(
        message: 'Failed to fetch skill',
        originalException: e,
      );
    }
  }

  Future<List<UserSkillModel>> getUserSkills(String userId) async {
    try {
      final data = await _client
          .from('user_skills')
          .select('''
            id,
            user_id,
            skill_id,
            proficiency_level,
            hours_invested,
            started_at,
            completed_at,
            created_at,
            skills(id, name, description, category, difficulty, estimated_hours, icon_url, created_at)
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<UserSkillModel>.from(
        (data as List).map((x) => UserSkillModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get user skills error: $e');
      throw ServerException(
        message: 'Failed to fetch user skills',
        originalException: e,
      );
    }
  }

  Future<UserSkillModel> startSkill(String userId, String skillId) async {
    try {
      final userSkill = {
        'user_id': userId,
        'skill_id': skillId,
        'proficiency_level': 0,
        'hours_invested': 0,
        'started_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('user_skills').insert(userSkill);

      return UserSkillModel(
        id: '${userId}_$skillId',
        userId: userId,
        skillId: skillId,
        proficiencyLevel: 0,
        hoursInvested: 0,
        startedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
    } catch (e) {
      appLogger.e('Start skill error: $e');
      throw ServerException(
        message: 'Failed to start skill',
        originalException: e,
      );
    }
  }

  Future<void> updateSkillProgress(String userSkillId, {
    int? proficiencyLevel,
    int? hoursInvested,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (proficiencyLevel != null) updates['proficiency_level'] = proficiencyLevel;
      if (hoursInvested != null) updates['hours_invested'] = hoursInvested;

      await _client
          .from('user_skills')
          .update(updates)
          .eq('id', userSkillId);
    } catch (e) {
      appLogger.e('Update skill progress error: $e');
      throw ServerException(
        message: 'Failed to update skill progress',
        originalException: e,
      );
    }
  }

  Future<void> completeSkill(String userSkillId) async {
    try {
      await _client
          .from('user_skills')
          .update({'completed_at': DateTime.now().toIso8601String()})
          .eq('id', userSkillId);
    } catch (e) {
      appLogger.e('Complete skill error: $e');
      throw ServerException(
        message: 'Failed to complete skill',
        originalException: e,
      );
    }
  }

  Future<List<SkillResourceModel>> getSkillResources(String skillId) async {
    try {
      final data = await _client
          .from('skill_resources')
          .select()
          .eq('skill_id', skillId)
          .order('created_at', ascending: false);

      return List<SkillResourceModel>.from(
        (data as List).map((x) => SkillResourceModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get skill resources error: $e');
      throw ServerException(
        message: 'Failed to fetch resources',
        originalException: e,
      );
    }
  }

  Future<int> getUserSkillCount(String userId) async {
    try {
      final data = await _client
          .from('user_skills')
          .select()
          .eq('user_id', userId);

      return data.length;
    } catch (e) {
      appLogger.e('Get skill count error: $e');
      return 0;
    }
  }

  Future<int> getCompletedSkillCount(String userId) async {
    try {
      final data = await _client
          .from('user_skills')
          .select()
          .eq('user_id', userId)
          .not('completed_at', 'is', null);

      return data.length;
    } catch (e) {
      appLogger.e('Get completed skill count error: $e');
      return 0;
    }
  }

  Future<List<SkillModel>> searchSkills(String query) async {
    try {
      final data = await _client
          .from('skills')
          .select()
          .ilike('name', '%$query%')
          .limit(10);

      return List<SkillModel>.from(
        (data as List).map((x) => SkillModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Search skills error: $e');
      throw ServerException(
        message: 'Failed to search skills',
        originalException: e,
      );
    }
  }
}

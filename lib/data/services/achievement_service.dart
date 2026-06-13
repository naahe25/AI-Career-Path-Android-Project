import '../models/achievement_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class AchievementService {
  final _client = SupabaseService.client;

  Future<List<AchievementModel>> getAllAchievements() async {
    try {
      final data = await _client
          .from('achievements')
          .select()
          .order('created_at', ascending: false);

      return List<AchievementModel>.from(
        (data as List).map((x) => AchievementModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get achievements error: $e');
      throw ServerException(
        message: 'Failed to fetch achievements',
        originalException: e,
      );
    }
  }

  Future<List<UserAchievementModel>> getUserAchievements(String userId) async {
    try {
      final data = await _client
          .from('user_achievements')
          .select('''
            id,
            user_id,
            achievement_id,
            earned_at,
            achievements(id, title, description, icon_url, threshold, type, created_at)
          ''')
          .eq('user_id', userId)
          .order('earned_at', ascending: false);

      return List<UserAchievementModel>.from(
        (data as List).map((x) => UserAchievementModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get user achievements error: $e');
      throw ServerException(
        message: 'Failed to fetch user achievements',
        originalException: e,
      );
    }
  }

  Future<void> earnAchievement(String userId, String achievementId) async {
    try {
      await _client.from('user_achievements').insert({
        'user_id': userId,
        'achievement_id': achievementId,
        'earned_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      appLogger.e('Earn achievement error: $e');
      throw ServerException(
        message: 'Failed to earn achievement',
        originalException: e,
      );
    }
  }

  Future<List<BadgeModel>> getUserBadges(String userId) async {
    try {
      final data = await _client
          .from('badges')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<BadgeModel>.from(
        (data as List).map((x) => BadgeModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get badges error: $e');
      throw ServerException(
        message: 'Failed to fetch badges',
        originalException: e,
      );
    }
  }

  Future<void> updateBadgeProgress(String badgeId, int progress, {int? level}) async {
    try {
      final updates = {
        'progress': progress,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (level != null) updates['level'] = level;

      await _client
          .from('badges')
          .update(updates)
          .eq('id', badgeId);
    } catch (e) {
      appLogger.e('Update badge progress error: $e');
      throw ServerException(
        message: 'Failed to update badge',
        originalException: e,
      );
    }
  }

  Future<void> createBadge(BadgeModel badge) async {
    try {
      await _client.from('badges').insert(badge.toJson());
    } catch (e) {
      appLogger.e('Create badge error: $e');
      throw ServerException(
        message: 'Failed to create badge',
        originalException: e,
      );
    }
  }

  Future<bool> hasAchievement(String userId, String achievementId) async {
    try {
      final data = await _client
          .from('user_achievements')
          .select('id')
          .eq('user_id', userId)
          .eq('achievement_id', achievementId)
          .maybeSingle();

      return data != null;
    } catch (e) {
      appLogger.e('Check achievement error: $e');
      return false;
    }
  }

  Future<int> getAchievementCount(String userId) async {
    try {
      final data = await _client
          .from('user_achievements')
          .select()
          .eq('user_id', userId);

      return data.length;
    } catch (e) {
      appLogger.e('Get achievement count error: $e');
      return 0;
    }
  }
}

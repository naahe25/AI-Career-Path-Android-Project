import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analytics_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class AnalyticsService {
  SupabaseClient get _client => SupabaseService.client;

  Future<AnalyticsModel?> getUserAnalytics(String userId) async {
    try {
      final data = await _client
          .from('user_analytics')
          .select()
          .eq('user_id', userId)
          .single();
      return AnalyticsModel.fromJson(data);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return null;
      }
      appLogger.e('Get analytics error: ${e.message}');
      throw ServerException(
        message: 'Failed to fetch analytics',
        statusCode: int.tryParse(e.code ?? ''),
        originalException: e,
      );
    } catch (e) {
      appLogger.e('Analytics error: $e');
      throw ServerException(
        message: 'Failed to fetch analytics',
        originalException: e,
      );
    }
  }

  Future<List<DailyProgressModel>> getDailyProgress(String userId,
      {int daysBack = 30}) async {
    try {
      final startDate = DateTime.now().subtract(Duration(days: daysBack));
      final data = await _client
          .from('daily_progress')
          .select()
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .order('date', ascending: false);

      return List<DailyProgressModel>.from(
        (data as List).map((x) => DailyProgressModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get daily progress error: $e');
      throw ServerException(
        message: 'Failed to fetch daily progress',
        originalException: e,
      );
    }
  }

  Future<void> recordDailyProgress(String userId, DailyProgressModel progress) async {
    try {
      await _client.from('daily_progress').insert(progress.toJson());
    } catch (e) {
      appLogger.e('Record daily progress error: $e');
      throw ServerException(
        message: 'Failed to record progress',
        originalException: e,
      );
    }
  }

  Future<void> updateAnalytics(String userId, {
    int? learningHours,
    int? milestonesCompleted,
    int? skillsAcquired,
    int? currentStreak,
    int? longestStreak,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (learningHours != null) updates['learning_hours'] = learningHours;
      if (milestonesCompleted != null) updates['milestones_completed'] = milestonesCompleted;
      if (skillsAcquired != null) updates['skills_acquired'] = skillsAcquired;
      if (currentStreak != null) updates['current_streak'] = currentStreak;
      if (longestStreak != null) updates['longest_streak'] = longestStreak;
      updates['last_activity_date'] = DateTime.now().toIso8601String();
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('user_analytics')
          .update(updates)
          .eq('user_id', userId);
    } catch (e) {
      appLogger.e('Update analytics error: $e');
      throw ServerException(
        message: 'Failed to update analytics',
        originalException: e,
      );
    }
  }

  Future<AnalyticsModel> initializeAnalytics(String userId) async {
    try {
      final analytics = AnalyticsModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        learningHours: 0,
        milestonesCompleted: 0,
        skillsAcquired: 0,
        currentStreak: 0,
        longestStreak: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _client
          .from('user_analytics')
          .insert(analytics.toJson());

      return analytics;
    } catch (e) {
      appLogger.e('Initialize analytics error: $e');
      throw ServerException(
        message: 'Failed to initialize analytics',
        originalException: e,
      );
    }
  }

  Future<int> getTotalLearningTime(String userId) async {
    try {
      final result = await _client.rpc(
        'get_total_learning_time',
        params: {'user_id': userId},
      );
      return result as int? ?? 0;
    } catch (e) {
      appLogger.e('Get total learning time error: $e');
      return 0;
    }
  }

  Future<int> getCurrentStreak(String userId) async {
    try {
      final result = await _client.rpc(
        'get_current_streak',
        params: {'user_id': userId},
      );
      return result as int? ?? 0;
    } catch (e) {
      appLogger.e('Get streak error: $e');
      return 0;
    }
  }
}

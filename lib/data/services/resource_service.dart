import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/learning_resource_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class ResourceService {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<LearningResourceModel>> getAllResources({
    String? resourceType,
    String? difficulty,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var query = _client.from('learning_resources').select();
      if (resourceType != null) query = query.eq('resource_type', resourceType);
      if (difficulty != null) query = query.eq('difficulty', difficulty);

      final data = await query
          .order('rating', ascending: false)
          .range(offset, offset + limit - 1);

      return List<LearningResourceModel>.from(
        (data as List).map((x) => LearningResourceModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Get all resources error: $e');
      throw ServerException(
        message: 'Failed to fetch resources',
        originalException: e,
      );
    }
  }

  Future<List<LearningResourceModel>> searchResources(String query, {int limit = 20}) async {
    try {
      final data = await _client
          .from('learning_resources')
          .select()
          .ilike('title', '%$query%')
          .limit(limit);

      return List<LearningResourceModel>.from(
        (data as List).map((x) => LearningResourceModel.fromJson(x)),
      );
    } catch (e) {
      appLogger.e('Search resources error: $e');
      throw ServerException(
        message: 'Failed to search resources',
        originalException: e,
      );
    }
  }

  Future<void> bookmarkResource(String userId, String resourceId) async {
    try {
      await _client.from('user_bookmarks').insert({
        'user_id': userId,
        'resource_id': resourceId,
        'bookmarked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      appLogger.e('Bookmark resource error: $e');
      throw ServerException(
        message: 'Failed to bookmark resource',
        originalException: e,
      );
    }
  }

  Future<void> unbookmarkResource(String userId, String resourceId) async {
    try {
      await _client
          .from('user_bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('resource_id', resourceId);
    } catch (e) {
      appLogger.e('Unbookmark resource error: $e');
      throw ServerException(
        message: 'Failed to unbookmark resource',
        originalException: e,
      );
    }
  }

  Future<List<UserResourceModel>> getUserBookmarks(String userId) async {
    try {
      final data = await _client
          .from('user_bookmarks')
          .select('''
            id,
            user_id,
            resource_id,
            bookmarked_at,
            learning_resources(id, title, description, resource_type, url, provider, difficulty, estimated_hours, rating, reviews_count, thumbnail_url, created_at)
          ''')
          .eq('user_id', userId)
          .order('bookmarked_at', ascending: false);

      return List<UserResourceModel>.from(
        (data as List).map((x) {
          final json = x as Map<String, dynamic>;
          return UserResourceModel(
            id: json['id'] as String,
            userId: json['user_id'] as String,
            resourceId: json['resource_id'] as String,
            isBookmarked: true,
            createdAt: DateTime.parse(json['bookmarked_at'] as String),
            resource: LearningResourceModel.fromJson(
              json['learning_resources'] as Map<String, dynamic>,
            ),
          );
        }),
      );
    } catch (e) {
      appLogger.e('Get bookmarks error: $e');
      throw ServerException(
        message: 'Failed to fetch bookmarks',
        originalException: e,
      );
    }
  }

  Future<void> completeResource(String userId, String resourceId, {String? notes}) async {
    try {
      await _client.from('resource_completions').insert({
        'user_id': userId,
        'resource_id': resourceId,
        'completed_at': DateTime.now().toIso8601String(),
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      appLogger.e('Complete resource error: $e');
      throw ServerException(
        message: 'Failed to mark resource as complete',
        originalException: e,
      );
    }
  }

  Future<List<UserResourceModel>> getUserCompletions(String userId) async {
    try {
      final data = await _client
          .from('resource_completions')
          .select('''
            id,
            user_id,
            resource_id,
            completed_at,
            notes,
            created_at,
            learning_resources(id, title, description, resource_type, url, provider, difficulty, estimated_hours, rating, reviews_count, thumbnail_url, created_at)
          ''')
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return List<UserResourceModel>.from(
        (data as List).map((x) {
          final json = x as Map<String, dynamic>;
          return UserResourceModel(
            id: json['id'] as String,
            userId: json['user_id'] as String,
            resourceId: json['resource_id'] as String,
            isBookmarked: false,
            completedAt: DateTime.parse(json['completed_at'] as String),
            notes: json['notes'] as String?,
            createdAt: DateTime.parse(json['created_at'] as String),
            resource: LearningResourceModel.fromJson(
              json['learning_resources'] as Map<String, dynamic>,
            ),
          );
        }),
      );
    } catch (e) {
      appLogger.e('Get completions error: $e');
      throw ServerException(
        message: 'Failed to fetch completed resources',
        originalException: e,
      );
    }
  }
}

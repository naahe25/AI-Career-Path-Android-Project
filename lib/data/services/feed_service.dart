import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/post_model.dart';
import '../models/profile_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';
import 'supabase_service.dart';

class FeedService {
  final _client = SupabaseService.client;

  /// Uploads an image to the `post-images` bucket and returns its public URL.
  Future<String> uploadPostImage(
    String userId,
    Uint8List bytes, {
    String extension = 'jpg',
  }) async {
    try {
      final path = '$userId/${const Uuid().v4()}.$extension';
      await _client.storage.from('post-images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$extension',
              upsert: true,
            ),
          );
      return _client.storage.from('post-images').getPublicUrl(path);
    } catch (e) {
      appLogger.e('Upload post image error: $e');
      throw ServerException(
          message: 'Failed to upload image', originalException: e);
    }
  }

  Future<List<PostModel>> getFeed(String? userId) async {
    try {
      final data = await _client
          .from('posts')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      // Which of these posts has the current user liked?
      Set<String> likedIds = {};
      if (userId != null) {
        final likes = await _client
            .from('post_likes')
            .select('post_id')
            .eq('user_id', userId);
        likedIds = (likes as List).map((x) => x['post_id'] as String).toSet();
      }

      return (data as List)
          .map((x) => PostModel.fromJson(
                x,
                likedByMe: likedIds.contains(x['id']),
              ))
          .toList();
    } catch (e) {
      appLogger.e('Get feed error: $e');
      throw ServerException(message: 'Failed to load feed', originalException: e);
    }
  }

  Future<PostModel> createPost({
    required String userId,
    required ProfileModel? profile,
    required String content,
    String? imageUrl,
  }) async {
    try {
      final row = {
        'author_id': userId,
        'author_name': profile?.fullName ?? 'Member',
        'author_title': profile?.currentRole ?? profile?.desiredField,
        'author_avatar_url': profile?.avatarUrl,
        'content': content,
        'image_url': imageUrl,
      };
      final data =
          await _client.from('posts').insert(row).select().single();
      return PostModel.fromJson(data);
    } catch (e) {
      appLogger.e('Create post error: $e');
      throw ServerException(message: 'Failed to publish post', originalException: e);
    }
  }

  Future<void> toggleLike(String postId, String userId, bool like) async {
    try {
      if (like) {
        await _client.from('post_likes').upsert({
          'post_id': postId,
          'user_id': userId,
        }, onConflict: 'post_id,user_id');
      } else {
        await _client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
      }
    } catch (e) {
      appLogger.e('Toggle like error: $e');
      rethrow;
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final data = await _client
          .from('post_comments')
          .select()
          .eq('post_id', postId)
          .order('created_at', ascending: true);
      return (data as List).map((x) => CommentModel.fromJson(x)).toList();
    } catch (e) {
      appLogger.e('Get comments error: $e');
      throw ServerException(message: 'Failed to load comments', originalException: e);
    }
  }

  Future<CommentModel> addComment({
    required String postId,
    required String userId,
    required ProfileModel? profile,
    required String content,
  }) async {
    try {
      final row = {
        'post_id': postId,
        'user_id': userId,
        'author_name': profile?.fullName ?? 'Member',
        'author_avatar_url': profile?.avatarUrl,
        'content': content,
      };
      final data =
          await _client.from('post_comments').insert(row).select().single();
      return CommentModel.fromJson(data);
    } catch (e) {
      appLogger.e('Add comment error: $e');
      throw ServerException(message: 'Failed to add comment', originalException: e);
    }
  }

  // --- Network -----------------------------------------------------------
  Future<List<ConnectionPerson>> getSuggestedPeople(String userId) async {
    try {
      final people = <ConnectionPerson>[];

      // 1) Seeded "people" directory (LinkedIn-style suggestions everyone sees).
      try {
        final directory =
            await _client.from('people').select('id, name, title, company, avatar_url');
        final userConnections = await _client
            .from('user_connections')
            .select('person_id, status')
            .eq('user_id', userId);
        final statusByPerson = <String, String>{};
        for (final c in (userConnections as List)) {
          statusByPerson[c['person_id'] as String] =
              c['status'] == 'connected' ? 'connected' : 'pending';
        }
        for (final p in (directory as List)) {
          final name = (p['name'] as String?)?.trim();
          people.add(ConnectionPerson(
            id: p['id'] as String,
            name: (name == null || name.isEmpty) ? 'Member' : name,
            title: p['title'] as String?,
            company: p['company'] as String?,
            avatarUrl: p['avatar_url'] as String?,
            status: statusByPerson[p['id']] ?? 'none',
            source: 'directory',
          ));
        }
      } catch (e) {
        // The people directory is optional; ignore if the table isn't present.
        appLogger.e('Get people directory error: $e');
      }

      // 2) Other real members (actual app users).
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, avatar_url, user_current_role, desired_field')
          .neq('id', userId)
          .limit(30);

      final connections = await _client
          .from('connections')
          .select('requester_id, addressee_id, status')
          .or('requester_id.eq.$userId,addressee_id.eq.$userId');

      final statusByPerson = <String, String>{};
      for (final c in (connections as List)) {
        final other = c['requester_id'] == userId
            ? c['addressee_id'] as String
            : c['requester_id'] as String;
        statusByPerson[other] =
            c['status'] == 'accepted' ? 'connected' : 'pending';
      }

      for (final p in (profiles as List)) {
        final name = (p['full_name'] as String?)?.trim();
        people.add(ConnectionPerson(
          id: p['id'] as String,
          name: (name == null || name.isEmpty) ? 'Member' : name,
          title: (p['user_current_role'] as String?) ??
              (p['desired_field'] as String?),
          avatarUrl: p['avatar_url'] as String?,
          status: statusByPerson[p['id']] ?? 'none',
          source: 'profile',
        ));
      }

      return people;
    } catch (e) {
      appLogger.e('Get suggested people error: $e');
      throw ServerException(
          message: 'Failed to load people', originalException: e);
    }
  }

  Future<void> connect(String userId, ConnectionPerson person) async {
    try {
      if (person.source == 'directory') {
        await _client.from('user_connections').upsert({
          'user_id': userId,
          'person_id': person.id,
          'status': 'connected',
        }, onConflict: 'user_id,person_id');
      } else {
        await _client.from('connections').upsert({
          'requester_id': userId,
          'addressee_id': person.id,
          'status': 'pending',
        }, onConflict: 'requester_id,addressee_id');
      }
    } catch (e) {
      appLogger.e('Connect error: $e');
      rethrow;
    }
  }
}

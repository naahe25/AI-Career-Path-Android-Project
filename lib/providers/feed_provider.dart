import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post_model.dart';
import '../data/services/feed_service.dart';
import 'auth_provider.dart';

final feedServiceProvider = Provider<FeedService>((ref) => FeedService());

class FeedNotifier extends StateNotifier<AsyncValue<List<PostModel>>> {
  final FeedService _service;
  final Ref _ref;
  final String? _userId;

  FeedNotifier(this._service, this._ref, this._userId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      state = const AsyncValue.loading();
      final posts = await _service.getFeed(_userId);
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike(String postId) async {
    if (_userId == null) return;
    final posts = state.value;
    if (posts == null) return;

    final updated = posts.map((p) {
      if (p.id != postId) return p;
      final nowLiked = !p.likedByMe;
      return p.copyWith(
        likedByMe: nowLiked,
        likesCount: p.likesCount + (nowLiked ? 1 : -1),
      );
    }).toList();
    state = AsyncValue.data(updated);

    final target = posts.firstWhere((p) => p.id == postId);
    try {
      await _service.toggleLike(postId, _userId, !target.likedByMe);
    } catch (_) {
      state = AsyncValue.data(posts); // revert
    }
  }

  Future<void> createPost(String content, {String? imageUrl}) async {
    if (_userId == null) return;
    final profile = _ref.read(profileProvider).value;
    final post = await _service.createPost(
      userId: _userId,
      profile: profile,
      content: content,
      imageUrl: imageUrl,
    );
    final current = state.value ?? [];
    state = AsyncValue.data([post, ...current]);
  }
}

final feedProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<PostModel>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(feedServiceProvider);
  return FeedNotifier(service, ref, user?.id);
});

final commentsProvider =
    FutureProvider.family.autoDispose<List<CommentModel>, String>(
        (ref, postId) async {
  final service = ref.watch(feedServiceProvider);
  return service.getComments(postId);
});

class SuggestedPeopleNotifier
    extends StateNotifier<AsyncValue<List<ConnectionPerson>>> {
  final FeedService _service;
  final String? _userId;

  SuggestedPeopleNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    try {
      state = const AsyncValue.loading();
      state = AsyncValue.data(await _service.getSuggestedPeople(_userId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> connect(ConnectionPerson person) async {
    if (_userId == null) return;
    final people = state.value;
    if (people == null) return;
    final connectedStatus = person.source == 'directory' ? 'connected' : 'pending';
    state = AsyncValue.data(
      people
          .map((p) => p.id == person.id ? p.copyWith(status: connectedStatus) : p)
          .toList(),
    );
    try {
      await _service.connect(_userId, person);
    } catch (_) {
      state = AsyncValue.data(people);
    }
  }
}

final suggestedPeopleProvider = StateNotifierProvider<SuggestedPeopleNotifier,
    AsyncValue<List<ConnectionPerson>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(feedServiceProvider);
  return SuggestedPeopleNotifier(service, user?.id);
});

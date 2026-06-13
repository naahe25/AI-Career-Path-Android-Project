import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/learning_resource_model.dart';
import '../data/services/resource_service.dart';
import '../providers/auth_provider.dart';

final resourceServiceProvider = Provider<ResourceService>((ref) => ResourceService());

final allResourcesProvider = FutureProvider<List<LearningResourceModel>>((ref) async {
  final service = ref.watch(resourceServiceProvider);
  return service.getAllResources();
});

final resourcesByTypeProvider = FutureProvider.family<List<LearningResourceModel>, String>((ref, type) async {
  final service = ref.watch(resourceServiceProvider);
  return service.getAllResources(resourceType: type);
});

final resourceSearchProvider = FutureProvider.family<List<LearningResourceModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(resourceServiceProvider);
  return service.searchResources(query);
});

final userBookmarksProvider = FutureProvider<List<UserResourceModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final service = ref.watch(resourceServiceProvider);
  return service.getUserBookmarks(user.id);
});

final userCompletionsProvider = FutureProvider<List<UserResourceModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final service = ref.watch(resourceServiceProvider);
  return service.getUserCompletions(user.id);
});

class ResourceNotifier extends StateNotifier<AsyncValue<List<UserResourceModel>>> {
  final ResourceService _service;
  final String? _userId;

  ResourceNotifier(this._service, this._userId) : super(const AsyncValue.data([]));

  Future<void> bookmarkResource(String resourceId) async {
    if (_userId == null) return;
    try {
      await _service.bookmarkResource(_userId, resourceId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> unbookmarkResource(String resourceId) async {
    if (_userId == null) return;
    try {
      await _service.unbookmarkResource(_userId, resourceId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeResource(String resourceId, {String? notes}) async {
    if (_userId == null) return;
    try {
      await _service.completeResource(_userId, resourceId, notes: notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final resourceNotifierProvider = StateNotifierProvider<ResourceNotifier, AsyncValue<List<UserResourceModel>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(resourceServiceProvider);
  return ResourceNotifier(service, user?.id);
});

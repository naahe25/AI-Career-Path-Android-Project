import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/achievement_model.dart';
import '../data/services/achievement_service.dart';
import '../providers/auth_provider.dart';

final achievementServiceProvider = Provider<AchievementService>((ref) => AchievementService());

final allAchievementsProvider = FutureProvider<List<AchievementModel>>((ref) async {
  final service = ref.watch(achievementServiceProvider);
  return service.getAllAchievements();
});

class AchievementNotifier extends StateNotifier<AsyncValue<List<UserAchievementModel>>> {
  final AchievementService _service;
  final String? _userId;

  AchievementNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final achievements = await _service.getUserAchievements(_userId);
      state = AsyncValue.data(achievements);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> earnAchievement(String achievementId) async {
    if (_userId == null) return;
    try {
      await _service.earnAchievement(_userId, achievementId);
      await _loadAchievements();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> hasAchievement(String achievementId) async {
    if (_userId == null) return false;
    return _service.hasAchievement(_userId, achievementId);
  }
}

final achievementNotifierProvider = StateNotifierProvider<AchievementNotifier, AsyncValue<List<UserAchievementModel>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(achievementServiceProvider);
  return AchievementNotifier(service, user?.id);
});

final badgeCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final service = ref.watch(achievementServiceProvider);
  return service.getAchievementCount(user.id);
});

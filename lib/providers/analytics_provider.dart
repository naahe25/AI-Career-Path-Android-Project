import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/analytics_model.dart';
import '../data/services/analytics_service.dart';
import '../providers/auth_provider.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) => AnalyticsService());

final userAnalyticsProvider = FutureProvider<AnalyticsModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final analyticsService = ref.watch(analyticsServiceProvider);
  final analytics = await analyticsService.getUserAnalytics(user.id);
  return analytics ?? await analyticsService.initializeAnalytics(user.id);
});

final dailyProgressProvider = FutureProvider<List<DailyProgressModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final analyticsService = ref.watch(analyticsServiceProvider);
  return analyticsService.getDailyProgress(user.id);
});

class AnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsModel?>> {
  final AnalyticsService _analyticsService;
  final String? _userId;

  AnalyticsNotifier(this._analyticsService, this._userId)
      : super(const AsyncValue.loading()) {
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    if (_userId == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final analytics = await _analyticsService.getUserAnalytics(_userId);
      state = AsyncValue.data(analytics ?? await _analyticsService.initializeAnalytics(_userId));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAnalytics({
    int? learningHours,
    int? milestonesCompleted,
    int? skillsAcquired,
    int? currentStreak,
    int? longestStreak,
  }) async {
    if (_userId == null) return;
    try {
      await _analyticsService.updateAnalytics(
        _userId,
        learningHours: learningHours,
        milestonesCompleted: milestonesCompleted,
        skillsAcquired: skillsAcquired,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
      await _loadAnalytics();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordDailyProgress(DailyProgressModel progress) async {
    if (_userId == null) return;
    try {
      await _analyticsService.recordDailyProgress(_userId, progress);
      await _loadAnalytics();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final analyticsNotifierProvider = StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsModel?>>((ref) {
  final user = ref.watch(currentUserProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  return AnalyticsNotifier(analyticsService, user?.id);
});

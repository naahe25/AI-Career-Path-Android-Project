import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/career_path_model.dart';
import '../data/models/profile_model.dart';
import '../data/services/career_service.dart';
import '../data/services/ai_service.dart';
import '../core/utils/logger.dart';
import 'auth_provider.dart';

final careerServiceProvider = Provider<CareerService>((ref) => CareerService());

final aiServiceProvider = Provider<AiService>((ref) => AiService());

// Career paths list
class CareerPathsNotifier
    extends StateNotifier<AsyncValue<List<CareerPathModel>>> {
  final CareerService _careerService;
  final String? _userId;

  CareerPathsNotifier(this._careerService, this._userId)
    : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadCareerPaths();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadCareerPaths() async {
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      final paths = await _careerService.getUserCareerPaths(_userId);
      state = AsyncValue.data(paths);
    } catch (e, st) {
      appLogger.e('Load career paths error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCareerPath(CareerPathModel path) async {
    final current = state.value ?? [];
    state = AsyncValue.data([path, ...current]);
  }

  /// Removes a path so the user can later re-add it (paths are de-duplicated by
  /// title in the dashboard). Optimistically drops it, reverting on failure.
  Future<void> removeCareerPath(String pathId) async {
    final current = state.value ?? [];
    final previous = current;
    state = AsyncValue.data(
      current.where((p) => p.id != pathId).toList(),
    );
    try {
      await _careerService.deleteCareerPath(pathId);
    } catch (e) {
      appLogger.e('Remove career path error: $e');
      state = AsyncValue.data(previous);
      rethrow;
    }
  }

  Future<void> toggleMilestone(
    String pathId,
    String milestoneId,
    bool isCompleted,
  ) async {
    try {
      final updated = await _careerService.toggleMilestoneComplete(
        milestoneId,
        isCompleted,
      );

      final current = state.value ?? [];
      final newPaths = current.map((path) {
        if (path.id != pathId) return path;
        final newMilestones = path.milestones.map((m) {
          if (m.id != milestoneId) return m;
          return updated;
        }).toList();
        return CareerPathModel(
          id: path.id,
          userId: path.userId,
          title: path.title,
          description: path.description,
          targetRole: path.targetRole,
          estimatedDurationMonths: path.estimatedDurationMonths,
          difficultyLevel: path.difficultyLevel,
          isActive: path.isActive,
          milestones: newMilestones,
          createdAt: path.createdAt,
          updatedAt: DateTime.now(),
        );
      }).toList();

      state = AsyncValue.data(newPaths);
    } catch (e) {
      appLogger.e('Toggle milestone error: $e');
      rethrow;
    }
  }
}

final careerPathsProvider =
    StateNotifierProvider<
      CareerPathsNotifier,
      AsyncValue<List<CareerPathModel>>
    >((ref) {
      final user = ref.watch(currentUserProvider);
      final careerService = ref.watch(careerServiceProvider);
      return CareerPathsNotifier(careerService, user?.id);
    });

// AI generation state
class AiGenerationNotifier
    extends StateNotifier<AsyncValue<List<GeneratedPath>?>> {
  final AiService _aiService;
  final CareerService _careerService;

  AiGenerationNotifier(this._aiService, this._careerService)
    : super(const AsyncValue.data(null));

  Future<void> generatePaths(ProfileModel profile) async {
    try {
      state = const AsyncValue.loading();
      final paths = await _aiService.generateCareerPaths(profile);
      state = AsyncValue.data(paths);
    } catch (e, st) {
      appLogger.e('AI generation error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<CareerPathModel?> savePath(String userId, GeneratedPath path) async {
    try {
      final saved = await _careerService.createCareerPath(
        userId: userId,
        title: path.title,
        description: path.description,
        targetRole: path.targetRole,
        estimatedDurationMonths: path.estimatedDurationMonths,
        difficultyLevel: path.difficultyLevel,
        milestones: path.milestones,
      );
      return saved;
    } catch (e) {
      appLogger.e('Save path error: $e');
      rethrow;
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final aiGenerationProvider =
    StateNotifierProvider<
      AiGenerationNotifier,
      AsyncValue<List<GeneratedPath>?>
    >((ref) {
      final aiService = ref.watch(aiServiceProvider);
      final careerService = ref.watch(careerServiceProvider);
      return AiGenerationNotifier(aiService, careerService);
    });

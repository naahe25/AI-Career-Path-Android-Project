import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/demo/demo_data.dart';
import '../data/models/career_path_model.dart';
import '../data/models/milestone_model.dart';
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
  final CareerService? _careerService;
  final String? _userId;

  CareerPathsNotifier(this._careerService, this._userId)
    : super(const AsyncValue.loading()) {
    if (AppConfig.demoMode) {
      state = AsyncValue.data(DemoData.careerPaths());
    } else if (_userId != null) {
      loadCareerPaths();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadCareerPaths() async {
    if (AppConfig.demoMode) {
      state = AsyncValue.data(DemoData.careerPaths());
      return;
    }
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      final paths = await _careerService!.getUserCareerPaths(_userId);
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

  Future<void> toggleMilestone(
    String pathId,
    String milestoneId,
    bool isCompleted,
  ) async {
    if (AppConfig.demoMode) {
      final current = state.value ?? [];
      final newPaths = current.map((path) {
        if (path.id != pathId) return path;
        final newMilestones = path.milestones.map((milestone) {
          if (milestone.id != milestoneId) return milestone;
          return _copyMilestoneCompletion(milestone, isCompleted);
        }).toList();
        return _copyPath(path, newMilestones);
      }).toList();
      state = AsyncValue.data(newPaths);
      return;
    }

    try {
      final updated = await _careerService!.toggleMilestoneComplete(
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

  CareerPathModel _copyPath(
    CareerPathModel path,
    List<MilestoneModel> milestones,
  ) {
    return CareerPathModel(
      id: path.id,
      userId: path.userId,
      title: path.title,
      description: path.description,
      targetRole: path.targetRole,
      estimatedDurationMonths: path.estimatedDurationMonths,
      difficultyLevel: path.difficultyLevel,
      isActive: path.isActive,
      milestones: milestones,
      createdAt: path.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  MilestoneModel _copyMilestoneCompletion(
    MilestoneModel milestone,
    bool isCompleted,
  ) {
    return MilestoneModel(
      id: milestone.id,
      careerPathId: milestone.careerPathId,
      title: milestone.title,
      description: milestone.description,
      orderIndex: milestone.orderIndex,
      isCompleted: isCompleted,
      resources: milestone.resources,
      skillsGained: milestone.skillsGained,
      estimatedWeeks: milestone.estimatedWeeks,
      completedAt: isCompleted ? DateTime.now() : null,
      createdAt: milestone.createdAt,
    );
  }
}

final careerPathsProvider =
    StateNotifierProvider<
      CareerPathsNotifier,
      AsyncValue<List<CareerPathModel>>
    >((ref) {
      if (AppConfig.demoMode) {
        return CareerPathsNotifier(null, AppConfig.demoUserId);
      }
      final user = ref.watch(currentUserProvider);
      final careerService = ref.watch(careerServiceProvider);
      return CareerPathsNotifier(careerService, user?.id);
    });

// AI generation state
class AiGenerationNotifier
    extends StateNotifier<AsyncValue<List<GeneratedPath>?>> {
  final AiService _aiService;
  final CareerService? _careerService;

  AiGenerationNotifier(this._aiService, this._careerService)
    : super(const AsyncValue.data(null));

  Future<void> generatePaths(ProfileModel profile) async {
    try {
      state = const AsyncValue.loading();
      if (AppConfig.demoMode) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        state = AsyncValue.data(DemoData.generatedPaths());
        return;
      }
      final paths = await _aiService.generateCareerPaths(profile);
      state = AsyncValue.data(paths);
    } catch (e, st) {
      appLogger.e('AI generation error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<CareerPathModel?> savePath(String userId, GeneratedPath path) async {
    try {
      if (AppConfig.demoMode) {
        return DemoData.careerPathFromGenerated(userId, path);
      }
      final saved = await _careerService!.createCareerPath(
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
      final careerService = AppConfig.demoMode
          ? null
          : ref.watch(careerServiceProvider);
      return AiGenerationNotifier(aiService, careerService);
    });

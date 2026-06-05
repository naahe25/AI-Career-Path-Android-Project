import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_config.dart';
import '../data/demo/demo_data.dart';
import '../data/models/skill_model.dart';
import '../data/services/skill_service.dart';
import '../providers/auth_provider.dart';

final skillServiceProvider = Provider<SkillService>((ref) => SkillService());

final allSkillsProvider = FutureProvider<List<SkillModel>>((ref) async {
  if (AppConfig.demoMode) return DemoData.allSkills();

  final service = ref.watch(skillServiceProvider);
  return service.getAllSkills();
});

final skillsByDifficultyProvider = FutureProvider.family<List<SkillModel>, String>((ref, difficulty) async {
  if (AppConfig.demoMode) {
    return DemoData.allSkills()
        .where((skill) => skill.difficulty == difficulty)
        .toList();
  }

  final service = ref.watch(skillServiceProvider);
  return service.getAllSkills(difficulty: difficulty);
});

class SkillNotifier extends StateNotifier<AsyncValue<List<UserSkillModel>>> {
  final SkillService? _service;
  final String? _userId;

  SkillNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    if (AppConfig.demoMode) {
      state = AsyncValue.data(DemoData.userSkills());
      return;
    }

    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final skills = await _service!.getUserSkills(_userId!);
      state = AsyncValue.data(skills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startSkill(String skillId) async {
    if (AppConfig.demoMode) {
      final current = state.value ?? DemoData.userSkills();
      if (current.any((skill) => skill.skillId == skillId)) return;
      final skill = DemoData.allSkills().firstWhere((item) => item.id == skillId);
      state = AsyncValue.data([
        UserSkillModel(
          id: 'demo-user-skill-$skillId',
          userId: AppConfig.demoUserId,
          skillId: skillId,
          proficiencyLevel: 5,
          hoursInvested: 1,
          startedAt: DateTime.now(),
          createdAt: DateTime.now(),
          skill: skill,
        ),
        ...current,
      ]);
      return;
    }

    if (_userId == null) return;
    try {
      await _service!.startSkill(_userId!, skillId);
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(String userSkillId, {int? level, int? hours}) async {
    if (AppConfig.demoMode) {
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((skill) {
          if (skill.id != userSkillId) return skill;
          return skill.copyWith(
            proficiencyLevel: level,
            hoursInvested: hours,
          );
        }).toList(),
      );
      return;
    }

    try {
      await _service!.updateSkillProgress(
        userSkillId,
        proficiencyLevel: level,
        hoursInvested: hours,
      );
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeSkill(String userSkillId) async {
    if (AppConfig.demoMode) {
      final current = state.value ?? [];
      state = AsyncValue.data(
        current.map((skill) {
          if (skill.id != userSkillId) return skill;
          return skill.copyWith(
            proficiencyLevel: 100,
            completedAt: DateTime.now(),
          );
        }).toList(),
      );
      return;
    }

    try {
      await _service!.completeSkill(userSkillId);
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final skillNotifierProvider = StateNotifierProvider<SkillNotifier, AsyncValue<List<UserSkillModel>>>((ref) {
  if (AppConfig.demoMode) {
    return SkillNotifier(null, AppConfig.demoUserId);
  }
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(skillServiceProvider);
  return SkillNotifier(service, user?.id);
});

final userSkillCountProvider = FutureProvider<int>((ref) async {
  if (AppConfig.demoMode) return DemoData.userSkills().length;

  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final service = ref.watch(skillServiceProvider);
  return service.getUserSkillCount(user.id);
});

final completedSkillCountProvider = FutureProvider<int>((ref) async {
  if (AppConfig.demoMode) {
    return DemoData.userSkills().where((skill) => skill.isCompleted).length;
  }

  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final service = ref.watch(skillServiceProvider);
  return service.getCompletedSkillCount(user.id);
});

final skillSearchProvider = FutureProvider.family<List<SkillModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  if (AppConfig.demoMode) {
    final normalized = query.toLowerCase();
    return DemoData.allSkills()
        .where((skill) => skill.name.toLowerCase().contains(normalized))
        .toList();
  }

  final service = ref.watch(skillServiceProvider);
  return service.searchSkills(query);
});

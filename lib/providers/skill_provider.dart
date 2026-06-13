import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/skill_model.dart';
import '../data/services/skill_service.dart';
import '../providers/auth_provider.dart';

final skillServiceProvider = Provider<SkillService>((ref) => SkillService());

final allSkillsProvider = FutureProvider<List<SkillModel>>((ref) async {
  final service = ref.watch(skillServiceProvider);
  return service.getAllSkills();
});

final skillsByDifficultyProvider = FutureProvider.family<List<SkillModel>, String>((ref, difficulty) async {
  final service = ref.watch(skillServiceProvider);
  return service.getAllSkills(difficulty: difficulty);
});

class SkillNotifier extends StateNotifier<AsyncValue<List<UserSkillModel>>> {
  final SkillService _service;
  final String? _userId;

  SkillNotifier(this._service, this._userId) : super(const AsyncValue.loading()) {
    _loadSkills();
  }

  Future<void> _loadSkills() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      state = const AsyncValue.loading();
      final skills = await _service.getUserSkills(_userId);
      state = AsyncValue.data(skills);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> startSkill(String skillId) async {
    if (_userId == null) return;
    try {
      await _service.startSkill(_userId, skillId);
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(String userSkillId, {int? level, int? hours}) async {
    try {
      await _service.updateSkillProgress(userSkillId, proficiencyLevel: level, hoursInvested: hours);
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> completeSkill(String userSkillId) async {
    try {
      await _service.completeSkill(userSkillId);
      await _loadSkills();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final skillNotifierProvider = StateNotifierProvider<SkillNotifier, AsyncValue<List<UserSkillModel>>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(skillServiceProvider);
  return SkillNotifier(service, user?.id);
});

final userSkillCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final service = ref.watch(skillServiceProvider);
  return service.getUserSkillCount(user.id);
});

final completedSkillCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;

  final service = ref.watch(skillServiceProvider);
  return service.getCompletedSkillCount(user.id);
});

final skillSearchProvider = FutureProvider.family<List<SkillModel>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final service = ref.watch(skillServiceProvider);
  return service.searchSkills(query);
});

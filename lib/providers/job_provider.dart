import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/job_model.dart';
import '../data/services/job_service.dart';
import 'auth_provider.dart';

final jobServiceProvider = Provider<JobService>((ref) => JobService());

/// Active filter set for the jobs list.
class JobFilters {
  final String search;
  final String? employmentType;
  final String? experienceLevel;
  final bool remoteOnly;

  const JobFilters({
    this.search = '',
    this.employmentType,
    this.experienceLevel,
    this.remoteOnly = false,
  });

  JobFilters copyWith({
    String? search,
    Object? employmentType = _sentinel,
    Object? experienceLevel = _sentinel,
    bool? remoteOnly,
  }) {
    return JobFilters(
      search: search ?? this.search,
      employmentType: employmentType == _sentinel
          ? this.employmentType
          : employmentType as String?,
      experienceLevel: experienceLevel == _sentinel
          ? this.experienceLevel
          : experienceLevel as String?,
      remoteOnly: remoteOnly ?? this.remoteOnly,
    );
  }

  static const _sentinel = Object();
}

final jobFiltersProvider =
    StateProvider<JobFilters>((ref) => const JobFilters());

final jobsProvider = FutureProvider.autoDispose<List<JobModel>>((ref) async {
  final filters = ref.watch(jobFiltersProvider);
  final service = ref.watch(jobServiceProvider);
  return service.getJobs(
    search: filters.search,
    employmentType: filters.employmentType,
    experienceLevel: filters.experienceLevel,
    remoteOnly: filters.remoteOnly,
  );
});

final jobByIdProvider =
    FutureProvider.family.autoDispose<JobModel?, String>((ref, id) async {
  final service = ref.watch(jobServiceProvider);
  return service.getJobById(id);
});

/// Saved-job ids with optimistic toggling.
class SavedJobsNotifier extends StateNotifier<Set<String>> {
  final JobService _service;
  final String? _userId;

  SavedJobsNotifier(this._service, this._userId) : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    state = await _service.getSavedJobIds(_userId);
  }

  bool isSaved(String jobId) => state.contains(jobId);

  Future<void> toggle(String jobId) async {
    if (_userId == null) return;
    final willSave = !state.contains(jobId);
    // Optimistic update.
    final next = {...state};
    willSave ? next.add(jobId) : next.remove(jobId);
    state = next;
    try {
      await _service.toggleSaveJob(_userId, jobId, willSave);
    } catch (_) {
      // Revert on failure.
      final reverted = {...state};
      willSave ? reverted.remove(jobId) : reverted.add(jobId);
      state = reverted;
    }
  }
}

final savedJobIdsProvider =
    StateNotifierProvider<SavedJobsNotifier, Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(jobServiceProvider);
  return SavedJobsNotifier(service, user?.id);
});

final savedJobsListProvider =
    FutureProvider.autoDispose<List<JobModel>>((ref) async {
  // Re-run whenever the saved set changes.
  ref.watch(savedJobIdsProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(jobServiceProvider);
  return service.getSavedJobs(user.id);
});

/// Applied-job ids (used to show an "Applied" state on cards).
class AppliedJobsNotifier extends StateNotifier<Set<String>> {
  final JobService _service;
  final String? _userId;

  AppliedJobsNotifier(this._service, this._userId) : super(<String>{}) {
    _load();
  }

  Future<void> _load() async {
    if (_userId == null) return;
    state = await _service.getAppliedJobIds(_userId);
  }

  bool hasApplied(String jobId) => state.contains(jobId);

  Future<void> apply(String jobId, {String? coverNote}) async {
    if (_userId == null) return;
    await _service.applyToJob(_userId, jobId, coverNote: coverNote);
    state = {...state, jobId};
  }
}

final appliedJobIdsProvider =
    StateNotifierProvider<AppliedJobsNotifier, Set<String>>((ref) {
  final user = ref.watch(currentUserProvider);
  final service = ref.watch(jobServiceProvider);
  return AppliedJobsNotifier(service, user?.id);
});

final applicationsListProvider =
    FutureProvider.autoDispose<List<JobApplicationModel>>((ref) async {
  ref.watch(appliedJobIdsProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final service = ref.watch(jobServiceProvider);
  return service.getApplications(user.id);
});

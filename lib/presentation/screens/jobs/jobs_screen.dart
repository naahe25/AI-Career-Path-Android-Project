import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/jobs/job_card.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final filters = ref.watch(jobFiltersProvider);
    final savedIds = ref.watch(savedJobIdsProvider);
    final appliedIds = ref.watch(appliedJobIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.paddingL,
                AppDimensions.paddingL,
                AppDimensions.paddingL,
                AppDimensions.paddingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find your next role',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Curated opportunities for you',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _RoundIconButton(
                        icon: Icons.add,
                        onTap: () => context.push('/post-job'),
                      ),
                      const SizedBox(width: 10),
                      _RoundIconButton(
                        icon: Icons.bookmark_border,
                        onTap: () => context.push('/saved-jobs'),
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  ref.read(jobFiltersProvider.notifier).update(
                        (s) => s.copyWith(search: v),
                      );
                },
                decoration: InputDecoration(
                  hintText: 'Search jobs, companies, skills...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                  suffixIcon: filters.search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(jobFiltersProvider.notifier).update(
                                  (s) => s.copyWith(search: ''),
                                );
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Filter chips
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                ),
                children: [
                  _FilterChip(
                    label: 'Remote',
                    selected: filters.remoteOnly,
                    onTap: () => ref.read(jobFiltersProvider.notifier).update(
                          (s) => s.copyWith(remoteOnly: !s.remoteOnly),
                        ),
                  ),
                  _FilterChip(
                    label: 'Full-time',
                    selected: filters.employmentType == 'full_time',
                    onTap: () => ref.read(jobFiltersProvider.notifier).update(
                          (s) => s.copyWith(
                            employmentType:
                                s.employmentType == 'full_time' ? null : 'full_time',
                          ),
                        ),
                  ),
                  _FilterChip(
                    label: 'Internship',
                    selected: filters.employmentType == 'internship',
                    onTap: () => ref.read(jobFiltersProvider.notifier).update(
                          (s) => s.copyWith(
                            employmentType:
                                s.employmentType == 'internship' ? null : 'internship',
                          ),
                        ),
                  ),
                  _FilterChip(
                    label: 'Entry level',
                    selected: filters.experienceLevel == 'entry',
                    onTap: () => ref.read(jobFiltersProvider.notifier).update(
                          (s) => s.copyWith(
                            experienceLevel:
                                s.experienceLevel == 'entry' ? null : 'entry',
                          ),
                        ),
                  ),
                  _FilterChip(
                    label: 'Senior',
                    selected: filters.experienceLevel == 'senior',
                    onTap: () => ref.read(jobFiltersProvider.notifier).update(
                          (s) => s.copyWith(
                            experienceLevel:
                                s.experienceLevel == 'senior' ? null : 'senior',
                          ),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // List
            Expanded(
              child: jobsAsync.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const _JobsEmpty();
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(jobsProvider),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingL,
                        AppDimensions.paddingS,
                        AppDimensions.paddingL,
                        AppDimensions.paddingXL,
                      ),
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return JobCard(
                          job: job,
                          isSaved: savedIds.contains(job.id),
                          isApplied: appliedIds.contains(job.id),
                          onToggleSave: () => ref
                              .read(savedJobIdsProvider.notifier)
                              .toggle(job.id),
                          onTap: () => context.push('/job/${job.id}'),
                        )
                            .animate(delay: (index * 60).ms)
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.1, end: 0);
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => _JobsError(
                  onRetry: () => ref.invalidate(jobsProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(100),
            boxShadow: selected
                ? AppShadows.glow(AppColors.primary)
                : AppShadows.subtle,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadows.subtle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

class _JobsEmpty extends StatelessWidget {
  const _JobsEmpty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.work_off_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No jobs match your filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'Try clearing a filter or searching something else.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _JobsError extends StatelessWidget {
  final VoidCallback onRetry;
  const _JobsError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Could not load jobs. Make sure the jobs table is set up in Supabase.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

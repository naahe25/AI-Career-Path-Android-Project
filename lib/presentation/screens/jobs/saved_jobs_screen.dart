import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/jobs/job_card.dart';

class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedAsync = ref.watch(savedJobsListProvider);
    final savedIds = ref.watch(savedJobIdsProvider);
    final appliedIds = ref.watch(appliedJobIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Saved jobs')),
      body: savedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => const Center(child: Text('Failed to load saved jobs')),
        data: (jobs) {
          if (jobs.isEmpty) {
            return _EmptySaved();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                job: job,
                isSaved: savedIds.contains(job.id),
                isApplied: appliedIds.contains(job.id),
                onToggleSave: () =>
                    ref.read(savedJobIdsProvider.notifier).toggle(job.id),
                onTap: () => context.push('/job/${job.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptySaved extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bookmark_border,
              size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'No saved jobs yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap the bookmark on a job to save it here.',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

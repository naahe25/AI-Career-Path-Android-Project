import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/job_model.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/common/neo_card.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobByIdProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final saved = ref.watch(savedJobIdsProvider).contains(jobId);
              return IconButton(
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.primary : AppColors.textPrimary),
                onPressed: () =>
                    ref.read(savedJobIdsProvider.notifier).toggle(jobId),
              );
            },
          ),
        ],
      ),
      body: jobAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => const Center(child: Text('Failed to load job')),
        data: (job) {
          if (job == null) {
            return const Center(child: Text('Job not found'));
          }
          return _JobDetailBody(job: job);
        },
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  final JobModel job;
  const _JobDetailBody({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applied = ref.watch(appliedJobIdsProvider).contains(job.id);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.glow(AppColors.primary),
                          ),
                          child: Text(
                            job.company.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.company} · ${job.postedLabel}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TintChip(
                          icon: job.isRemote
                              ? Icons.public
                              : Icons.location_on_outlined,
                          label: job.location,
                          color: AppColors.info,
                        ),
                        TintChip(
                          icon: Icons.payments_outlined,
                          label: job.salaryRange,
                          color: AppColors.secondary,
                        ),
                        TintChip(
                          icon: Icons.work_outline,
                          label: job.employmentTypeLabel,
                          color: AppColors.primary,
                        ),
                        TintChip(
                          icon: Icons.trending_up,
                          label: job.experienceLabel,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 18),
              const _SectionTitle('About the role'),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              if (job.requirements.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle('What you\'ll need'),
                const SizedBox(height: 10),
                ...job.requirements.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 13, color: AppColors.success),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              if (job.tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _SectionTitle('Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.tags
                      .map((t) => TintChip(label: t, color: AppColors.primary))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Apply bar
        Container(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.paddingL,
            AppDimensions.paddingM,
            AppDimensions.paddingL,
            AppDimensions.paddingM + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundCard,
            boxShadow: AppShadows.soft,
          ),
          child: GradientButton(
            label: applied ? 'Application submitted' : 'Apply now',
            icon: applied ? Icons.check_circle : Icons.send_rounded,
            gradient:
                applied ? AppColors.successGradient : AppColors.primaryGradient,
            onTap: applied ? null : () => _confirmApply(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmApply(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(appliedJobIdsProvider.notifier).apply(job.id);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Applied to ${job.title} at ${job.company} 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not submit application. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

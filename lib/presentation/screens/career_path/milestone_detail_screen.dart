import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/milestone_model.dart';
import '../../../providers/career_provider.dart';

class MilestoneDetailScreen extends ConsumerWidget {
  final String milestoneId;
  final String careerPathId;

  const MilestoneDetailScreen({
    super.key,
    required this.milestoneId,
    required this.careerPathId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careerPathsAsync = ref.watch(careerPathsProvider);

    return careerPathsAsync.when(
      data: (paths) {
        MilestoneModel? milestone;
        for (final path in paths) {
          try {
            milestone = path.milestones.firstWhere((m) => m.id == milestoneId);
            break;
          } catch (_) {}
        }

        if (milestone == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(title: const Text('Milestone')),
            body: const Center(
              child: Text(
                'Milestone not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          );
        }

        return _MilestoneContent(
          milestone: milestone,
          careerPathId: careerPathId,
        );
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _MilestoneContent extends ConsumerWidget {
  final MilestoneModel milestone;
  final String careerPathId;

  const _MilestoneContent({
    required this.milestone,
    required this.careerPathId,
  });

  IconData _resourceIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle_outline;
      case 'course':
        return Icons.school_outlined;
      case 'book':
        return Icons.menu_book_outlined;
      case 'documentation':
        return Icons.description_outlined;
      case 'project':
        return Icons.code_outlined;
      default:
        return Icons.link_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(
          'Milestone ${milestone.orderIndex + 1}',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                ref
                    .read(careerPathsProvider.notifier)
                    .toggleMilestone(
                      careerPathId,
                      milestone.id,
                      !milestone.isCompleted,
                    );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: milestone.isCompleted
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: milestone.isCompleted
                        ? AppColors.success
                        : AppColors.primary,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      milestone.isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: milestone.isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                      size: 14,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      milestone.isCompleted ? 'Done' : 'Mark Done',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: milestone.isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              milestone.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.3,
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            if (milestone.estimatedWeeks != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Estimated: ${milestone.estimatedWeeks} weeks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(),
            ],

            if (milestone.description != null &&
                milestone.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                milestone.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.7,
                ),
              ).animate(delay: 150.ms).fadeIn(),
            ],

            if (milestone.skillsGained.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Skills You\'ll Gain',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: milestone.skillsGained.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt,
                          size: 12,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ).animate(delay: 200.ms).fadeIn(),
            ],

            if (milestone.resources.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Learning Resources',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...milestone.resources.asMap().entries.map((entry) {
                final index = entry.key;
                final resource = entry.value;
                return GestureDetector(
                      onTap: () async {
                        final uri = Uri.tryParse(resource.url);
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          await Clipboard.setData(
                            ClipboardData(text: resource.url),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL copied to clipboard'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundCard,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _resourceIcon(resource.type),
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resource.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    resource.type.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 250 + (index * 80)))
                    .fadeIn()
                    .slideX(begin: 0.1, end: 0);
              }),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

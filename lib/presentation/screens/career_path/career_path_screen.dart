import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/career_path_model.dart';
import '../../../providers/career_provider.dart';
import '../../widgets/career/milestone_tile.dart';

class CareerPathScreen extends ConsumerWidget {
  final String careerPathId;

  const CareerPathScreen({super.key, required this.careerPathId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careerPathsAsync = ref.watch(careerPathsProvider);

    return careerPathsAsync.when(
      data: (paths) {
        CareerPathModel? path;
        try {
          path = paths.firstWhere((p) => p.id == careerPathId);
        } catch (_) {
          path = null;
        }

        if (path == null) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            appBar: AppBar(title: const Text('Career Path')),
            body: const Center(
              child: Text(
                'Path not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
          );
        }

        return _CareerPathContent(path: path);
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

class _CareerPathContent extends ConsumerWidget {
  final CareerPathModel path;

  const _CareerPathContent({required this.path});

  Color get _difficultyColor {
    switch (path.difficultyLevel) {
      case 'beginner':
        return AppColors.beginner;
      case 'advanced':
        return AppColors.advanced;
      default:
        return AppColors.intermediate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.backgroundDark,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios, size: 20),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.backgroundDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          path.difficultyLevel ?? 'intermediate',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _difficultyColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        path.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            path.targetRole,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Progress Stats
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Progress',
                          value:
                              '${path.completionPercentage.toStringAsFixed(0)}%',
                          icon: Icons.trending_up,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Completed',
                          value:
                              '${path.completedMilestones}/${path.milestones.length}',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Duration',
                          value: '${path.estimatedDurationMonths ?? "?"}mo',
                          icon: Icons.schedule_outlined,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 16),

                  // Progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${path.completionPercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearPercentIndicator(
                        percent: (path.completionPercentage / 100).clamp(
                          0.0,
                          1.0,
                        ),
                        lineHeight: 10,
                        backgroundColor: AppColors.backgroundSurface,
                        progressColor: AppColors.primary,
                        barRadius: const Radius.circular(10),
                        padding: EdgeInsets.zero,
                        animation: true,
                        animationDuration: 1000,
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 24),

                  if (path.description != null) ...[
                    Text(
                      path.description!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate(delay: 250.ms).fadeIn(),
                    const SizedBox(height: 24),
                  ],

                  const Text(
                    'Milestones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ).animate(delay: 300.ms).fadeIn(),

                  const SizedBox(height: 4),
                  Text(
                    'Tap milestone to view details. Tap circle to mark complete.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ).animate(delay: 320.ms).fadeIn(),

                  const SizedBox(height: 20),

                  // Milestones
                  ...path.milestones.asMap().entries.map((entry) {
                    final index = entry.key;
                    final milestone = entry.value;
                    return MilestoneTile(
                          milestone: milestone,
                          isLast: index == path.milestones.length - 1,
                          onToggle: () {
                            ref
                                .read(careerPathsProvider.notifier)
                                .toggleMilestone(
                                  path.id,
                                  milestone.id,
                                  !milestone.isCompleted,
                                );
                          },
                          onTap: () {
                            context.push(
                              '/milestone/${milestone.id}',
                              extra: {'careerPathId': path.id},
                            );
                          },
                        )
                        .animate(
                          delay: Duration(milliseconds: 350 + (index * 80)),
                        )
                        .fadeIn()
                        .slideX(begin: 0.1, end: 0);
                  }),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/skill_provider.dart';
import '../../../providers/achievement_provider.dart';
import '../../widgets/analytics/analytics_widgets.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsNotifierProvider);
    final skillCountAsync = ref.watch(userSkillCountProvider);
    final completedSkillsAsync = ref.watch(completedSkillCountProvider);
    final achievementsAsync = ref.watch(achievementNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(title: const Text('Progress & Analytics'), elevation: 0),
      body: analyticsAsync.when(
        data: (analytics) {
          if (analytics == null) {
            return const Center(child: Text('No analytics data available'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(analyticsNotifierProvider);
              ref.invalidate(dailyProgressProvider);
            },
            color: AppColors.primary,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppDimensions.paddingM,
                    mainAxisSpacing: AppDimensions.paddingM,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatsCardWidget(
                        label: 'Learning Hours',
                        value: analytics.learningHours.toString(),
                        unit: 'h',
                        icon: Icons.timer,
                        bgColor: Colors.blue,
                      ),
                      skillCountAsync.when(
                        data: (count) => StatsCardWidget(
                          label: 'Skills Started',
                          value: count.toString(),
                          unit: 'skills',
                          icon: Icons.school,
                          bgColor: Colors.purple,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      StatsCardWidget(
                        label: 'Milestones',
                        value: analytics.milestonesCompleted.toString(),
                        unit: 'completed',
                        icon: Icons.flag,
                        bgColor: Colors.green,
                      ),
                      achievementsAsync.when(
                        data: (achievements) => StatsCardWidget(
                          label: 'Achievements',
                          value: achievements.length.toString(),
                          unit: 'earned',
                          icon: Icons.emoji_events,
                          bgColor: Colors.orange,
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Streak Widget
                  StreakWidget(
                    currentStreak: analytics.currentStreak,
                    longestStreak: analytics.longestStreak,
                    lastActivityDate: analytics.lastActivityDate,
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Progress Section
                  const Text(
                    'Career Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  ProgressBarWidget(
                    progress: analytics.milestonesCompleted.toDouble(),
                    label: 'Milestones Completed',
                    progressText: '${analytics.milestonesCompleted} milestones',
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Skills Progress
                  completedSkillsAsync.when(
                    data: (completed) => Column(
                      children: [
                        const Text(
                          'Skills Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingM),
                        skillCountAsync.when(
                          data: (total) => ProgressBarWidget(
                            progress: total > 0 ? (completed / total) * 100 : 0,
                            label: 'Skills Acquired',
                            progressText: '$completed / $total skills',
                            color: Colors.purple,
                          ),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Tips Section
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundCard.withValues(alpha: 0.5),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.amber,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Pro Tips',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          analytics.currentStreak > 0
                              ? 'Keep your learning streak going! You\'re doing great.'
                              : 'Start your learning streak today to maintain momentum.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading analytics',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

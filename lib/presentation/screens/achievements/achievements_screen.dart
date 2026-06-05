import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/achievement_provider.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(achievementNotifierProvider);
    final allAchievementsAsync = ref.watch(allAchievementsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
      ),
      body: achievementsAsync.when(
        data: (userAchievements) => allAchievementsAsync.when(
          data: (allAchievements) {
            final earnedIds = userAchievements.map((a) => a.achievementId).toSet();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            userAchievements.length.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            'Earned',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            allAchievements.length.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Earned Achievements
                  if (userAchievements.isNotEmpty) ...[
                    const Text(
                      'Earned Achievements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.paddingM,
                        mainAxisSpacing: AppDimensions.paddingM,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = userAchievements[index];
                        return _buildAchievementCard(
                          achievement.achievement?.title ?? 'Unknown',
                          achievement.achievement?.description ?? '',
                          earned: true,
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],

                  if (allAchievements
                      .where((a) => !earnedIds.contains(a.id))
                      .isNotEmpty) ...[
                    const Text(
                      'Locked Achievements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppDimensions.paddingM,
                        mainAxisSpacing: AppDimensions.paddingM,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allAchievements
                          .where((a) => !earnedIds.contains(a.id))
                          .length,
                      itemBuilder: (context, index) {
                        final locked = allAchievements
                            .where((a) => !earnedIds.contains(a.id))
                            .toList();
                        final achievement = locked[index];
                        return _buildAchievementCard(
                          achievement.title,
                          achievement.description,
                          earned: false,
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAchievementCard(String title, String description, {required bool earned}) {
    return Container(
      decoration: BoxDecoration(
        gradient: earned
            ? LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.1),
                ],
              )
            : LinearGradient(
                colors: [
                  AppColors.backgroundCard.withOpacity(0.5),
                  AppColors.backgroundCard.withOpacity(0.3),
                ],
              ),
        border: Border.all(
          color: earned ? AppColors.primary.withOpacity(0.4) : AppColors.textMuted.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            earned ? '🏆' : '🔒',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: earned ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: earned ? AppColors.textSecondary : AppColors.textMuted,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

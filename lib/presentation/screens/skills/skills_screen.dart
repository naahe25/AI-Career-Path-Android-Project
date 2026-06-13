import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/skill_provider.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userSkillsAsync = ref.watch(skillNotifierProvider);
    final allSkillsAsync = ref.watch(allSkillsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Skills'),
        elevation: 0,
      ),
      body: userSkillsAsync.when(
        data: (userSkills) => allSkillsAsync.when(
          data: (allSkills) {
            final startedSkillIds = userSkills.map((s) => s.skillId).toSet();
            final availableSkills = allSkills
                .where((s) => !startedSkillIds.contains(s.id))
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatBox('${userSkills.length}', 'Started'),
                      _buildStatBox(
                        '${userSkills.where((s) => s.isCompleted).length}',
                        'Completed',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.paddingL),

                  // Started Skills
                  if (userSkills.isNotEmpty) ...[
                    const Text(
                      'My Skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: userSkills.length,
                      itemBuilder: (context, index) {
                        final userSkill = userSkills[index];
                        return _buildSkillTile(userSkill);
                      },
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                  ],

                  // Recommended Skills
                  if (availableSkills.isNotEmpty) ...[
                    const Text(
                      'Recommended Skills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: availableSkills.take(5).length,
                      itemBuilder: (context, index) {
                        final skill = availableSkills[index];
                        return _buildRecommendedSkillTile(skill, ref);
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

  Widget _buildStatBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillTile(dynamic userSkill) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withValues(alpha: 0.5),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  userSkill.skill?.name ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (userSkill.isCompleted)
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: userSkill.proficiencyLevel / 100,
              minHeight: 6,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${userSkill.proficiencyLevel}% - ${userSkill.proficiencyLabel}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSkillTile(dynamic skill, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await ref.read(skillNotifierProvider.notifier).startSkill(skill.id);
      },
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${skill.estimatedHours}h • ${skill.difficulty}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.add_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

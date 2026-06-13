import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/auth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/career_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final careerPathsAsync = ref.watch(careerPathsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text(
                'Profile not found',
                style: TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          final totalPaths = careerPathsAsync.value?.length ?? 0;
          final completedPaths =
              careerPathsAsync.value
                  ?.where((p) => p.completionPercentage >= 100)
                  .length ??
              0;
          final avgProgress = totalPaths > 0
              ? (careerPathsAsync.value
                            ?.map((p) => p.completionPercentage)
                            .reduce((a, b) => a + b) ??
                        0) /
                    totalPaths
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (profile.fullName?.isNotEmpty == true
                          ? profile.fullName![0].toUpperCase()
                          : 'U'),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                const SizedBox(height: 12),

                Text(
                  profile.fullName ?? 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ).animate(delay: 100.ms).fadeIn(),

                if (profile.desiredField != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Aspiring ${profile.desiredField}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),
                ],

                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _StatBlock(
                        value: '$totalPaths',
                        label: 'Paths',
                        color: AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _StatBlock(
                        value: '$completedPaths',
                        label: 'Completed',
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: _StatBlock(
                        value: '${avgProgress.toStringAsFixed(0)}%',
                        label: 'Avg Progress',
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                // Info Cards
                _InfoCard(
                  icon: Icons.school_outlined,
                  label: 'Education',
                  value: profile.educationLevel ?? 'Not set',
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 10),

                _InfoCard(
                  icon: Icons.work_outline,
                  label: 'Current Role',
                  value: profile.currentRole ?? 'Not set',
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 10),

                _InfoCard(
                  icon: Icons.timeline,
                  label: 'Experience',
                  value: '${profile.yearsOfExperience} years',
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),

                if (profile.currentSkills.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      'Skills',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.currentSkills.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate(delay: 400.ms).fadeIn(),
                ],

                const SizedBox(height: 32),

                // Sign Out
                GestureDetector(
                  onTap: () async {
                    await AuthService().signOut();
                    if (context.mounted) context.go('/login');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusRound,
                      ),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppColors.error, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBlock({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

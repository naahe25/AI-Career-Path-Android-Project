import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/ai_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/career_provider.dart';
import '../../widgets/career/career_path_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_overlay.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isGenerating = false;

  Future<void> _generateCareerPaths() async {
    final profile = ref.read(profileProvider).value;
    if (profile == null) return;

    setState(() => _isGenerating = true);

    try {
      await ref.read(aiGenerationProvider.notifier).generatePaths(profile);

      if (mounted) {
        _showGeneratedPathsBottomSheet();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate paths: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showGeneratedPathsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _GeneratedPathsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final careerPathsAsync = ref.watch(careerPathsProvider);

    return LoadingOverlay(
      isLoading: _isGenerating,
      message: 'AI is generating your career paths...',
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(careerPathsProvider);
            },
            color: AppColors.primary,
            backgroundColor: AppColors.backgroundCard,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.paddingL,
                      AppDimensions.paddingL,
                      AppDimensions.paddingL,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                profileAsync.when(
                                  data: (profile) => Text(
                                    'Hello, ${profile?.fullName?.split(' ').first ?? 'there'} 👋',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  loading: () => const Text(
                                    'Hello 👋',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  error: (_, __) => const SizedBox.shrink(),
                                ),
                                const Text(
                                  'What will you learn today?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: AppColors.primaryGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(),

                        const SizedBox(height: 24),

                        // Generate Button
                        GestureDetector(
                              onTap: _generateCareerPaths,
                              child: Container(
                                padding: const EdgeInsets.all(
                                  AppDimensions.paddingM,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6C63FF),
                                      Color(0xFF9D97FF),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Generate New Path',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Let AI build your career roadmap',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .animate(delay: 100.ms)
                            .fadeIn()
                            .slideY(begin: 0.1, end: 0),

                        const SizedBox(height: 28),
                        const Text(
                          'My Career Paths',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ).animate(delay: 200.ms).fadeIn(),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // Career Paths List
                careerPathsAsync.when(
                  data: (paths) {
                    if (paths.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          child: _EmptyState(onGenerate: _generateCareerPaths),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.paddingL,
                        0,
                        AppDimensions.paddingL,
                        AppDimensions.paddingL,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final path = paths[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.paddingM,
                            ),
                            child: CareerPathCard(
                              careerPath: path,
                              index: index,
                              onTap: () {
                                context.push('/career-path/${path.id}');
                              },
                            ),
                          );
                        }, childCount: paths.length),
                      ),
                    );
                  },
                  loading: () => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        children: List.generate(
                          3,
                          (i) => _ShimmerCard(index: i),
                        ),
                      ),
                    ),
                  ),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Center(
                        child: Text(
                          'Failed to load paths: $e',
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onGenerate;

  const _EmptyState({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.route_outlined,
            color: AppColors.primary,
            size: 40,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        const Text(
          'No career paths yet',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Generate your first AI-powered career path and start your journey.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        AppButton(
          label: 'Generate My First Path',
          onPressed: onGenerate,
          icon: Icons.auto_awesome,
          width: 240,
        ),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final int index;

  const _ShimmerCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
          height: 160,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
        )
        .animate(
          onPlay: (c) => c.repeat(),
          delay: Duration(milliseconds: index * 100),
        )
        .shimmer(duration: 1200.ms, color: AppColors.backgroundSurface);
  }
}

class _GeneratedPathsSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_GeneratedPathsSheet> createState() =>
      _GeneratedPathsSheetState();
}

class _GeneratedPathsSheetState extends ConsumerState<_GeneratedPathsSheet> {
  bool _isSaving = false;

  Future<void> _savePath(GeneratedPath path) async {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      final saved = await ref
          .read(aiGenerationProvider.notifier)
          .savePath(userId, path);

      if (saved != null) {
        await ref.read(careerPathsProvider.notifier).addCareerPath(saved);
      }

      ref.read(aiGenerationProvider.notifier).reset();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Career path saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiGenerationProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: aiState.when(
            data: (paths) {
              if (paths == null || paths.isEmpty) {
                return const Center(child: Text('No paths generated'));
              }

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Generated Paths',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Choose one to add to your dashboard',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ref.read(aiGenerationProvider.notifier).reset();
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingL,
                      ),
                      itemCount: paths.length,
                      itemBuilder: (context, index) {
                        final path = paths[index];
                        return _GeneratedPathCard(
                          path: path,
                          onSave: () => _savePath(path),
                          isSaving: _isSaving,
                          index: index,
                        );
                      },
                    ),
                  ),
                ],
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
      },
    );
  }
}

class _GeneratedPathCard extends StatelessWidget {
  final GeneratedPath path;
  final VoidCallback onSave;
  final bool isSaving;
  final int index;

  const _GeneratedPathCard({
    required this.path,
    required this.onSave,
    required this.isSaving,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                path.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _InfoChip(
                    icon: Icons.flag_outlined,
                    label: path.targetRole,
                    color: AppColors.primary,
                  ),
                  _InfoChip(
                    icon: Icons.schedule_outlined,
                    label: '${path.estimatedDurationMonths} months',
                    color: AppColors.info,
                  ),
                  _InfoChip(
                    icon: Icons.bar_chart,
                    label: path.difficultyLevel,
                    color: path.difficultyLevel == 'beginner'
                        ? AppColors.beginner
                        : path.difficultyLevel == 'advanced'
                        ? AppColors.advanced
                        : AppColors.intermediate,
                  ),
                  _InfoChip(
                    icon: Icons.checklist,
                    label: '${path.milestones.length} milestones',
                    color: AppColors.secondary,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppButton(
                label: 'Add This Path',
                onPressed: isSaving ? null : onSave,
                isLoading: isSaving,
                icon: Icons.add_circle_outline,
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 150))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

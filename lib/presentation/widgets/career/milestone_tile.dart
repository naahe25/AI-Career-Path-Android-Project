import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/milestone_model.dart';

class MilestoneTile extends StatelessWidget {
  final MilestoneModel milestone;
  final bool isLast;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const MilestoneTile({
    super.key,
    required this.milestone,
    this.isLast = false,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: milestone.isCompleted
                          ? AppColors.success
                          : AppColors.backgroundSurface,
                      border: Border.all(
                        color: milestone.isCompleted
                            ? AppColors.success
                            : AppColors.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: milestone.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Center(
                            child: Text(
                              '${milestone.orderIndex + 1}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            milestone.isCompleted
                                ? AppColors.success
                                : AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: isLast ? 0 : AppDimensions.paddingM,
                ),
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: milestone.isCompleted
                      ? AppColors.success.withOpacity(0.08)
                      : AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: milestone.isCompleted
                        ? AppColors.success.withOpacity(0.3)
                        : const Color(0xFF2A2A45),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: milestone.isCompleted
                                  ? AppColors.success
                                  : AppColors.textPrimary,
                              decoration: milestone.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: AppColors.success,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    if (milestone.description != null &&
                        milestone.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        milestone.description!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (milestone.estimatedWeeks != null ||
                        milestone.skillsGained.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (milestone.estimatedWeeks != null)
                            _Chip(
                              label: '${milestone.estimatedWeeks}w',
                              icon: Icons.schedule_outlined,
                              color: AppColors.info,
                            ),
                          ...milestone.skillsGained
                              .take(2)
                              .map(
                                (skill) => _Chip(
                                  label: skill,
                                  color: AppColors.primary,
                                ),
                              ),
                          if (milestone.resources.isNotEmpty)
                            _Chip(
                              label: '${milestone.resources.length} resources',
                              icon: Icons.library_books_outlined,
                              color: AppColors.secondary,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const _Chip({required this.label, this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class StatsCardWidget extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color? bgColor;

  const StatsCardWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (bgColor ?? AppColors.primary).withOpacity(0.1),
            (bgColor ?? AppColors.primary).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: (bgColor ?? AppColors.primary).withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: bgColor ?? AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;

  const StreakWidget({
    Key? key,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isStreakActive = lastActivityDate != null &&
        DateTime.now().difference(lastActivityDate!).inDays <= 1;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '🔥 Learning Streak',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (isStreakActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStreakInfo('Current', currentStreak.toString()),
              Container(
                height: 50,
                width: 1,
                color: AppColors.textMuted.withOpacity(0.2),
              ),
              _buildStreakInfo('Longest', longestStreak.toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakInfo(String label, String value) {
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
}

class ProgressBarWidget extends StatelessWidget {
  final double progress;
  final String label;
  final String progressText;
  final Color? color;

  const ProgressBarWidget({
    Key? key,
    required this.progress,
    required this.label,
    required this.progressText,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              progressText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.backgroundCard.withOpacity(0.5),
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/job_model.dart';
import '../common/neo_card.dart';

/// A 3D job card used in the jobs list and saved jobs.
class JobCard extends StatelessWidget {
  final JobModel job;
  final VoidCallback onTap;
  final bool isSaved;
  final bool isApplied;
  final VoidCallback? onToggleSave;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.isSaved = false,
    this.isApplied = false,
    this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanyBadge(company: job.company),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onToggleSave != null)
                GestureDetector(
                  onTap: onToggleSave,
                  child: Icon(
                    isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: isSaved ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                job.isRemote ? Icons.public : Icons.location_on_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  job.isRemote ? 'Remote · ${job.location}' : job.location,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                job.postedLabel,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
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
                color: AppColors.info,
              ),
              if (isApplied)
                const TintChip(
                  icon: Icons.check_circle,
                  label: 'Applied',
                  color: AppColors.success,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanyBadge extends StatelessWidget {
  final String company;
  const _CompanyBadge({required this.company});

  @override
  Widget build(BuildContext context) {
    final initial = company.trim().isNotEmpty
        ? company.trim().characters.first.toUpperCase()
        : '?';
    // Deterministic color from company name.
    final palette = [
      AppColors.primaryGradient,
      AppColors.successGradient,
      AppColors.infoGradient,
      AppColors.accentGradient,
    ];
    final gradient = palette[company.hashCode.abs() % palette.length];
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: AppShadows.glow(gradient.first),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/job_model.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/common/neo_card.dart';

/// Shown to a job's poster: who applied, their info, and their CV.
class JobApplicantsScreen extends ConsumerWidget {
  final String jobId;
  const JobApplicantsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(jobApplicantsProvider(jobId));
    final jobAsync = ref.watch(jobByIdProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: Text(jobAsync.valueOrNull?.title ?? 'Applicants'),
      ),
      body: applicantsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              'Could not load applicants.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
        data: (applicants) {
          if (applicants.isEmpty) {
            return const _ApplicantsEmpty();
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(jobApplicantsProvider(jobId)),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: applicants.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      '${applicants.length} '
                      '${applicants.length == 1 ? 'applicant' : 'applicants'}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }
                final a = applicants[index - 1];
                return _ApplicantCard(application: a)
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 280.ms)
                    .slideY(begin: 0.08, end: 0);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final JobApplicationModel application;
  const _ApplicantCard({required this.application});

  Future<void> _openCv(BuildContext context) async {
    final url = application.cvUrl;
    if (url == null) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the CV.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = (application.applicantName?.trim().isNotEmpty == true)
        ? application.applicantName!
        : 'Member';
    final avatar = application.applicantAvatarUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Avatar(name: name, avatarUrl: avatar),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (application.applicantHeadline != null &&
                          application.applicantHeadline!.isNotEmpty)
                        Text(
                          application.applicantHeadline!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      Text(
                        'Applied ${_ago(application.appliedAt)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (application.coverNote != null &&
                application.coverNote!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Text(
                  application.coverNote!,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            GradientButton(
              label: 'Open CV${application.cvName != null ? ' · ${application.cvName}' : ''}',
              icon: Icons.description_outlined,
              height: 46,
              gradient: AppColors.infoGradient,
              onTap: application.cvUrl == null ? null : () => _openCv(context),
            ),
          ],
        ),
      ),
    );
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
    return 'just now';
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const _Avatar({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(radius: 26, backgroundImage: NetworkImage(avatarUrl!));
    }
    return GradientAvatar(name: name, size: 52);
  }
}

class _ApplicantsEmpty extends StatelessWidget {
  const _ApplicantsEmpty();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Icon(Icons.inbox_outlined,
            size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'No applicants yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Center(
          child: Text(
            'When people apply, they will show up here with their CV.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

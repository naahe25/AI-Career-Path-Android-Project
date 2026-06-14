import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/career_provider.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/common/neo_card.dart';

/// LinkedIn-style profile: cover banner, overlapping avatar, headline, edit
/// button, About + Skills, and the user's activity (applied jobs + job posts).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _picker = ImagePicker();
  bool _uploadingAvatar = false;

  Future<void> _changePhoto() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final name = file.name.toLowerCase();
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      setState(() => _uploadingAvatar = true);
      await ref
          .read(profileProvider.notifier)
          .uploadAvatar(bytes, extension: ext == 'jpeg' ? 'jpg' : ext);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update photo. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(
              child: Text('Profile not found',
                  style: TextStyle(color: AppColors.textMuted)),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header(
                profile: profile,
                uploading: _uploadingAvatar,
                onChangePhoto: _changePhoto,
              )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.paddingL,
                    8,
                    AppDimensions.paddingL,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _StatsRow(),
                      const SizedBox(height: 20),
                      _AboutSection(profile: profile),
                      if (profile.currentSkills.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        _SkillsSection(skills: profile.currentSkills),
                      ],
                      const SizedBox(height: 20),
                      const _AppliedJobsSection(),
                      const SizedBox(height: 20),
                      const _MyJobPostsSection(),
                      const SizedBox(height: 24),
                      _SignOutButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header (banner + avatar + name + edit)
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  final ProfileModel profile;
  final bool uploading;
  final VoidCallback onChangePhoto;

  const _Header({
    required this.profile,
    required this.uploading,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover banner
        Container(
          height: 150,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          top: 44,
          right: 16,
          child: SafeArea(
            child: _GlassIconButton(
              icon: Icons.edit_outlined,
              onTap: () => context.push('/edit-profile'),
            ),
          ),
        ),
        // Body card with overlapping avatar
        Padding(
          padding: const EdgeInsets.only(top: 96),
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL),
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  profile.fullName ?? 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.currentRole ??
                      (profile.desiredField != null
                          ? 'Aspiring ${profile.desiredField}'
                          : 'Add a headline'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (profile.educationLevel != null &&
                    profile.educationLevel!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 5),
                      Text(
                        profile.educationLevel!,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Edit profile',
                    icon: Icons.edit,
                    height: 44,
                    onTap: () => context.push('/edit-profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Overlapping avatar
        Positioned(
          top: 96 - 44,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: uploading ? null : onChangePhoto,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.backgroundCard, width: 4),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: _ProfileAvatar(
                      url: profile.avatarUrl,
                      name: profile.fullName,
                    ),
                  ),
                  if (uploading)
                    const Positioned.fill(
                      child: CircleAvatar(
                        backgroundColor: Colors.black38,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: AppColors.primaryGradient),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.backgroundCard, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? url;
  final String? name;
  const _ProfileAvatar({this.url, this.name});

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(radius: 44, backgroundImage: NetworkImage(url!));
    }
    return GradientAvatar(name: name, size: 88);
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats
// ---------------------------------------------------------------------------
class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paths = ref.watch(careerPathsProvider).value ?? [];
    final applied = ref.watch(appliedJobIdsProvider).length;
    final posts = ref.watch(myPostedJobsProvider).value?.length ?? 0;
    final completed =
        paths.where((p) => p.completionPercentage >= 100).length;

    return Row(
      children: [
        Expanded(
          child: _StatBlock(
              value: '${paths.length}',
              label: 'Paths',
              color: AppColors.primary),
        ),
        Expanded(
          child: _StatBlock(
              value: '$completed',
              label: 'Completed',
              color: AppColors.success),
        ),
        Expanded(
          child: _StatBlock(
              value: '$applied', label: 'Applied', color: AppColors.info),
        ),
        Expanded(
          child: _StatBlock(
              value: '$posts', label: 'Posts', color: AppColors.accent),
        ),
      ],
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatBlock(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, color: color),
        ),
        Text(label,
            style:
                const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// About + Skills
// ---------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final ProfileModel profile;
  const _AboutSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'About',
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Current role',
            value: profile.currentRole ?? 'Not set',
          ),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Desired field',
            value: profile.desiredField ?? 'Not set',
          ),
          _InfoRow(
            icon: Icons.timeline,
            label: 'Experience',
            value: '${profile.yearsOfExperience} years',
          ),
          _InfoRow(
            icon: Icons.school_outlined,
            label: 'Education',
            value: profile.educationLevel ?? 'Not set',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted)),
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

class _SkillsSection extends StatelessWidget {
  final List<String> skills;
  const _SkillsSection({required this.skills});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Skills',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: skills
            .map((s) => TintChip(label: s, color: AppColors.primary))
            .toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Applied jobs
// ---------------------------------------------------------------------------
class _AppliedJobsSection extends ConsumerWidget {
  const _AppliedJobsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsListProvider);
    return _SectionCard(
      title: 'Jobs you applied to',
      child: applicationsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (e, _) => const Text('Could not load applications.',
            style: TextStyle(color: AppColors.textMuted)),
        data: (apps) {
          if (apps.isEmpty) {
            return const _EmptyHint(
              icon: Icons.send_outlined,
              text: 'You haven\'t applied to any jobs yet.',
            );
          }
          return Column(
            children: apps.map((a) {
              final job = a.job;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: job == null ? null : () => context.push('/job/${job.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: AppColors.primaryGradient),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (job?.company ?? '?')
                              .characters
                              .first
                              .toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job?.title ?? 'Job',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${job?.company ?? ''} · ${a.statusLabel}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My job posts (with applicant counts)
// ---------------------------------------------------------------------------
class _MyJobPostsSection extends ConsumerWidget {
  const _MyJobPostsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(myPostedJobsProvider);
    return _SectionCard(
      title: 'Your job posts',
      trailing: GestureDetector(
        onTap: () => context.push('/post-job'),
        child: const Icon(Icons.add_circle_outline, color: AppColors.primary),
      ),
      child: postsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        error: (e, _) => const Text('Could not load your posts.',
            style: TextStyle(color: AppColors.textMuted)),
        data: (jobs) {
          if (jobs.isEmpty) {
            return const _EmptyHint(
              icon: Icons.campaign_outlined,
              text: 'You haven\'t posted any hiring listings yet.',
            );
          }
          return Column(
            children: jobs
                .map((job) => _MyJobPostTile(job: job))
                .toList(),
          );
        },
      ),
    );
  }
}

class _MyJobPostTile extends ConsumerWidget {
  final JobModel job;
  const _MyJobPostTile({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicantsAsync = ref.watch(jobApplicantsProvider(job.id));
    final count = applicantsAsync.valueOrNull?.length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push('/job/${job.id}/applicants'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: AppColors.infoGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.work_outline, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      count == null
                          ? 'View applicants'
                          : '$count ${count == 1 ? 'applicant' : 'applicants'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.groups_outlined, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ),
      ],
    );
  }
}

class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await AuthService().signOut();
        if (context.mounted) context.go('/login');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3), width: 1),
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
    );
  }
}

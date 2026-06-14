import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/job_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/common/neo_card.dart';

class JobDetailScreen extends ConsumerWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobByIdProvider(jobId));

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final saved = ref.watch(savedJobIdsProvider).contains(jobId);
              return IconButton(
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.primary : AppColors.textPrimary),
                onPressed: () =>
                    ref.read(savedJobIdsProvider.notifier).toggle(jobId),
              );
            },
          ),
        ],
      ),
      body: jobAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => const Center(child: Text('Failed to load job')),
        data: (job) {
          if (job == null) {
            return const Center(child: Text('Job not found'));
          }
          return _JobDetailBody(job: job);
        },
      ),
    );
  }
}

class _JobDetailBody extends ConsumerWidget {
  final JobModel job;
  const _JobDetailBody({required this.job});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applied = ref.watch(appliedJobIdsProvider).contains(job.id);
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isOwner = job.postedBy != null && job.postedBy == currentUserId;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppDimensions.paddingL),
            children: [
              NeoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppShadows.glow(AppColors.primary),
                          ),
                          child: Text(
                            job.company.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job.title,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${job.company} · ${job.postedLabel}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TintChip(
                          icon: job.isRemote
                              ? Icons.public
                              : Icons.location_on_outlined,
                          label: job.location,
                          color: AppColors.info,
                        ),
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
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.08, end: 0),
              const SizedBox(height: 18),
              const _SectionTitle('About the role'),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              if (job.requirements.isNotEmpty) ...[
                const SizedBox(height: 22),
                const _SectionTitle('What you\'ll need'),
                const SizedBox(height: 10),
                ...job.requirements.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check,
                                size: 13, color: AppColors.success),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              r,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              if (job.tags.isNotEmpty) ...[
                const SizedBox(height: 18),
                const _SectionTitle('Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: job.tags
                      .map((t) => TintChip(label: t, color: AppColors.primary))
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
        // Apply bar
        Container(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.paddingL,
            AppDimensions.paddingM,
            AppDimensions.paddingL,
            AppDimensions.paddingM + MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.backgroundCard,
            boxShadow: AppShadows.soft,
          ),
          child: isOwner
              ? GradientButton(
                  label: 'View applicants',
                  icon: Icons.groups_outlined,
                  gradient: AppColors.infoGradient,
                  onTap: () => context.push('/job/${job.id}/applicants'),
                )
              : GradientButton(
                  label: applied ? 'Application submitted' : 'Apply now',
                  icon: applied ? Icons.check_circle : Icons.send_rounded,
                  gradient: applied
                      ? AppColors.successGradient
                      : AppColors.primaryGradient,
                  onTap: applied ? null : () => _openApplySheet(context),
                ),
        ),
      ],
    );
  }

  void _openApplySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplySheet(job: job),
    );
  }
}

/// LinkedIn-style "Easy Apply" sheet: an (optional) cover note and a REQUIRED
/// CV upload (PDF or Word).
class _ApplySheet extends ConsumerStatefulWidget {
  final JobModel job;
  const _ApplySheet({required this.job});

  @override
  ConsumerState<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends ConsumerState<_ApplySheet> {
  final _note = TextEditingController();
  Uint8List? _cvBytes;
  String? _cvName;
  String _cvExt = 'pdf';
  bool _submitting = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickCv() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) return;
      setState(() {
        _cvBytes = bytes;
        _cvName = file.name;
        _cvExt = (file.extension ?? 'pdf').toLowerCase();
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the file picker.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    if (_cvBytes == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Please attach your CV to apply.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;
    final profile = ref.read(profileProvider).value;

    setState(() => _submitting = true);
    final navigator = Navigator.of(context);
    try {
      final cvUrl = await ref.read(jobServiceProvider).uploadCv(
            userId,
            _cvBytes!,
            _cvName ?? 'cv.$_cvExt',
            extension: _cvExt,
          );
      await ref.read(appliedJobIdsProvider.notifier).apply(
            widget.job.id,
            coverNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
            cvUrl: cvUrl,
            cvName: _cvName ?? 'CV',
            applicant: profile,
          );
      ref.invalidate(applicationsListProvider);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Applied to ${widget.job.title} 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not submit application. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Apply to ${widget.job.title}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${widget.job.company} · applying as ${profile?.fullName ?? 'you'}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            const Text(
              'Your CV *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickCv,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: _cvBytes == null
                        ? AppColors.border
                        : AppColors.success.withValues(alpha: 0.5),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _cvBytes == null
                          ? Icons.upload_file_outlined
                          : Icons.description,
                      color: _cvBytes == null
                          ? AppColors.primary
                          : AppColors.success,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _cvName ?? 'Upload PDF or Word document',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _cvBytes == null
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_cvBytes != null)
                      const Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Cover note (optional)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 4,
              minLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Add a short note to the hiring manager...',
              ),
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Submit application',
              icon: Icons.send_rounded,
              isLoading: _submitting,
              onTap: _submit,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }
}

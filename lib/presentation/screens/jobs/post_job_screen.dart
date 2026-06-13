import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/job_provider.dart';
import '../../widgets/common/neo_card.dart';

/// A LinkedIn-style "post a job" form. Any signed-in user can publish a hiring
/// listing that then shows up in the jobs feed for everyone.
class PostJobScreen extends ConsumerStatefulWidget {
  const PostJobScreen({super.key});

  @override
  ConsumerState<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends ConsumerState<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _location = TextEditingController();
  final _category = TextEditingController();
  final _salaryMin = TextEditingController();
  final _salaryMax = TextEditingController();
  final _description = TextEditingController();
  final _requirements = TextEditingController();
  final _tags = TextEditingController();

  bool _isRemote = false;
  String _employmentType = 'full_time';
  String _experienceLevel = 'mid';
  bool _submitting = false;

  static const _employmentOptions = {
    'full_time': 'Full-time',
    'part_time': 'Part-time',
    'contract': 'Contract',
    'internship': 'Internship',
  };
  static const _experienceOptions = {
    'entry': 'Entry',
    'mid': 'Mid',
    'senior': 'Senior',
    'lead': 'Lead',
  };

  @override
  void dispose() {
    _title.dispose();
    _company.dispose();
    _location.dispose();
    _category.dispose();
    _salaryMin.dispose();
    _salaryMax.dispose();
    _description.dispose();
    _requirements.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _splitLines(String raw) => raw
      .split(RegExp(r'[\n,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return;

    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(jobServiceProvider).createJob(
            userId: userId,
            title: _title.text.trim(),
            company: _company.text.trim(),
            location: _location.text.trim().isEmpty
                ? 'Remote'
                : _location.text.trim(),
            isRemote: _isRemote,
            employmentType: _employmentType,
            experienceLevel: _experienceLevel,
            category: _category.text.trim().isEmpty
                ? null
                : _category.text.trim(),
            salaryMin: int.tryParse(_salaryMin.text.trim()),
            salaryMax: int.tryParse(_salaryMax.text.trim()),
            description: _description.text.trim(),
            requirements: _splitLines(_requirements.text),
            tags: _splitLines(_tags.text),
          );
      ref.invalidate(jobsProvider);
      router.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Your job listing is now live 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not post the job. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const Text('Post a job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          children: [
            const Text(
              'Hiring for a role?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share an opportunity with the community. It will appear in the jobs feed for everyone.',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            _field(_title, 'Job title *', hint: 'e.g. Senior Flutter Engineer',
                required: true),
            _field(_company, 'Company *', hint: 'e.g. Nimbus Labs',
                required: true),
            _field(_location, 'Location', hint: 'e.g. San Francisco, CA'),
            const SizedBox(height: 4),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
              title: const Text(
                'Remote friendly',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              value: _isRemote,
              onChanged: (v) => setState(() => _isRemote = v),
            ),
            const SizedBox(height: 8),
            _label('Employment type'),
            _ChoiceRow(
              options: _employmentOptions,
              selected: _employmentType,
              onSelect: (v) => setState(() => _employmentType = v),
            ),
            const SizedBox(height: 16),
            _label('Experience level'),
            _ChoiceRow(
              options: _experienceOptions,
              selected: _experienceLevel,
              onSelect: (v) => setState(() => _experienceLevel = v),
            ),
            const SizedBox(height: 16),
            _field(_category, 'Category', hint: 'e.g. Mobile Development'),
            Row(
              children: [
                Expanded(
                  child: _field(_salaryMin, 'Salary min',
                      hint: '90000', number: true),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(_salaryMax, 'Salary max',
                      hint: '140000', number: true),
                ),
              ],
            ),
            _field(_description, 'Description *',
                hint: 'What the role is about, the team, the impact...',
                maxLines: 5, required: true),
            _field(_requirements, 'Requirements',
                hint: 'One per line (or comma separated)', maxLines: 4),
            _field(_tags, 'Tags', hint: 'Flutter, Dart, Remote'),
            const SizedBox(height: 8),
            GradientButton(
              label: 'Publish job',
              icon: Icons.campaign_outlined,
              isLoading: _submitting,
              onTap: _submit,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    int maxLines = 1,
    bool number = false,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: number ? TextInputType.number : TextInputType.text,
            inputFormatters:
                number ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(hintText: hint),
            validator: required
                ? (v) => (v == null || v.trim().isEmpty)
                    ? 'This field is required'
                    : null
                : null,
          ),
        ],
      ),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  final Map<String, String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((e) {
        final isSelected = e.key == selected;
        return GestureDetector(
          onTap: () => onSelect(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(100),
              boxShadow:
                  isSelected ? AppShadows.glow(AppColors.primary) : AppShadows.subtle,
            ),
            child: Text(
              e.value,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _roleController = TextEditingController();
  final _desiredFieldController = TextEditingController();
  final _skillController = TextEditingController();

  final List<String> _skills = [];
  String _selectedEducation = 'Bachelor\'s Degree';
  int _yearsExperience = 0;
  bool _isLoading = false;

  final List<String> _educationOptions = [
    'High School',
    'Associate\'s Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Self-taught',
    'Bootcamp',
  ];

  @override
  void dispose() {
    _roleController.dispose();
    _desiredFieldController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() => _skills.remove(skill));
  }

  Future<void> _saveAndContinue() async {
    if (_desiredFieldController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tell us your desired field'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(profileProvider.notifier).updateProfile({
        'current_skills': _skills,
        'education_level': _selectedEducation,
        'years_of_experience': _yearsExperience,
        'user_current_role': _roleController.text.trim(),
        'desired_field': _desiredFieldController.text.trim(),
      });

      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'Step 1 of 1 • Setup Profile',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 20),
                const Text(
                  'Tell us about\nyourself',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 50.ms).fadeIn().slideX(begin: -0.1, end: 0),
                const SizedBox(height: 6),
                const Text(
                  'Help our AI generate career paths tailored for you.',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ).animate(delay: 100.ms).fadeIn(),
                const SizedBox(height: 32),

                // Desired Field
                _SectionLabel(
                  label: 'What field do you want to work in?',
                  required: true,
                ),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'e.g. Artificial Intelligence, Cyber Security...',
                  controller: _desiredFieldController,
                  prefixIcon: Icons.flag_outlined,
                  textInputAction: TextInputAction.next,
                ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Current Role
                _SectionLabel(label: 'Your current role / title'),
                const SizedBox(height: 8),
                AppTextField(
                  hint: 'e.g. Student, Junior Developer, Analyst...',
                  controller: _roleController,
                  prefixIcon: Icons.work_outline,
                  textInputAction: TextInputAction.next,
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Education Level
                _SectionLabel(label: 'Education level'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: const Color(0xFF2A2A45),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedEducation,
                      isExpanded: true,
                      dropdownColor: AppColors.backgroundCard,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingM,
                      ),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textMuted,
                      ),
                      items: _educationOptions.map((e) {
                        return DropdownMenuItem(value: e, child: Text(e));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedEducation = v);
                        }
                      },
                    ),
                  ),
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Years of Experience
                _SectionLabel(label: 'Years of experience: $_yearsExperience'),
                Slider(
                  value: _yearsExperience.toDouble(),
                  min: 0,
                  max: 20,
                  divisions: 20,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.backgroundSurface,
                  label: '$_yearsExperience years',
                  onChanged: (v) {
                    setState(() => _yearsExperience = v.round());
                  },
                ).animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 20),

                // Skills
                _SectionLabel(label: 'Your current skills'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        hint: 'Add a skill (e.g. Python, React...)',
                        controller: _skillController,
                        prefixIcon: Icons.psychology_outlined,
                        textInputAction: TextInputAction.done,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addSkill,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),

                if (_skills.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .map(
                          (skill) => _SkillChip(
                            skill: skill,
                            onRemove: () => _removeSkill(skill),
                          ),
                        )
                        .toList(),
                  ).animate().fadeIn(),
                ],

                const SizedBox(height: 40),

                AppButton(
                  label: 'Generate My Career Paths',
                  onPressed: _saveAndContinue,
                  isLoading: _isLoading,
                  icon: Icons.auto_awesome,
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _SectionLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(color: AppColors.error, fontSize: 13),
          ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String skill;
  final VoidCallback onRemove;

  const _SkillChip({required this.skill, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/profile_model.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/common/neo_card.dart';

/// LinkedIn-style "Edit profile" form. Saves straight to the `profiles` table.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();
  final _desiredField = TextEditingController();
  final _education = TextEditingController();
  final _experience = TextEditingController();
  final _skills = TextEditingController();

  final _picker = ImagePicker();
  Uint8List? _newAvatar;
  String _avatarExt = 'jpg';
  bool _saving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    _desiredField.dispose();
    _education.dispose();
    _experience.dispose();
    _skills.dispose();
    super.dispose();
  }

  void _hydrate(ProfileModel p) {
    if (_initialized) return;
    _initialized = true;
    _name.text = p.fullName ?? '';
    _role.text = p.currentRole ?? '';
    _desiredField.text = p.desiredField ?? '';
    _education.text = p.educationLevel ?? '';
    _experience.text = p.yearsOfExperience.toString();
    _skills.text = p.currentSkills.join(', ');
  }

  Future<void> _pickAvatar() async {
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
      setState(() {
        _newAvatar = bytes;
        _avatarExt = ext == 'jpeg' ? 'jpg' : ext;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the image picker.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<String> _splitSkills(String raw) => raw
      .split(RegExp(r'[\n,]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final notifier = ref.read(profileProvider.notifier);
    try {
      if (_newAvatar != null) {
        await notifier.uploadAvatar(_newAvatar!, extension: _avatarExt);
      }
      await notifier.updateProfile({
        'full_name': _name.text.trim(),
        'user_current_role': _role.text.trim(),
        'desired_field': _desiredField.text.trim(),
        'education_level': _education.text.trim(),
        'years_of_experience': int.tryParse(_experience.text.trim()) ?? 0,
        'current_skills': _splitSkills(_skills.text),
      });
      router.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profile updated ✓'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not save your profile. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        title: const Text('Edit profile'),
      ),
      body: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }
          _hydrate(profile);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickAvatar,
                    child: Stack(
                      children: [
                        _AvatarPreview(
                          bytes: _newAvatar,
                          url: profile.avatarUrl,
                          name: profile.fullName,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: AppColors.primaryGradient,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.backgroundDark, width: 3),
                            ),
                            child: const Icon(Icons.camera_alt,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Tap to change photo',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 24),
                _field(_name, 'Full name', required: true),
                _field(_role, 'Headline / current role',
                    hint: 'e.g. Aspiring Flutter Engineer'),
                _field(_desiredField, 'Desired field',
                    hint: 'e.g. Mobile Development'),
                _field(_education, 'Education',
                    hint: 'e.g. B.Sc. Computer Science'),
                _field(_experience, 'Years of experience',
                    hint: '0', number: true),
                _field(_skills, 'Skills',
                    hint: 'Comma separated, e.g. Flutter, Dart, SQL',
                    maxLines: 2),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'Save changes',
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onTap: _save,
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
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

class _AvatarPreview extends StatelessWidget {
  final Uint8List? bytes;
  final String? url;
  final String? name;
  const _AvatarPreview({this.bytes, this.url, this.name});

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return CircleAvatar(radius: 48, backgroundImage: MemoryImage(bytes!));
    }
    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(radius: 48, backgroundImage: NetworkImage(url!));
    }
    return GradientAvatar(name: name, size: 96);
  }
}

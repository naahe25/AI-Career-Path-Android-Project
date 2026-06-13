import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) context.go('/home');
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithOAuth(OAuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      final started = await AuthService().signInWithOAuth(provider);
      if (!started && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not start ${provider.name} login.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${provider.name} login failed: $e'),
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
                const SizedBox(height: 48),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                const SizedBox(height: 32),
                const Text(
                  'Welcome back',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1, end: 0),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to continue your career journey',
                  style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                ).animate(delay: 150.ms).fadeIn().slideX(begin: -0.1, end: 0),
                const SizedBox(height: 40),
                AppTextField(
                  hint: 'Email address',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                AppTextField(
                  hint: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showResetPasswordDialog,
                    child: const Text(
                      'Forgot password?',
                      style: TextStyle(color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Sign In',
                  onPressed: _login,
                  isLoading: _isLoading,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.textMuted.withValues(alpha: 0.25),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.textMuted.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ).animate(delay: 380.ms).fadeIn(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _OAuthButton(
                        label: 'Google',
                        onTap: _isLoading
                            ? null
                            : () => _loginWithOAuth(OAuthProvider.google),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OAuthButton(
                        label: 'GitHub',
                        onTap: _isLoading
                            ? null
                            : () => _loginWithOAuth(OAuthProvider.github),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _OAuthButton(
                        label: 'LinkedIn',
                        onTap: _isLoading
                            ? null
                            : () => _loginWithOAuth(OAuthProvider.linkedin),
                      ),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController(text: _emailController.text);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: AppTextField(
            hint: 'Email address',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                try {
                  await AuthService().resetPassword(email);
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password reset email sent.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Reset failed: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }
}

class _OAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _OAuthButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.route_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                )
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            const Text(
                  'AI Career Path',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                )
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 8),
            const Text(
              'Your intelligent career navigator',
              style: TextStyle(fontSize: 14, color: AppColors.textMuted),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ).animate(delay: 700.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

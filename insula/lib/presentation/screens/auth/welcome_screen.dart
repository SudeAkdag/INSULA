import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/screens/auth/login_screen.dart';
import 'package:insula/presentation/screens/onboarding/onboarding_flow_screen.dart';

/// Karşılama ekranı: Insula ismi, slogan ve "Hadi Başlayalım" ile onboarding'e,
/// "Zaten hesabım var" ile giriş ekranına yönlendirme.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo / ikon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentTeal.withAlpha(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentTeal.withAlpha(38),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety_rounded,
                  size: 64,
                  color: AppColors.accentTeal,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Başlık
              Text(
                'Insula',
                style: AppTextStyles.h1.copyWith(
                  fontSize: 36,
                  color: AppColors.accentTeal,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Akıllı diyabet takipçiniz ve yaşam tarzı asistanınız',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecLight,
                  fontSize: 18,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              // Hadi Başlayalım — geniş, erişilebilir buton
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingFlowScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppRadius.defaultRadius),
                    ),
                  ),
                  child: const Text(
                    'Hadi Başlayalım',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Zaten hesabım var
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(
                  'Zaten hesabım var',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.accentTeal,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

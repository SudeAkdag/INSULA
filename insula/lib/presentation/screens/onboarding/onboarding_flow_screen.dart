import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/logic/viewmodels/auth_viewmodel.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/screens/main_screen.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_progress_bar.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_basic_info.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_diabetes_profile.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_treatment.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_glucose_monitoring.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_lifestyle_goals.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_health_conditions.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_emergency_security.dart';
import 'package:insula/presentation/screens/onboarding/steps/step_notifications_final.dart';

/// Çok adımlı kayıt/onboarding akışı. Üstte ilerleme çubuğu, adımlar arası yumuşak geçiş.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  static const int _totalSteps = 8;
  final PageController _pageController = PageController();
  final AuthViewModel _authViewModel = AuthViewModel();

  int _currentStep = 1;
  OnboardingData _data = OnboardingData();
  bool _isCompleting = false;

  void _goNext() {
    if (_currentStep < _totalSteps) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  Future<void> _completeOnboarding() async {
    final email = _data.email?.trim();
    final password = _data.password;
    if (email == null || email.isEmpty || password == null || password.length < 8) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen e-posta ve şifrenizi kontrol edin.')),
        );
      }
      return;
    }

    setState(() => _isCompleting = true);

    try {
      await _authViewModel.signUpWithEmail(
        email: email,
        password: password,
        fullName: _data.fullName ?? '',
      );

      final uid = _authViewModel.currentUserId;
      if (uid != null) {
        await _authViewModel.saveFullOnboardingProfile(uid: uid, data: _data);
      }

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt başarısız: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep > 1
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.secondary),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                  );
                  setState(() => _currentStep--);
                },
              )
            : null,
      ),
      body: _isCompleting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.secondary),
                  SizedBox(height: 16),
                  Text('Hesabınız oluşturuluyor...'),
                ],
              ),
            )
          : Column(
              children: [
                OnboardingProgressBar(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Adım 1: Temel Bilgiler
                      StepBasicInfo(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 2: Diyabet Profili
                      StepDiabetesProfile(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 3: Tedavi Bilgileri
                      StepTreatment(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 4: Glikoz İzleme
                      StepGlucoseMonitoring(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 5: Yaşam Tarzı ve Hedefler
                      StepLifestyleGoals(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 6: Sağlık Durumu (Kronik Hastalıklar & Alerjiler)
                      StepHealthConditions(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 7: Acil Durum ve Güvenlik
                      StepEmergencySecurity(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onNext: _goNext,
                      ),
                      // Adım 8: Bildirimler & Tamamla
                      StepNotificationsFinal(
                        data: _data,
                        onChanged: (d) => setState(() => _data = d),
                        onComplete: _completeOnboarding,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

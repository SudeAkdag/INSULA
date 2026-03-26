import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_input_card.dart';

class StepHealthConditions extends StatefulWidget {
  const StepHealthConditions({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepHealthConditions> createState() => _StepHealthConditionsState();
}

class _StepHealthConditionsState extends State<StepHealthConditions> {
  final _chronicController = TextEditingController();
  final _allergyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chronicController.text = widget.data.chronicDiseases ?? '';
    _allergyController.text = widget.data.allergies ?? '';
  }

  @override
  void dispose() {
    _chronicController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      chronicDiseases: _chronicController.text.trim().isEmpty
          ? null
          : _chronicController.text.trim(),
      allergies: _allergyController.text.trim().isEmpty
          ? null
          : _allergyController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sağlık Durumunuz',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kronik hastalık ve alerji bilgileriniz, önerilerimizi daha güvenli ve kişisel hale getirmemizi sağlar.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(18),
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.secondary, size: 18),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Bu alanlar isteğe bağlıdır. Boş bırakabilirsiniz.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          OnboardingInputCard(
            icon: Icons.local_hospital_outlined,
            label: 'Kronik Hastalıklarınız',
            child: TextField(
              controller: _chronicController,
              onChanged: (_) => _emit(),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Örn: Hipertansiyon, Kalp yetmezliği, Böbrek hastalığı...',
                hintMaxLines: 2,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          OnboardingInputCard(
            icon: Icons.warning_amber_outlined,
            label: 'Alerjileriniz',
            child: TextField(
              controller: _allergyController,
              onChanged: (_) => _emit(),
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Örn: Penisilin, Aspirin, Fındık, Süt ürünleri...',
                hintMaxLines: 2,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _emit();
                widget.onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
              ),
              child: const Text('Devam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

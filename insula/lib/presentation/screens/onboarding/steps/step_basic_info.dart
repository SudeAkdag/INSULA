import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_input_card.dart';

class StepBasicInfo extends StatefulWidget {
  const StepBasicInfo({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends State<StepBasicInfo> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  static const _genders = ['Erkek', 'Kadın', 'Diğer'];
  String _gender = 'Erkek';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.data.fullName ?? '';
    _emailController.text = widget.data.email ?? '';
    if (widget.data.age != null) _ageController.text = widget.data.age.toString();
    if (widget.data.heightCm != null) _heightController.text = widget.data.heightCm!.toInt().toString();
    if (widget.data.weightKg != null) _weightController.text = widget.data.weightKg!.toInt().toString();
    _gender = widget.data.gender ?? _genders[0];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _emit() {
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    widget.onChanged(widget.data.copyWith(
      fullName: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      age: age,
      heightCm: height,
      weightKg: weight,
      gender: _gender,
    ));
  }

  bool get _canNext {
    final name = _nameController.text.trim().isNotEmpty;
    final email = _emailController.text.trim().isNotEmpty;
    final age = int.tryParse(_ageController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());
    return name && email && (age != null && age > 0 && age < 120) &&
        (height != null && height > 0 && height < 250) &&
        (weight != null && weight > 0 && weight < 300);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Temel Bilgiler',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Size daha iyi hizmet verebilmemiz için birkaç bilgiye ihtiyacımız var.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          OnboardingInputCard(
            icon: Icons.person_outline,
            label: 'Ad Soyad',
            child: TextField(
              controller: _nameController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Adınız ve soyadınız',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          OnboardingInputCard(
            icon: Icons.email_outlined,
            label: 'E-posta',
            child: TextField(
              controller: _emailController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'ornek@email.com',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          OnboardingInputCard(
            icon: Icons.cake_outlined,
            label: 'Yaş',
            child: TextField(
              controller: _ageController,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Örn: 45',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: OnboardingInputCard(
                  icon: Icons.height,
                  label: 'Boy (cm)',
                  child: TextField(
                    controller: _heightController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: '175',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OnboardingInputCard(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Kilo (kg)',
                  child: TextField(
                    controller: _weightController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: '70',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Text(
            'Cinsiyet',
            style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: _genders.map((g) {
              final selected = _gender == g;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: g != _genders.last ? AppSpacing.sm : 0),
                  child: Material(
                    color: selected
                        ? AppColors.secondary.withAlpha(26)
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _gender = g;
                          _emit();
                        });
                      },
                      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: Text(
                            g,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? AppColors.secondary
                                  : AppColors.textSecLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canNext ? () { _emit(); widget.onNext(); } : null,
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

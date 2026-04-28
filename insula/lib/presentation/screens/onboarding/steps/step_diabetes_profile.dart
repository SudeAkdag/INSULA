import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_select_card.dart';

class StepDiabetesProfile extends StatefulWidget {
  const StepDiabetesProfile({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepDiabetesProfile> createState() => _StepDiabetesProfileState();
}

class _StepDiabetesProfileState extends State<StepDiabetesProfile> {
  static const _types = [
    ('Tip 1', 'İnsülin üretimi yok', Icons.medical_services_outlined),
    ('Tip 2', 'İnsülin direnci', Icons.health_and_safety_outlined),
    ('Gestasyonel', 'Gebelik diyabeti', Icons.pregnant_woman_outlined),
    ('Prediyabet', 'Risk aşaması', Icons.trending_up_outlined),
  ];

  String? _selectedType;
  final _yearController = TextEditingController();
  int? _diagnosisYear;
  String? _yearError;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.data.diabetesType;
    if (widget.data.diagnosisYear != null) {
      _yearController.text = widget.data.diagnosisYear.toString();
      _diagnosisYear = widget.data.diagnosisYear;
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      diabetesType: _selectedType,
      diagnosisYear: _diagnosisYear,
    ));
  }

  void _validateYear(String value) {
    final trimmed = value.trim();
    final year = int.tryParse(trimmed);
    final now = DateTime.now().year;
    setState(() {
      if (trimmed.isEmpty) {
        _yearError = 'Tanı yılı zorunludur';
      } else if (year == null || year < 1920 || year > now) {
        _yearError = 'Geçerli bir yıl girin (1920 – $now)';
      } else {
        _yearError = null;
      }
    });
  }

  bool get _canNext {
    if (_selectedType == null) return false;
    final year = int.tryParse(_yearController.text.trim());
    if (year == null) return false;
    final now = DateTime.now().year;
    return year >= 1920 && year <= now && _yearError == null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Diyabet Profili',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Diyabet tipinizi ve tanı yılınızı seçin.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ..._types.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OnboardingSelectCard(
                  label: t.$1,
                  subtitle: t.$2,
                  icon: t.$3,
                  selected: _selectedType == t.$1,
                  onTap: () {
                    setState(() {
                      _selectedType = t.$1;
                      _emit();
                    });
                  },
                ),
              )),

          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tanı yılı',
            style: AppTextStyles.label.copyWith(fontSize: 15, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _yearError != null ? Colors.red.shade50 : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              border: Border.all(
                color: _yearError != null ? Colors.red.shade400 : Colors.transparent,
                width: _yearError != null ? 1.5 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _yearError != null
                      ? Colors.red.withAlpha(20)
                      : AppColors.secondary.withAlpha(15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _yearController,
              onChanged: (v) {
                _validateYear(v);
                setState(() {
                  _diagnosisYear = int.tryParse(v.trim());
                  _emit();
                });
              },
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'Örn: ${DateTime.now().year - 5}',
                prefixIcon: Icon(Icons.calendar_today_outlined,
                    color: _yearError != null ? Colors.red.shade600 : AppColors.secondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          if (_yearError != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 4),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 13, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    _yearError!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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

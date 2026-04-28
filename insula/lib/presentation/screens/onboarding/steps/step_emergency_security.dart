import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_input_card.dart';

class StepEmergencySecurity extends StatefulWidget {
  const StepEmergencySecurity({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepEmergencySecurity> createState() => _StepEmergencySecurityState();
}

class _StepEmergencySecurityState extends State<StepEmergencySecurity> {
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  bool? _hasSevereHypo;

  String? _nameError;
  String? _phoneError;

  // Harf-only formatter (Türkçe)
  static final _nameRegex =
      RegExp(r'^[a-zA-ZçÇğĞıİöÖşŞüÜ]+(?: [a-zA-ZçÇğĞıİöÖşŞüÜ]+)*$');

  @override
  void initState() {
    super.initState();
    _contactNameController.text = widget.data.emergencyContactName ?? '';
    _contactPhoneController.text = widget.data.emergencyContactPhone ?? '';
    _hasSevereHypo = widget.data.hasSevereHypoglycemiaHistory;
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      emergencyContactName: _contactNameController.text.trim().isEmpty
          ? null
          : _contactNameController.text.trim(),
      emergencyContactPhone: _contactPhoneController.text.trim().isEmpty
          ? null
          : _contactPhoneController.text.trim(),
      hasSevereHypoglycemiaHistory: _hasSevereHypo,
    ));
  }

  void _validateContactName(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _nameError = null; // İsteğe bağlı alan
      } else if (!_nameRegex.hasMatch(trimmed)) {
        _nameError = 'Lütfen yalnızca harf kullanın';
      } else {
        _nameError = null;
      }
    });
  }

  void _validatePhone(String value) {
    final trimmed = value.trim();
    setState(() {
      if (trimmed.isEmpty) {
        _phoneError = null; // İsteğe bağlı alan
      } else if (trimmed.length < 10 || trimmed.length > 11) {
        _phoneError = 'Telefon 10–11 haneli olmalıdır';
      } else {
        _phoneError = null;
      }
    });
  }

  // Hata widget'ı
  Widget _errorText(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 13, color: Colors.red.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canNext => _hasSevereHypo != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Acil Durum ve Güvenlik',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Acil durumda aranacak kişi ve sağlık geçmişi bilgisi güvenliğiniz için önemlidir.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          OnboardingInputCard(
            icon: Icons.person_outline,
            label: 'Acil durum kişisi adı',
            hasError: _nameError != null,
            child: TextField(
              controller: _contactNameController,
              inputFormatters: [
                // Harf + boşluk izin ver
                FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-ZçÇğĞıİöÖşŞüÜ ]')),
                LengthLimitingTextInputFormatter(50),
              ],
              onChanged: (v) {
                _validateContactName(v);
                _emit();
              },
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: 'Ad Soyad',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          _errorText(_nameError),
          const SizedBox(height: AppSpacing.md),

          OnboardingInputCard(
            icon: Icons.phone_outlined,
            label: 'Acil durum telefonu',
            hasError: _phoneError != null,
            child: TextField(
              controller: _contactPhoneController,
              onChanged: (v) {
                _validatePhone(v);
                _emit();
              },
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                hintText: '05XX XXX XX XX',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 16),
              ),
            ),
          ),
          _errorText(_phoneError),

          const SizedBox(height: AppSpacing.xl),
          Text(
            'Şiddetli hipoglisemi geçmişiniz var mı?',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ChoiceChip(
                  label: 'Evet',
                  selected: _hasSevereHypo == true,
                  onTap: () {
                    setState(() {
                      _hasSevereHypo = true;
                      _emit();
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ChoiceChip(
                  label: 'Hayır',
                  selected: _hasSevereHypo == false,
                  onTap: () {
                    setState(() {
                      _hasSevereHypo = false;
                      _emit();
                    });
                  },
                ),
              ),
            ],
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
          const SizedBox(height: AppSpacing.md),

          // Skip butonu – validasyon atla
          SizedBox(
            height: 48,
            child: TextButton(
              onPressed: () {
                _emit();
                widget.onNext();
              },
              child: Text(
                'Sonra ekleyeceğim',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.secondary.withAlpha(26)
          : AppColors.surfaceLight,
      borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            border: Border.all(
              color: selected ? AppColors.secondary : Colors.grey.shade300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color:
                    selected ? AppColors.secondary : AppColors.textSecLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

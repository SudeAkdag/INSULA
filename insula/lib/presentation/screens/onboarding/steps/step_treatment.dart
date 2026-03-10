import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_select_card.dart';

class StepTreatment extends StatefulWidget {
  const StepTreatment({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepTreatment> createState() => _StepTreatmentState();
}

class _StepTreatmentState extends State<StepTreatment> {
  bool? _usesInsulin;
  String? _insulinType;
  String? _deliveryMethod;
  int _carbRatio = 10; // 1 ünite / 10g karb (varsayılan)

  static const _insulinTypes = ['Hızlı etkili', 'Uzun etkili', 'Karma'];
  static const _deliveryMethods = ['Kalem', 'Pompa'];

  @override
  void initState() {
    super.initState();
    _usesInsulin = widget.data.usesInsulin;
    _insulinType = widget.data.insulinType;
    _deliveryMethod = widget.data.insulinDeliveryMethod;
    _carbRatio = widget.data.carbRatio ?? 10;
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      usesInsulin: _usesInsulin,
      insulinType: _usesInsulin == true ? _insulinType : null,
      insulinDeliveryMethod: _usesInsulin == true ? _deliveryMethod : null,
      carbRatio: _usesInsulin == true ? _carbRatio : null,
    ));
  }

  bool get _canNext {
    if (_usesInsulin == null) return false;
    if (_usesInsulin == true) {
      return _insulinType != null && _deliveryMethod != null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tedavi Bilgileri',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'İnsülin kullanımı bilgisi, önerilerimizi kişiselleştirmemize yardımcı olur.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'İnsülin kullanıyor musunuz?',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ChoiceChip(
                  label: 'Evet',
                  selected: _usesInsulin == true,
                  onTap: () {
                    setState(() {
                      _usesInsulin = true;
                      _emit();
                    });
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ChoiceChip(
                  label: 'Hayır',
                  selected: _usesInsulin == false,
                  onTap: () {
                    setState(() {
                      _usesInsulin = false;
                      _insulinType = null;
                      _deliveryMethod = null;
                      _emit();
                    });
                  },
                ),
              ),
            ],
          ),

          if (_usesInsulin == true) ...[
            const SizedBox(height: AppSpacing.xl),
            Text(
              'İnsülin tipi',
              style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
            ),
            const SizedBox(height: AppSpacing.sm),
            ..._insulinTypes.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OnboardingSelectCard(
                    label: t,
                    selected: _insulinType == t,
                    onTap: () {
                      setState(() {
                        _insulinType = t;
                        _emit();
                      });
                    },
                  ),
                )),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Uygulama yöntemi',
              style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _deliveryMethods.map((m) {
                final selected = _deliveryMethod == m;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: m != _deliveryMethods.last ? AppSpacing.sm : 0),
                    child: OnboardingSelectCard(
                      label: m,
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _deliveryMethod = m;
                          _emit();
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Karbonhidrat oranı (1 ünite insülin / kaç g karb?)',
              style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [10, 12, 15, 20].map((ratio) {
                final selected = _carbRatio == ratio;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: OnboardingSelectCard(
                      label: '1:$ratio',
                      selected: selected,
                      onTap: () {
                        setState(() {
                          _carbRatio = ratio;
                          _emit();
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

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

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// İlaç ekleme formunda tek satırlık seçim alanı (tıklanınca bottom sheet vb. açılır).
/// Label + değer/hint gösteren kutu + suffix ikon.
class AddMedicationSelectField extends StatelessWidget {
  final String label;
  final String value;
  final String hint;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const AddMedicationSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
    this.suffixIcon,
    this.onTap,
  });

  static Widget dropdownIcon() {
    return Icon(Icons.arrow_drop_down, color: AppColors.accentTeal, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accentTeal,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: AppTextStyles.body.copyWith(
                      color: value.isEmpty ? Colors.grey : AppColors.textMainLight,
                    ),
                  ),
                ),
                if (suffixIcon != null) suffixIcon!,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

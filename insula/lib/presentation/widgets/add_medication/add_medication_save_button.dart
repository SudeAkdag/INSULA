import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// İlaç ekleme sayfasının altındaki tam genişlik "Kaydet" butonu.
class AddMedicationSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddMedicationSaveButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(Icons.save, color: AppColors.secondary, size: 22),
        label: Text(
          'Kaydet',
          style: AppTextStyles.body.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

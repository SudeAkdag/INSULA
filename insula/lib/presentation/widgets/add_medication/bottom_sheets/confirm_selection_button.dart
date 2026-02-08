import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Bottom sheet'lerdeki "SEÇİMİ ONAYLA" butonu: koyu teal arka plan, sarı yazı + check ikonu, kapsül form, gölge.
/// İlaç Türü ve Kullanım Zamanı sayfalarında aynı tasarım için kullanılır.
class ConfirmSelectionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ConfirmSelectionButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentTeal,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 12,
          shadowColor: AppColors.accentTeal.withOpacity(0.35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SEÇİMİ ONAYLA',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

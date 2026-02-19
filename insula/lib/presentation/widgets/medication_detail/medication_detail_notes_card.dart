import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// İlaç detay sayfasındaki notlar kartı: İlaç notlarını gösterir.
class MedicationDetailNotesCard extends StatelessWidget {
  final String notes;

  const MedicationDetailNotesCard({
    super.key,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'İlaç Notları',
            style: AppTextStyles.h1.copyWith(
              fontSize: 18,
              color: AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accentTeal.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.accentTeal,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notes.isEmpty
                        ? 'Bu ilaç için henüz not eklenmemiş.'
                        : notes,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.textMainLight,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

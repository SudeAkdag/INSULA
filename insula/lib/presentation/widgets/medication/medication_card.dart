import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'medication_card_data.dart';

/// Tek bir ilacı liste öğesi olarak gösteren kart.
/// İlaç adı, doz, saat ve alındı (checkbox) bilgisini içerir.
class MedicationCard extends StatelessWidget {
  final MedicationCardData medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: medication.iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              medication.icon,
              color: medication.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      medication.dosage,
                      style: AppTextStyles.label.copyWith(
                        color: medication.dosageColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      ' • +${medication.time}',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: medication.isTaken
                  ? AppColors.secondary
                  : Colors.transparent,
              border: Border.all(
                color: medication.isTaken
                    ? AppColors.secondary
                    : AppColors.textSecLight.withOpacity(0.5),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: medication.isTaken
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

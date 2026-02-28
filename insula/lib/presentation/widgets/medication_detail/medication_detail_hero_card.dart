import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// İlaç detay sayfasındaki hero bölümü: İlaç ikonu, adı, türü, dozaj ve sıklık bilgilerini gösterir.
class MedicationDetailHeroCard extends StatelessWidget {
  final String name;
  final String medicationType;
  final String dosage;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;

  const MedicationDetailHeroCard({
    super.key,
    required this.name,
    required this.medicationType,
    required this.dosage,
    required this.frequency,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.accentTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.accentTeal.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.medication,
              size: 48,
              color: AppColors.accentTeal,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.h1.copyWith(
                    fontSize: 24,
                    color: AppColors.textMainLight,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medication,
                          size: 18,
                          color: AppColors.accentTeal,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          medicationType == 'Tür Seçiniz' ? 'Tablet' : medicationType,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.accentTeal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (dosage.isNotEmpty)
                      Text(
                        '•',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecLight,
                        ),
                      ),
                    if (dosage.isNotEmpty)
                      Text(
                        dosage,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_repeat,
                      size: 18,
                      color: AppColors.textSecLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      frequency,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (startDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppColors.accentTeal.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${startDate!.day.toString().padLeft(2, '0')}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.year}' +
                        (endDate != null ? ' - ${endDate!.day.toString().padLeft(2, '0')}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.year}' : ' (Sürekli)'),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecLight.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

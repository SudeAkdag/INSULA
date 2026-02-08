import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'calendar_day_strip.dart';

/// İlaç sayfasının üstündeki günlük ilerleme kartı.
/// Takvim gün şeridini, "Günlük İlerleme" başlığını, yüzde etiketini,
/// progress bar'ı ve "X/Y Doz Alındı / Sonraki doz" satırını gösterir.
class MedicationProgressCard extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final double progress;
  final String takenLabel;
  final String nextDoseLabel;

  const MedicationProgressCard({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.progress = 0.75,
    this.takenLabel = '3/4 Doz Alındı',
    this.nextDoseLabel = "Sonraki doz: 20:00'de",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarDayStrip(
            selectedDate: selectedDate,
            onDateSelected: onDateSelected,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Günlük İlerleme',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.backgroundLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(takenLabel, style: AppTextStyles.label),
              Text(nextDoseLabel, style: AppTextStyles.label),
            ],
          ),
        ],
      ),
    );
  }
}

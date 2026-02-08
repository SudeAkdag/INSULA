import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'add_medication_select_field.dart';

/// İlaç ekleme sayfasında tek bir doz kartı (1. DOZ / 2. DOZ).
/// SAAT, MİKTAR, KULLANIM ZAMANI, DURUM alanları.
class AddMedicationDoseCard extends StatelessWidget {
  final String title;
  final TimeOfDay time;
  final VoidCallback onTimeTap;
  final String amount;
  final String usageTime;
  final String condition;
  final VoidCallback onAmountTap;
  final VoidCallback onUsageTimeTap;
  final VoidCallback onConditionTap;

  const AddMedicationDoseCard({
    super.key,
    required this.title,
    required this.time,
    required this.onTimeTap,
    required this.amount,
    required this.usageTime,
    required this.condition,
    required this.onAmountTap,
    required this.onUsageTimeTap,
    required this.onConditionTap,
  });

  static const double _cardRadius = 16;

  static String formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accentTeal,
                ),
              ),
              IconButton(
                icon: Icon(Icons.access_time, color: AppColors.accentTeal, size: 20),
                onPressed: onTimeTap,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AddMedicationSelectField(
                  label: 'SAAT',
                  value: formatTime(time),
                  hint: '08:00 AM',
                  suffixIcon: Icon(Icons.access_time, color: AppColors.accentTeal, size: 18),
                  onTap: onTimeTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AddMedicationSelectField(
                  label: 'MİKTAR',
                  value: amount,
                  hint: '1 Tablet',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onAmountTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AddMedicationSelectField(
                  label: 'KULLANIM ZAMANI',
                  value: usageTime,
                  hint: 'Sabah',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onUsageTimeTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AddMedicationSelectField(
                  label: 'DURUM',
                  value: condition,
                  hint: 'Aç',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onConditionTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

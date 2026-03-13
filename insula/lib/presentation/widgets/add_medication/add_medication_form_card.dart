import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'add_medication_select_field.dart';

/// İlaç ekleme sayfasındaki ilk kart: İlaç Adı, İlaç Türü, Dozaj, Sıklık.
class AddMedicationFormCard extends StatelessWidget {
  final TextEditingController nameController;
  final String medicationType;
  final String dosage;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onTypeTap;
  final VoidCallback onDosageTap;
  final VoidCallback onFrequencyTap;
  final VoidCallback onStartDateTap;
  final VoidCallback onEndDateTap;
  final String? Function(String?)? nameValidator;

  const AddMedicationFormCard({
    super.key,
    required this.nameController,
    required this.medicationType,
    required this.dosage,
    required this.frequency,
    this.startDate,
    this.endDate,
    required this.onTypeTap,
    required this.onDosageTap,
    required this.onFrequencyTap,
    required this.onStartDateTap,
    required this.onEndDateTap,
    this.nameValidator,
  });

  static const double _cardRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: const Border(
          left: BorderSide(color: AppColors.accentTeal, width: 6),
        ),
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
          _buildLabel('İlaç Adı'),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Örn: Metformin',
              hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: Icon(Icons.search, color: AppColors.accentTeal, size: 22),
            ),
            style: AppTextStyles.body,
            validator: nameValidator,
          ),
          const SizedBox(height: 6),
          AddMedicationSelectField(
            label: 'İlaç Türü',
            value: medicationType == 'Tür Seçiniz' ? '' : medicationType,
            hint: 'Tür Seçiniz',
            suffixIcon: AddMedicationSelectField.dropdownIcon(),
            onTap: onTypeTap,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Sıklık',
                  value: frequency,
                  hint: 'Günde 2 kez',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onFrequencyTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Dozaj',
                  value: dosage,
                  hint: '10 mg',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onDosageTap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Başlangıç',
                  value: startDate != null ? '${startDate!.day.toString().padLeft(2, '0')}.${startDate!.month.toString().padLeft(2, '0')}.${startDate!.year}' : '',
                  hint: 'Tarih Seç',
                  suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppColors.accentTeal),
                  onTap: onStartDateTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Bitiş',
                  value: endDate != null ? '${endDate!.day.toString().padLeft(2, '0')}.${endDate!.month.toString().padLeft(2, '0')}.${endDate!.year}' : 'Belirsiz',
                  hint: 'Tarih Seç',
                  suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppColors.accentTeal),
                  onTap: onEndDateTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.accentTeal,
        ),
      ),
    );
  }
}

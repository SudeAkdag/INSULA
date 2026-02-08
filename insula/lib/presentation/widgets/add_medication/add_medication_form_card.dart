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
  final VoidCallback onTypeTap;
  final VoidCallback onDosageTap;
  final VoidCallback onFrequencyTap;
  final String? Function(String?)? nameValidator;

  const AddMedicationFormCard({
    super.key,
    required this.nameController,
    required this.medicationType,
    required this.dosage,
    required this.frequency,
    required this.onTypeTap,
    required this.onDosageTap,
    required this.onFrequencyTap,
    this.nameValidator,
  });

  static const double _cardRadius = 16;

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
          _buildLabel('İlaç Adı'),
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Örn: Metformin',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              suffixIcon: Icon(Icons.search, color: AppColors.accentTeal, size: 22),
            ),
            validator: nameValidator,
          ),
          const SizedBox(height: 16),
          AddMedicationSelectField(
            label: 'İlaç Türü',
            value: medicationType == 'Tür Seçiniz' ? '' : medicationType,
            hint: 'Tür Seçiniz',
            suffixIcon: AddMedicationSelectField.dropdownIcon(),
            onTap: onTypeTap,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Dozaj',
                  value: dosage,
                  hint: '10 mg',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onDosageTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AddMedicationSelectField(
                  label: 'Sıklık',
                  value: frequency,
                  hint: 'Günde 2 kez',
                  suffixIcon: AddMedicationSelectField.dropdownIcon(),
                  onTap: onFrequencyTap,
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
      padding: const EdgeInsets.only(bottom: 8),
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

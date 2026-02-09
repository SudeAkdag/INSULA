import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'medication_card.dart';
import 'medication_card_data.dart';

/// Sabah / Öğle / Akşam gibi bir zaman dilimindeki ilaçları gruplayan bölüm.
/// Başlık ve altında [MedicationCard] listesini gösterir.
class MedicationSection extends StatelessWidget {
  final String title;
  final List<MedicationCardData> medications;
  final ValueChanged<MedicationCardData>? onToggle;

  const MedicationSection({
    super.key,
    required this.title,
    required this.medications,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: AppColors.accentTeal,
          ),
        ),
        const SizedBox(height: 12),
        ...medications.map((med) => MedicationCard(medication: med, onToggle: onToggle)),
      ],
    );
  }
}

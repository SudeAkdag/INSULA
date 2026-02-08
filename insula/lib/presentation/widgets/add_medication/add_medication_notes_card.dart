import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// İlaç ekleme sayfasındaki Notlar alanı (çok satırlı metin, beyaz kart).
class AddMedicationNotesCard extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const AddMedicationNotesCard({
    super.key,
    required this.controller,
    this.hint = 'Örn: Yemekten hemen sonra bol su ile alınmalı...',
  });

  static const double _cardRadius = 16;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Notlar',
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accentTeal,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
          child: TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration.collapsed(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}

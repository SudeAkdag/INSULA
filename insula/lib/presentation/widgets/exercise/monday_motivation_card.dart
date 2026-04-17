import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class MondayMotivationCard extends StatelessWidget {
  const MondayMotivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, // Alttaki kartla aynı renk
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text("✨", style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Bugün hedeflerine ulaşmak için harika bir gün.",
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
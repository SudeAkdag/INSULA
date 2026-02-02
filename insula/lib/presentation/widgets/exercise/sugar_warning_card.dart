import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SugarWarningCard extends StatelessWidget {
  const SugarWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withAlpha(20), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medical_services_outlined, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Şeker Kontrolü",
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                ),
                Text(
                  "Yüksek yoğunluklu egzersiz sonrası kan şekerinizi ölçmeyi unutmayın.",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
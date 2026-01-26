import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart'; //
import '/core/theme/app_text_styles.dart'; //
import '/core/theme/app_constants.dart'; //

class NutritionSummaryCard extends StatelessWidget {
  final double currentCarbs;
  final int carbGoal;
  final double sugar;
  final double fiber;

  const NutritionSummaryCard({
    super.key,
    required this.currentCarbs,
    required this.carbGoal,
    required this.sugar,
    required this.fiber,
  });

  @override
  Widget build(BuildContext context) {
    // İlerleme yüzdesini hesapla
    double progress = (currentCarbs / carbGoal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, //
        borderRadius: BorderRadius.circular(AppRadius.lg), //
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TOPLAM KARBONHİDRAT",
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currentCarbs.toInt().toString(),
                style: AppTextStyles.glucoseValue.copyWith(fontSize: 40), //
              ),
              const SizedBox(width: 4),
              Text(
                "/ ${carbGoal}g", //
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary.withOpacity(0.4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar Yapısı
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary, //
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Şeker ve Lif Bilgileri
          Row(
            children: [
              _buildNutrientInfo("Şeker", "${sugar.toInt()}g", AppColors.tertiary),
              const SizedBox(width: 32),
              _buildNutrientInfo("Lif", "${fiber.toInt()}g", AppColors.secondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(
          value,
          style: AppTextStyles.h1.copyWith(
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }
}
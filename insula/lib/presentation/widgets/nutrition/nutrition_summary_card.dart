import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';

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
    double progress = (currentCarbs / carbGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.5), // Tasarımdaki daha yumuşak köşe
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack( // Arka plan detayı için Stack kullanıyoruz
        children: [
          // Arka Plandaki Görsel Detayı (Sağ alt köşedeki tabağı simüle eder)
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.05,
              child: Icon(Icons.restaurant, size: 140, color: AppColors.secondary),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TOPLAM KARBONHİDRAT",
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.secondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentCarbs.toInt().toString(),
                      style: AppTextStyles.glucoseValue.copyWith(fontSize: 48, height: 1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "/ ${carbGoal}g",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Progress Bar
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 8)
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Şeker, Lif ve Buton Satırı
                Row(
                  children: [
                    _buildNutrientInfo("Şeker", "${sugar.toInt()}g", AppColors.tertiary),
                    const SizedBox(width: 24),
                    _buildNutrientInfo("Lif", "${fiber.toInt()}g", AppColors.secondary),
                  ]
                ),
                    const SizedBox(height: 20),
                    // Tasarımdaki "Raporu Gör" Butonu
                    SizedBox(
                      width: 140, // Tasarımdaki genişlik
                      child: ElevatedButton(
                        onPressed: () {}, // Fonksiyon daha sonra eklenecek
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const StadiumBorder(), // Oval yapı
                          elevation: 0,
                        ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("Raporu Gör", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
        Text(value, style: AppTextStyles.h1.copyWith(fontSize: 18, color: color)),
      ],
    );
  }
}
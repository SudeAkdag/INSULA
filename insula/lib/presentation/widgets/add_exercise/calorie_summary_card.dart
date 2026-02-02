import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart'; //

class CalorieSummaryCard extends StatelessWidget {
  final int calories;
  final String intensity;

  const CalorieSummaryCard({
    super.key,
    required this.calories,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Arka plan için primary (sarı) renginin çok açık bir tonu
        color: AppColors.primary.withValues(alpha: 0.1), 
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            // İkon arka planı için ana sarı renk
            backgroundColor: AppColors.primary,
            radius: 24,
            child: const Icon(
              Icons.local_fire_department, 
              color: Colors.white, 
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded( 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "TAHMİNİ KALORİ",
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    // Gri metinler için ikincil metin rengi
                    color: AppColors.textSecLight, 
                  ),
                ),
                Text(
                  "$calories kcal",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    // Değer vurgusu için ana koyu renk
                    color: AppColors.secondary, 
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),

          // Sağdaki Yoğunluk Kutusu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // Kutu içi için temiz beyaz/açık yüzey rengi
              color: AppColors.surfaceLight, 
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              intensity,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
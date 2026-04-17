import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ExerciseComparisonText extends StatelessWidget {
  final int difference;

  const ExerciseComparisonText({super.key, required this.difference});

  @override
  Widget build(BuildContext context) {
    if (difference == 0) return const SizedBox.shrink();

    final bool isIncrease = difference > 0;
    final String statusText = isIncrease ? "fazla" : "az";
    final IconData statusIcon = isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    
    // Artış/Azalışa göre ana renk seçimi
    final Color baseColor = isIncrease ? AppColors.secondary : AppColors.accent;

    return Container(
      // Genişliği yaymak için double.infinity veya dışarıdan gelen kısıtlamayı kullanır
      width: double.infinity, 
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        // Arka planı çok hafif (0.1) yaparak metni ve ikonu ön plana çıkardık
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: baseColor.withValues(alpha: 0.2), // Hafif bir çerçeve derinlik katar
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // İkon alanı için bir konteyner (daha şık durması için)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              size: 20,
              color: baseColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Düne göre ${difference.abs()} kalori daha $statusText yaktınız.",
              style: TextStyle(
                color: baseColor, // Yazı rengi artık dinamik
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
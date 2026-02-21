import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/exercise_service.dart';

class ExerciseChart extends StatelessWidget {
  const ExerciseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
    // Dart'ta Pazartesi 1, Pazar 7'dir. Index için 1 çıkarıyoruz.
    final int todayIndex = DateTime.now().weekday - 1; 

    return FutureBuilder<List<double>>(
      future: ExerciseService().getWeeklyCalories(),
      builder: (context, snapshot) {
        // Veri yüklenirken veya hata durumunda boş liste göster
        final List<double> weeklyData = snapshot.data ?? List.filled(7, 0.0);
        final bool hasData = weeklyData.any((value) => value > 0);

        // Bir önceki güne göre farkı hesaplayan fonksiyon
        String getDifference() {
          if (todayIndex == 0 || weeklyData.isEmpty) return "0";
          double diff = weeklyData[todayIndex] - weeklyData[todayIndex - 1];
          return diff >= 0 ? "+${diff.toInt()}" : "${diff.toInt()}";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık ve Sağ Üstteki Fark Kutusu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Haftalık Yakılan Kalori",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                if (hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getDifference(),
                      style: const TextStyle(
                        color: AppColors.secondary, 
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Grafik Gövdesi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: !hasData 
                ? const SizedBox(
                    height: 150, 
                    child: Center(child: Text("Bu hafta henüz veri yok", style: TextStyle(color: Colors.grey, fontSize: 12)))
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(weeklyData.length, (index) {
                      // Grafik yüksekliğini belirlemek için en yüksek değeri buluyoruz (scaling)
                      double maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
                      if (maxVal < 100) maxVal = 100; // Çok küçük değerlerde grafik sönük kalmasın

                      return Column(
                        children: [
                          // Sütun Üzerindeki Değer
                          Text(
                            "${weeklyData[index].toInt()}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: index == todayIndex ? AppColors.secondary : AppColors.textSecLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Grafik Sütunu
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 14,
                            // Dinamik yükseklik: Mevcut kalori / Max Kalori * Grafik Alanı (100px)
                            height: (weeklyData[index] / maxVal) * 100, 
                            decoration: BoxDecoration(
                              color: index == todayIndex ? AppColors.secondary : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Gün İsmi
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 12, 
                              color: index == todayIndex ? AppColors.secondary : AppColors.textSecLight,
                              fontWeight: index == todayIndex ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
            ),
          ],
        );
      },
    );
  }
}
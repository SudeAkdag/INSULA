import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseChart extends StatelessWidget {
  const ExerciseChart({super.key});

  // Örnek veri seti (Daha sonra SQL'den gelecek)
  final List<double> weeklyData = const [100, 200, 150, 300, 120, 180, 140];
  final int todayIndex = 3; // Bugünün Perşembe olduğunu varsayalım

  // Bir önceki güne göre farkı hesaplayan fonksiyon
  String getDifference() {
    if (todayIndex == 0) return "0";
    double diff = weeklyData[todayIndex] - weeklyData[todayIndex - 1];
    return diff >= 0 ? "+${diff.toInt()}" : "${diff.toInt()}";
  }

  @override
  Widget build(BuildContext context) {
    final List<String> days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                getDifference(),
                style: const TextStyle(
                  color:AppColors.secondary, 
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklyData.length, (index) {
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
                  Container(
                    width: 14,
                    height: (weeklyData[index] / 4), // Yüksekliği veriye göre oranladık
                    decoration: BoxDecoration(
                      color: index == todayIndex ? AppColors.secondary : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Gün İsmi
                  Text(
                    days[index],
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecLight),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/services/exercise_service.dart';
import '../../../data/models/exercise_model.dart';

class ExerciseChart extends StatelessWidget {
  // constructor'daki zorunlu difference parametresini kaldırdım çünkü StreamBuilder zaten hesaplıyor.
  const ExerciseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];
    final DateTime now = DateTime.now();
    final int todayIndex = now.weekday - 1; 

    return StreamBuilder<List<ExerciseModel>>(
      stream: ExerciseService().getExercises(),
      builder: (context, snapshot) {
        // 1. VERİYİ HAFTALIK KALORİ LİSTESİNE DÖNÜŞTÜR (Anlık)
        List<double> weeklyData = List.filled(7, 0.0);
        double yesterdayCalories = 0.0; // Pzt günü için Pazar verisini tutacak
        
        if (snapshot.hasData) {
          // Bu haftanın Pazartesi gününü bul
          DateTime startOfWeek = DateTime(now.year, now.month, now.day)
              .subtract(Duration(days: now.weekday - 1));
          
          // Dünün tarihini bul (Kıyaslama için)
          DateTime yesterdayDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

          for (var ex in snapshot.data!) {
            // Grafik için haftalık veriyi doldur
            if (ex.isCompleted && ex.date.isAfter(startOfWeek.subtract(const Duration(seconds: 1)))) {
              int dayIdx = ex.date.weekday - 1;
              if (dayIdx >= 0 && dayIdx < 7) {
                weeklyData[dayIdx] += ex.estimatedCalories.toDouble();
              }
            }
            
            // Dünün toplam kalorisini bul (Pazartesi olsa bile dünü bulur)
            if (ex.isCompleted && 
                ex.date.year == yesterdayDate.year && 
                ex.date.month == yesterdayDate.month && 
                ex.date.day == yesterdayDate.day) {
              yesterdayCalories += ex.estimatedCalories.toDouble();
            }
          }
        }

        final bool hasData = weeklyData.any((value) => value > 0);

        String getDifference() {
          if (weeklyData.isEmpty) return "0";
          double todayVal = weeklyData[todayIndex];
          if (todayVal == 0) return "0";

          // ARTIK Pzt kısıtlaması yok, alt kutu ne diyorsa bu da onu diyecek:
          double diff = todayVal - yesterdayCalories;
          
          if (diff == 0) return "0";
          return diff > 0 ? "+${diff.toInt()}" : "${diff.toInt()}";
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      color: AppColors.primary.withOpacity(0.1),
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
                    children: List.generate(7, (index) {
                      double val = weeklyData[index];
                      double maxVal = weeklyData.reduce((a, b) => a > b ? a : b);
                      if (maxVal < 100) maxVal = 100;

                      return Column(
                        children: [
                          Text(
                            "${val.toInt()}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: index == todayIndex ? AppColors.secondary : AppColors.textSecLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 14,
                            height: ((val / maxVal) * 100).clamp(4.0, 100.0), 
                            decoration: BoxDecoration(
                              color: index == todayIndex ? AppColors.secondary : AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
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
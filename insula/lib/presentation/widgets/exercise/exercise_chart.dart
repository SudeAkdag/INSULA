// lib/presentation/widgets/exercise_chart.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseChart extends StatelessWidget {
  const ExerciseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<double> weeklyData = [0.4, 0.7, 0.5, 0.9, 0.3, 0.6, 0.4];
    final List<String> days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(weeklyData.length, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 100 * weeklyData[index],
                decoration: BoxDecoration(
              
                  color: index == 3 
                      ? AppColors.secondary 
                      : AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(fontSize: 10, color: AppColors.textSecLight),
              ),
            ],
          );
        }),
      ),
    );
  }
}
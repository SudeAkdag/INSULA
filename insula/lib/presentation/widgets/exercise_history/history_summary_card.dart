import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/exercise_service.dart';

class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: ExerciseService().getMonthlyComparison(),
      builder: (context, snapshot) {
        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final stats = snapshot.data ?? {'count': 0, 'calories': 0, 'avgDrop': 0, 'difference': 0.0};
        final double diff = stats['difference'];

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.backgroundLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "BU AY ÖZETİ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                  ),
                  Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem("Egzersiz", isLoading ? "..." : "${stats['count']}"),
                  _buildStatItem("Kalori", isLoading ? "..." : "${stats['calories']}"),
                  
                  // Karşılaştırma Göstergesi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Önceki Aya Göre", style: TextStyle(fontSize: 9, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            diff >= 0 ? Icons.trending_up : Icons.trending_down,
                            color: diff >= 0 ? Colors.green : Colors.red,
                            size: 14,
                          ),
                          Text(
                            " %${diff.abs().toStringAsFixed(1)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: diff >= 0 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 32, color: AppColors.backgroundLight),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ortalama Şeker Düşüşü",
                    style: TextStyle(fontSize: 12, color: AppColors.textSecLight),
                  ),
                  Text(
                    isLoading ? "..." : "${stats['avgDrop']} mg/dL",
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecLight)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondary)),
      ],
    );
  }
}
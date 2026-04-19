import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/services/exercise_service.dart';

class HistorySummaryCard extends StatefulWidget {
  const HistorySummaryCard({super.key});

  @override
  State<HistorySummaryCard> createState() => _HistorySummaryCardState();
}

class _HistorySummaryCardState extends State<HistorySummaryCard> {
  // Future'ı burada tanımlamak, her build sırasında tekrar çalışmasını önler
  late Future<Map<String, dynamic>> _monthlyData;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _monthlyData = ExerciseService().getMonthlyComparison();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _monthlyData,
      builder: (context, snapshot) {
        // Hata durumunu kontrol et
        if (snapshot.hasError) {
           return const Center(child: Text("Veri alınamadı"));
        }

        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        
        // Veri geldiyse al, gelmediyse varsayılan değerleri kullan
        final stats = snapshot.data ?? {'count': 0, 'totalCalories': 0.0, 'difference': 0.0};
        
        final double calories = (stats['totalCalories'] as num).toDouble();
        final double diff = (stats['difference'] as num).toDouble();
        final int count = stats['count'] as int;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.backgroundLight),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "BU AY ÖZETİ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                  ),
                  GestureDetector(
                    onTap: _refreshData, // Dokununca veriyi yenileme özelliği
                    child: const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem("Egzersiz", isLoading ? "..." : "$count"),
                  _buildStatItem(
                    "Kalori", 
                    isLoading ? "..." : "${calories.toStringAsFixed(1)} kcal"
                  ),
                  
                  // Karşılaştırma Göstergesi
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Önceki Aya Göre", style: TextStyle(fontSize: 10, color: AppColors.textSecLight)),
                      const SizedBox(height: 4),
                      if (isLoading)
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      else
                        Row(
                          children: [
                            Icon(
                              diff >= 0 ? Icons.trending_up : Icons.trending_down,
                              color: diff >= 0 ? Colors.green : Colors.red,
                              size: 16,
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
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.secondary)),
      ],
    );
  }
}


import 'package:flutter/material.dart';
import 'package:insula/presentation/screens/reports_screen.dart';
import '../../../../core/theme/app_colors.dart';

// --- BU AY ÖZETİ KARTI (Görseldeki büyük beyaz kart) ---
class MonthlySummaryCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const MonthlySummaryCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          // Üst Kısım: Veriler
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "BU AY ÖZETİ",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Icon(Icons.calendar_month, color: Colors.orange, size: 20),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem("Egzersiz", stats['count'].toString()),
                    _buildStatItem("Kalori", "${stats['totalCalories'].toInt()} kcal"),
                    _buildStatItem(
                      "Önceki Aya Göre",
                      "%${stats['difference'].toStringAsFixed(1)}",
                      isTrend: true,
                      trendUp: stats['difference'] >= 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ayırıcı Çizgi
          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
          
          // Alt Kısım: Rapor Butonu
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportsScreen(initialTab: 2)),
              );
            },
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Detaylı Raporu Gör",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isTrend = false, bool trendUp = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          children: [
            if (isTrend)
              Icon(
                trendUp ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: trendUp ? Colors.green : Colors.red,
              ),
            if (isTrend) const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isTrend ? (trendUp ? Colors.green : Colors.red) : AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// --- GEÇMİŞ AKTİVİTE SATIRI (Tile) ---
class HistoryActivityTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String time;
  final String duration;
  final String calories;
  final String? glucoseBefore;
  final String? glucoseAfter;
  final bool isDecrease;

  const HistoryActivityTile({
    super.key,
    required this.title,
    required this.icon,
    required this.time,
    required this.duration,
    required this.calories,
    this.glucoseBefore,
    this.glucoseAfter,
    required this.isDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBoth = (glucoseBefore != null && glucoseBefore != "null") && 
                         (glucoseAfter != null && glucoseAfter != "null");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportsScreen(initialTab: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  child: Icon(icon, color: AppColors.secondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary, fontSize: 16)),
                      Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textSecLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasBoth 
                        ? (isDecrease ? AppColors.secondary.withOpacity(0.08) : AppColors.tertiary.withOpacity(0.08))
                        : AppColors.secondary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text("KAN ŞEKERİ", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: hasBoth ? (isDecrease ? AppColors.secondary : AppColors.tertiary) : AppColors.secondary)),
                      Text(hasBoth ? "$glucoseBefore ➔ $glucoseAfter" : "${glucoseBefore ?? '...'} - ${glucoseAfter ?? '...'}",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: hasBoth ? (isDecrease ? AppColors.secondary : AppColors.tertiary) : AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(height: 1, color: Color(0xFFF5F5F5)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoItem(Icons.timer_outlined, duration),
                Container(height: 15, width: 1, color: Colors.grey.shade200),
                _infoItem(Icons.local_fire_department_outlined, calories),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/exercise_service.dart'; // Yolunu projene göre düzenle
import '../../../logic/viewmodels/nutrition_viewmodel.dart'; // Yolunu projene göre düzenle
import '../../../presentation/screens/reports_screen.dart';

class DailySummaryGrid extends StatefulWidget {
  const DailySummaryGrid({super.key});

  @override
  State<DailySummaryGrid> createState() => _DailySummaryGridState();
}

class _DailySummaryGridState extends State<DailySummaryGrid> {
  // Modelimizi sayfa açıldığında kendi içinde oluşturuyoruz
  late final NutritionViewModel _nutritionVM;

  @override
  void initState() {
    super.initState();
    // Model başlatılıyor. İçindeki loadMeals fonksiyonu otomatik çalışacak.
    _nutritionVM = NutritionViewModel();
  }

  @override
  void dispose() {
    _nutritionVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Günlük Özet",
            style: AppTextStyles.h1.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),

          // Egzersiz verisini asenkron çekmek için FutureBuilder kullanıyoruz
         FutureBuilder<Map<String, dynamic>>(
  future: ExerciseService().getTodayStats(),
  builder: (context, snapshot) {
    // ✅ Değişkenleri double yapıyoruz
    double totalCalories = 0.0;
    int totalMinutes = 0; // Dakika küsuratlı olabilir diyorsan double kalsın

    if (snapshot.hasData && snapshot.data != null) {
      // ✅ En güvenli dönüşüm yolu: 'as num' üzerinden gitmek
      totalCalories = (snapshot.data!['totalCalories'] as num? ?? 0.0).toDouble();
      totalMinutes = (snapshot.data!['totalMinutes'] as num? ?? 0.0).toInt();
    }

              return Column(
                children: [
                  Row(
                    children: [
                      // 1. Kutu: Egzersiz
                      Expanded(
                        child: _ExerciseStatCard(
                          totalCalories: totalCalories,
                          totalMinutes: totalMinutes,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 2. Kutu: Beslenme (Provider yerine ListenableBuilder kullanıyoruz)
                      Expanded(
                        child: ListenableBuilder(
                          listenable: _nutritionVM,
                          builder: (context, child) {
                            return _NutritionStatCard(
                              carbs: _nutritionVM.totalCarbs,
                              fat: _nutritionVM.totalFat,
                              protein: _nutritionVM.totalProtein,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _ReportsCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── 1. Egzersiz Kutusu ───────────────────────────────────────────────────
class _ExerciseStatCard extends StatelessWidget {
  final double totalCalories;
  final int totalMinutes;

  const _ExerciseStatCard({
    required this.totalCalories,
    required this.totalMinutes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.fitness_center,
                    color: Colors.orange.shade400, size: 20),
              ),
              const SizedBox(width: 8),
              Text("Egzersiz",
                  style: AppTextStyles.label.copyWith(fontSize: 14)),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: totalCalories.toStringAsFixed(2),
                  style: AppTextStyles.h1.copyWith(fontSize: 22),
                ),
                TextSpan(
                  text: " kcal",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$totalMinutes",
                  style: AppTextStyles.h1.copyWith(fontSize: 18),
                ),
                TextSpan(
                  text: " dk",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 12,
                    color: AppColors.textSecLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. Beslenme Kutusu (Dairesel Grafik) ─────────────────────────────────
class _NutritionStatCard extends StatelessWidget {
  final double carbs;
  final double fat;
  final double protein;

  const _NutritionStatCard({
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    final total = carbs + fat + protein;
    final carbRatio = total > 0 ? carbs / total : 0.0;
    final fatRatio = total > 0 ? fat / total : 0.0;
    final proteinRatio = total > 0 ? protein / total : 0.0;

    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.restaurant,
                    color: Colors.green.shade400, size: 20),
              ),
              const SizedBox(width: 8),
              Text("Beslenme",
                  style: AppTextStyles.label.copyWith(fontSize: 14)),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: _MacroPieChartPainter(
                    carbRatio: carbRatio,
                    fatRatio: fatRatio,
                    proteinRatio: proteinRatio,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMacroRow(AppColors.tertiary, "Karb", carbs.toInt()),
                    const SizedBox(height: 2),
                    _buildMacroRow(AppColors.secondary, "Yağ", fat.toInt()),
                    const SizedBox(height: 2),
                    _buildMacroRow(AppColors.primary, "Pro", protein.toInt()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(Color color, String label, int value) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          "$label:",
          style: AppTextStyles.body
              .copyWith(fontSize: 10, color: AppColors.textSecLight),
        ),
        const Spacer(),
        Text(
          "${value}g",
          style: AppTextStyles.body
              .copyWith(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// ─── Dairesel Grafik İçin Custom Painter ──────────────────────────────────
class _MacroPieChartPainter extends CustomPainter {
  final double carbRatio;
  final double fatRatio;
  final double proteinRatio;

  _MacroPieChartPainter({
    required this.carbRatio,
    required this.fatRatio,
    required this.proteinRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - paint.strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (carbRatio == 0 && fatRatio == 0 && proteinRatio == 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    double startAngle = -3.14159 / 2;

    if (carbRatio > 0) {
      final sweepAngle = carbRatio * 2 * 3.14159;
      paint.color = AppColors.tertiary;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    if (fatRatio > 0) {
      final sweepAngle = fatRatio * 2 * 3.14159;
      paint.color = AppColors.secondary;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    if (proteinRatio > 0) {
      final sweepAngle = proteinRatio * 2 * 3.14159;
      paint.color = AppColors.primary;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ─── 3. Raporlar Kutusu (Birleştirilmiş Tam Genişlik) ─────────────────────
class _ReportsCard extends StatelessWidget {
  const _ReportsCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👇 EKSİK OLAN VE YÖNLENDİRMEYİ YAPAN KISIM BURASI 👇
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReportsScreen(),
          ),
        );
      },
      // 👆 ----------------------------------------------- 👆
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.backgroundLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.analytics_outlined,
                      color: Colors.purple.shade400, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Raporlar",
                      style: AppTextStyles.h1.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Detaylı analizleri görüntüle",
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecLight),
          ],
        ),
      ),
    );
  }
}

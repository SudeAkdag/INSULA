import 'package:flutter/material.dart';
import 'package:insula/presentation/screens/add_exercise_screen.dart';
import 'package:insula/presentation/screens/exercise_history_screen.dart';
import 'package:insula/data/services/exercise_service.dart';
import 'package:insula/presentation/widgets/exercise/exercise_comparison_text.dart';
import 'package:insula/presentation/widgets/exercise/monday_motivation_card.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';
import '../widgets/exercise/exercise_summary_card.dart';
import '../widgets/exercise/exercise_activity_tile.dart';
import '../widgets/exercise/sugar_warning_card.dart';
import '../widgets/exercise/exercise_chart.dart';

class ExerciseScreen extends StatelessWidget {
  ExerciseScreen({super.key});

  final ExerciseService _exerciseService = ExerciseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Egzersiz Takibi",
          style: TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<ExerciseModel>>(
        stream: _exerciseService.getExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Bağlantı Hatası: ${snapshot.error}"));
          }

          // ========== TEMEL VERİLER ==========
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final allExercises = snapshot.data ?? [];

          // ========== 1. BUGÜNÜN EGZERSİZ LİSTESİ ==========
          // ✅ TUTARLI: Her zaman yerel tarih kullan
          final todayActivities = allExercises.where((ex) {
            final exDayOnly = ex.dayOnly;
            return exDayOnly.year == todayStart.year &&
                exDayOnly.month == todayStart.month &&
                exDayOnly.day == todayStart.day;
          }).toList();

          // Bugünün istatistikleri
          double totalCalories = 0.0;
          int totalMinutes = 0;
          bool hasHigh = false;
          bool hasMedium = false;

          for (var ex in todayActivities) {
            if (ex.isCompleted) {
              totalCalories += ex.estimatedCalories;
              totalMinutes += ex.durationMinutes;
              String level = ex.intensityLevel.toLowerCase();
              if (level.contains("yüksek")) {
                hasHigh = true;
              } else if (level.contains("orta")) {
                hasMedium = true;
              }
            }
          }

          // ========== 2. HAFTALIK VERİ KONTROLÜ ==========
          final startOfWeek =
              todayStart.subtract(Duration(days: now.weekday - 1));

          final thisWeekExercises = allExercises.where((ex) {
            final exDayOnly = ex.dayOnly;
            return !exDayOnly.isBefore(startOfWeek) && ex.isCompleted;
          }).toList();

        

          // ========== 3. DÜNÜN VERİSİ HESAPLAMA ==========
          final yesterdayDate =
              todayStart.subtract(const Duration(days: 1));

          final yesterdayExercises = allExercises.where((ex) {
            final exDayOnly = ex.dayOnly;
            return exDayOnly.year == yesterdayDate.year &&
                exDayOnly.month == yesterdayDate.month &&
                exDayOnly.day == yesterdayDate.day &&
                ex.isCompleted;
          }).toList();

          double yesterdayTotalCalories = 0.0;
          bool hasYesterdayData = yesterdayExercises.isNotEmpty;

          if (hasYesterdayData) {
            for (var ex in yesterdayExercises) {
              yesterdayTotalCalories += ex.estimatedCalories;
            }
          }

         double calorieDifference = hasYesterdayData
    ? (totalCalories - yesterdayTotalCalories)
    : 0.0;

          // ========== YOĞUNLİK TİP BELİRLEME ==========
          String intensity = "---";
          if (hasHigh) {
            intensity = "Yüksek";
          } else if (hasMedium) {
            intensity = "Orta";
          } else if (todayActivities.isNotEmpty) {
            intensity = "Düşük";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========== 1. ÜST ÖZET KARTLARI ==========
                Row(
                  children: [
                    Expanded(
                      child: ExerciseSummaryCard(
                      value: totalCalories.toStringAsFixed(2),
                        label: "YAKILAN (KCAL)",
                        icon: Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ExerciseSummaryCard(
                        value: "$totalMinutes dk",
                        label: "SÜRE",
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ExerciseSummaryCard(
                  value: intensity,
                  label: "GÜN İÇİ YOĞUNLUK",
                  icon: Icons.favorite,
                  isFullWidth: true,
                ),
                const SizedBox(height: 24),

                // ========== 2. HAFTALIK GRAFIK ==========
                const ExerciseChart(),

                // ========== 3. MOTIVASYON VEYA KARŞILAŞTIRMA ==========
                if (now.weekday == DateTime.monday && totalCalories == 0) ...[
                  const SizedBox(height: 12),
                  const MondayMotivationCard(),
                ] else if (hasYesterdayData ||
                    (now.weekday == DateTime.monday && totalCalories > 0)) ...[
                  const SizedBox(height: 12),
                 ExerciseComparisonText(difference: calorieDifference.toInt()),
                ] else ...[
                  const SizedBox(height: 12),
                  const MondayMotivationCard(),
                ],

                const SizedBox(height: 12),
                const SugarWarningCard(),

                // ========== 4. BUGÜNKÜ EGZERSİZLER ==========
                const SizedBox(height: 24),
                const Text(
                  "Bugünkü Hareketlerin",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.secondary),
                ),
                const SizedBox(height: 12),

                if (todayActivities.isEmpty)
                  _buildEmptyState()
                else
                  Column(
                    children: todayActivities.map((exercise) {
                      return ExerciseActivityTile(
                        key: ValueKey(exercise.id),
                        title: exercise.activityName,
                        subtitle:
                            "${exercise.durationMinutes} dk - ${exercise.intensityLevel}",
                        calories: "${exercise.estimatedCalories}",
                        icon: exercise.activityIcon,
                        isCompleted: exercise.isCompleted,
                        duration: exercise.durationMinutes,
                        exerciseId: exercise.id,
                        initialSugar: exercise.glucoseBefore,
                      );
                    }).toList(),
                  ),

                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExerciseHistoryScreen()),
                  ),
                  child: _buildHistoryButton(),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddExerciseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon:
            const Icon(Icons.add, color: AppColors.secondary, size: 24),
        label: const Text(
          "Egzersiz Ekle",
          style: TextStyle(
              color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Henüz bugün için bir egzersiz eklemediniz.",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const Text(
            "Geçmiş Egzersizler",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.secondary),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
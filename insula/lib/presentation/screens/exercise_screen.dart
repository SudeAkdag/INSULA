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
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
   body: StreamBuilder<List<ExerciseModel>>(
        stream: _exerciseService.getExercises(),
        builder: (context, snapshot) {
  if (snapshot.connectionState == ConnectionState.waiting) {
    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
  if (snapshot.hasError) {
    return Center(child: Text("Bağlantı Hatası: ${snapshot.error}"));
  }

  // 1. TEMEL VERİLER VE BUGÜNÜN HESAPLANMASI
  final now = DateTime.now();
  final allExercises = snapshot.data ?? [];
  
  final todayActivities = allExercises.where((ex) => 
    ex.date.year == now.year && 
    ex.date.month == now.month && 
    ex.date.day == now.day
  ).toList();

  int totalCalories = 0;
  int totalMinutes = 0;
  bool hasHigh = false;
  bool hasMedium = false;

  for (var ex in todayActivities) {
    if (ex.isCompleted) {
      totalCalories += ex.estimatedCalories;
      totalMinutes += ex.durationMinutes;
      String level = ex.intensityLevel.toLowerCase();
      if (level.contains("yüksek")) hasHigh = true;
      else if (level.contains("orta")) hasMedium = true;
    }
  }

  // 2. HAFTALIK VERİ KONTROLÜ (Pazartesi'den bugüne kadar veri var mı?)
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  final mondayOfThisWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

  final thisWeekExercises = allExercises.where((ex) => 
    ex.date.isAfter(mondayOfThisWeek.subtract(const Duration(seconds: 1))) && 
    ex.isCompleted
  ).toList();

  bool hasAnyDataThisWeek = thisWeekExercises.isNotEmpty;

  // 3. DÜNÜN VERİSİNİN HESAPLANMASI (Kıyaslama için)
  final yesterdayDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
  
  final yesterdayExercises = allExercises.where((ex) => 
    ex.date.year == yesterdayDate.year && 
    ex.date.month == yesterdayDate.month && 
    ex.date.day == yesterdayDate.day &&
    ex.isCompleted
  ).toList();

  int yesterdayTotalCalories = 0;
  bool hasYesterdayData = yesterdayExercises.isNotEmpty;

  if (hasYesterdayData) {
    for (var ex in yesterdayExercises) {
      yesterdayTotalCalories += ex.estimatedCalories;
    }
  }

  int calorieDifference = hasYesterdayData ? (totalCalories - yesterdayTotalCalories) : 0;


  // Dinamik Yoğunluk Metni
  String intensity = "---";
  if (hasHigh) intensity = "Yüksek";
  else if (hasMedium) intensity = "Orta";
  else if (todayActivities.isNotEmpty) intensity = "Düşük";
          // Dinamik Yoğunluk Metni
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. ÜST ÖZET KARTLARI
                Row(
                  children: [
                    Expanded(
                      child: ExerciseSummaryCard(
                        value: "$totalCalories", 
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
                // Grafiği de anlık güncellenecek yeni haliyle çağırıyoruz
                // ...
const ExerciseChart(), // Grafik her zaman üstte durur

if (now.weekday == DateTime.monday && totalCalories == 0) ...[
  // SADECE Pazartesi VE henüz hiç veri girilmemişse motivasyon kartı
  const MondayMotivationCard(),
] else if (hasYesterdayData || (now.weekday == DateTime.monday && totalCalories > 0)) ...[
  // 1. Pazartesi ilk veri girildiyse VEYA 
  // 2. Diğer günlerde dünün verisi varsa kıyaslama metnini göster
  const SizedBox(height: 12),
  ExerciseComparisonText(difference: calorieDifference),
] else ...[
  // Hafta içi dün veri yoksa sayfa boş kalmasın diye yine motivasyon göster
  const MondayMotivationCard(),
],



const SugarWarningCard(),
// ...
                const SizedBox(height: 24),
                const Text(
                  "Bugünkü Hareketlerin", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)
                ),
                const SizedBox(height: 12),

                // 2. BUGÜNKÜ EGZERSİZ LİSTESİ
                if (todayActivities.isEmpty) 
                  _buildEmptyState()
                else 
                  Column(
                    children: todayActivities.map((exercise) {
                      return ExerciseActivityTile(
                        key: ValueKey(exercise.id),
                        title: exercise.activityName,
                        subtitle: "${exercise.durationMinutes} dk - ${exercise.intensityLevel}",
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
                    MaterialPageRoute(builder: (context) => const ExerciseHistoryScreen())
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
            MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.secondary, size: 24),
        label: const Text(
          "Egzersiz Ekle", 
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
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
            style: TextStyle(color: Colors.grey, fontSize: 13)
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
              shape: BoxShape.circle
            ),
            child: const Icon(Icons.history, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          const Text(
            "Geçmiş Egzersizler", 
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}


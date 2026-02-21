import 'package:flutter/material.dart';
import 'package:insula/presentation/screens/add_exercise_screen.dart'; 
import 'package:insula/presentation/screens/exercise_history_screen.dart';
import 'package:insula/data/services/exercise_service.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // 1. ÜST ÖZET KARTLARI (Dinamik Veri Bağlantısı)
    FutureBuilder<Map<String, dynamic>>(
      future: _exerciseService.getTodayStats(), // Bugünün toplamlarını getirir
      builder: (context, snapshot) {
        // Veriler yüklenene kadar 0 gösterir
        final stats = snapshot.data ?? {
          'totalCalories': 0, 
          'totalMinutes': 0, 
          'intensity': "Düşük"
        };

        return Column(
          children: [
            Row(
              children: [
                // YAKILAN KALORİ KARTI
                Expanded(
                  child: ExerciseSummaryCard(
                    value: "${stats['totalCalories']}", 
                    label: "YAKILAN (KCAL)", 
                    icon: Icons.local_fire_department, // Görseldeki alev ikonu
                  ),
                ),
                const SizedBox(width: 12),
                // SÜRE KARTI
                Expanded(
                  child: ExerciseSummaryCard(
                    value: "${stats['totalMinutes']} dk", 
                    label: "SÜRE", 
                    icon: Icons.timer, // Görseldeki kronometre ikonu
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // GÜN İÇİ YOĞUNLUK KARTI (Tam Genişlik)
            ExerciseSummaryCard(
              value: stats['intensity'], 
              label: "GÜN İÇİ YOĞUNLUK", 
              icon: Icons.favorite, // Görseldeki kalp ikonu
              isFullWidth: true,
            ),
          ],
        );
      },
    ),
            const SizedBox(height: 24),
            const ExerciseChart(),

            const SizedBox(height: 24),
            const SugarWarningCard(),
            
            const SizedBox(height: 24),
            const Text(
              "Bugünkü Hareketlerin", 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)
            ),
            const SizedBox(height: 12),

            // BUGÜNKÜ EGZERSİZ LİSTESİ (VERİTABANI)
            StreamBuilder<List<ExerciseModel>>(
              stream: _exerciseService.getExercises(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final now = DateTime.now();
                final todayActivities = snapshot.data?.where((ex) => 
                  ex.date.year == now.year && 
                  ex.date.month == now.month && 
                  ex.date.day == now.day
                ).toList() ?? [];

                if (todayActivities.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: todayActivities.map((exercise) {
                    return ExerciseActivityTile(
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
                );
              },
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
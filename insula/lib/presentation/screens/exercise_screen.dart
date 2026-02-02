import 'package:flutter/material.dart';
import 'package:insula/presentation/screens/add_exercise_screen.dart'; 
import 'package:insula/presentation/screens/exercise_history_screen.dart'; // Yeni import
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';
import '../widgets/exercise/exercise_summary_card.dart';
import '../widgets/exercise/exercise_activity_tile.dart';
import '../widgets/exercise/sugar_warning_card.dart';
import '../widgets/exercise/exercise_chart.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bugünün örnek verileri (Veritabanı bağlandığında buradan çekilecek)
    final List<ExerciseModel> todayActivities = [
      ExerciseModel(id: "1", activityName: "Yürüyüş", durationMinutes: 30, date: DateTime.now()),
      ExerciseModel(id: "2", activityName: "Ağırlık", durationMinutes: 15, date: DateTime.now()),
    ];

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
            // Üst Özet Kartları
            const Row(
              children: [
                Expanded(child: ExerciseSummaryCard(value: "450", label: "YAKILAN (KCAL)", icon: Icons.local_fire_department)),
                SizedBox(width: 12),
                Expanded(child: ExerciseSummaryCard(value: "45 dk", label: "SÜRE", icon: Icons.timer)),
              ],
            ),
            const SizedBox(height: 12),
            const ExerciseSummaryCard(value: "Orta", label: "YOĞUNLUK", icon: Icons.favorite, isFullWidth: true),
            
            const SizedBox(height: 24),
            
            // Haftalık Aktivite Grafiği
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Haftalık Aktivite", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                  child: const Text("+5%", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ExerciseChart(),

            const SizedBox(height: 24),
            const SugarWarningCard(), // Şeker Kontrolü uyarısı
            
            const SizedBox(height: 24),
            const Text("Bugünkü Hareketlerin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
            const SizedBox(height: 12),

            // Bugünün Aktiviteleri Listesi
            Column(
              children: todayActivities.map((exercise) => ExerciseActivityTile(
                title: " ${exercise.activityName}",
                subtitle: "${exercise.durationMinutes} dk - ${exercise.intensityLevel}",
                calories: "${exercise.estimatedCalories}",
                icon: exercise.activityIcon, isCompleted: false,
              )).toList(),
            ),

            const SizedBox(height: 16),

            // GEÇMİŞ EGZERSİZLER BUTONU (Görsel 16aa7a.png'deki gibi)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExerciseHistoryScreen()),
                );
              },
              child: Container(
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
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Geçmiş Egzersizler",
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 100), // FAB için boşluk
          ],
        ),
      ),
      
      // Egzersiz Ekleme Sayfasına Yönlendiren Buton
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExerciseScreen()),
          );
        },
        backgroundColor: const Color(0xFFFFC107),
        icon: const Icon(Icons.add, color: AppColors.secondary, size: 24),
        label: const Text(
          "Egzersiz Ekle", 
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
// lib/presentation/screens/add_exercise_screen.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/exercise_model.dart';
import '../widgets/add_exercise/activity_type_card.dart';
import '../widgets/add_exercise/duration_selector_card.dart';
import '../widgets/add_exercise/glucose_input_group.dart';
import '../widgets/add_exercise/calorie_summary_card.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  double _duration = 45;
  String _selectedActivity = "Yürüyüş";

  final List<Map<String, dynamic>> _activities = [
    {"label": "Yürüyüş", "icon": Icons.directions_walk},
    {"label": "Koşu", "icon": Icons.directions_run},
    {"label": "Yoga", "icon": Icons.self_improvement},
    {"label": "Ağırlık", "icon": Icons.fitness_center},
    {"label": "Bisiklet", "icon": Icons.directions_bike},
  ];

  @override
  Widget build(BuildContext context) {
    // Hesaplama mantığını modelden çekiyoruz
    final calcModel = ExerciseModel(
      id: '',
      activityName: _selectedActivity,
      durationMinutes: _duration.toInt(),
      date: DateTime.now(),
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Egzersiz Ekle", style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AKTİVİTE TÜRÜ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 16),
            
            // Aktivite Seçici (Ayrı Widget)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _activities.map((act) => ActivityTypeCard(
                  icon: act['icon'],
                  label: act['label'],
                  isSelected: _selectedActivity == act['label'],
                  onTap: () => setState(() => _selectedActivity = act['label']),
                )).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Süre Seçici (Widget'a taşındı)
            DurationSelectorCard(
              duration: _duration,
              onChanged: (val) => setState(() => _duration = val),
            ),

            const SizedBox(height: 32),

            // Kan Şekeri Alanı (Widget'a taşındı)
            const GlucoseInputGroup(),

            const SizedBox(height: 32),

            // Kalori Özeti (Widget'a taşındı)
            CalorieSummaryCard(
              calories: calcModel.estimatedCalories,
              intensity: calcModel.intensityLevel,
            ),

            const SizedBox(height: 40),

            // Kaydet Butonu
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Egzersizi Kaydet", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
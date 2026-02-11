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
  
  // Şeker girişi için kontrolcü tanımlandı
  final TextEditingController _glucoseController = TextEditingController();

  final List<Map<String, dynamic>> _activities = [
    {"label": "Yürüyüş", "icon": Icons.directions_walk},
    {"label": "Koşu", "icon": Icons.directions_run},
    {"label": "Yoga", "icon": Icons.self_improvement},
    {"label": "Ağırlık", "icon": Icons.fitness_center},
    {"label": "Bisiklet", "icon": Icons.directions_bike},
  ];

  // Şeker alanı boşsa gösterilecek uyarı pop-up'ı
  void _handleSave() async {
    if (_glucoseController.text.trim().isEmpty) {
      final bool? proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Şeker Verisi Eksik"),
          content: const Text(
            "Şeker girme alanını doldurmazsanız egzersiz öncesi şeker verinizi kaydedemezsiniz. Devam etmek istiyor musunuz?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Geri dön
              child: const Text("Geri Dön", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Devam et
              child: const Text(
                "Devam Et", 
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      );

      // Eğer kullanıcı pop-up'ta "Devam Et" dediyse ekrandan çık
      if (proceed == true && mounted) {
        Navigator.pop(context);
      }
    } else {
      // Şeker girilmişse direkt kaydet ve çık
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _glucoseController.dispose(); // Bellek sızıntısını önlemek için
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

            DurationSelectorCard(
              duration: _duration,
              onChanged: (val) => setState(() => _duration = val),
            ),

            const SizedBox(height: 32),

            // Şeker giriş grubu kontrolcü ile bağlandı
            GlucoseInputGroup(controller: _glucoseController),

            const SizedBox(height: 32),

            CalorieSummaryCard(
              calories: calcModel.estimatedCalories,
              intensity: calcModel.intensityLevel,
            ),

            const SizedBox(height: 40),

            // Kaydet Butonu
            ElevatedButton(
              onPressed: _handleSave, // Kontrollü kayıt fonksiyonuna bağlandı
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
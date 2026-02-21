import 'package:flutter/material.dart';
import 'package:insula/data/services/exercise_service.dart';
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
  final ExerciseService _exerciseService = ExerciseService();
  final TextEditingController _glucoseController = TextEditingController();
  
  double _duration = 45;
  String _selectedActivity = "Yürüyüş";

  final List<Map<String, dynamic>> _activities = [
    {"label": "Yürüyüş", "icon": Icons.directions_walk},
    {"label": "Koşu", "icon": Icons.directions_run},
    {"label": "Yoga", "icon": Icons.self_improvement},
    {"label": "Ağırlık", "icon": Icons.fitness_center},
    {"label": "Bisiklet", "icon": Icons.directions_bike},
  ];

  // Firestore'a kayıt işlemini gerçekleştiren fonksiyon
  Future<void> _processSave() async {
    final newExercise = ExerciseModel(
      activityName: _selectedActivity,
      durationMinutes: _duration.toInt(),
      glucoseBefore: double.tryParse(_glucoseController.text.trim()),
      date: DateTime.now(),
      isCompleted: false, id: '', // Yeni eklenen egzersiz henüz tamamlanmamıştır
    );

    await _exerciseService.saveExercise(newExercise);
    
    if (mounted) {
      Navigator.pop(context); // İşlem bitince geri dön
    }
  }

  // Uyarı pop-up'ı ve kontrol mekanizması
  void _handleSave() async {
    if (_glucoseController.text.trim().isEmpty) {
      final bool? proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surfaceLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Şeker Verisi Eksik", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            "Egzersiz öncesi şeker verinizi girmeniz, diyabet takibiniz için önemlidir. Devam etmek istiyor musunuz?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Geri Dön", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Devam Et", 
                style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)
              ),
            ),
          ],
        ),
      );

      if (proceed == true) {
        await _processSave();
      }
    } else {
      await _processSave();
    }
  }

  @override
  void dispose() {
    _glucoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sadece kalori ve yoğunluk gösterimi için geçici model
    final calcModel = ExerciseModel(
      activityName: _selectedActivity,
      durationMinutes: _duration.toInt(),
      date: DateTime.now(), id: '',
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
                children: _activities.map((act) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActivityTypeCard(
                    icon: act['icon'],
                    label: act['label'],
                    isSelected: _selectedActivity == act['label'],
                    onTap: () => setState(() => _selectedActivity = act['label']),
                  ),
                )).toList(),
              ),
            ),

            const SizedBox(height: 32),

            DurationSelectorCard(
              duration: _duration,
              onChanged: (val) => setState(() => _duration = val),
            ),

            const SizedBox(height: 32),

            GlucoseInputGroup(controller: _glucoseController),

            const SizedBox(height: 32),

            CalorieSummaryCard(
              calories: calcModel.estimatedCalories,
              intensity: calcModel.intensityLevel,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
                shadowColor: AppColors.secondary.withOpacity(0.3),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text(
                    "Egzersizi Kaydet", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../screens/active_timer_screen.dart';
import '../active_timer/status_action_button.dart';

class ExerciseActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String calories;
  final IconData icon;
  final bool isCompleted;
  final int duration; // Süre eklendi
  final String? exerciseId; // Güncelleme için ID eklendi
  final double? initialSugar; // Başlangıç şekeri eklendi

  const ExerciseActivityTile({
    super.key, 
    required this.title, 
    required this.subtitle, 
    required this.calories, 
    required this.icon, 
    required this.isCompleted,
    required this.duration, // Zorunlu yaptık
    this.exerciseId,
    this.initialSugar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: !isCompleted ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.backgroundLight, 
            child: Icon(icon, color: AppColors.secondary)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecLight, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isCompleted 
            ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
            : SizedBox(
                width: 80,
                height: 40,
                child: StatusActionButton(
                  label: "BAŞLA",
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => ActiveTimerScreen(
                        title: title, 
                        targetMinutes: duration, // Hata veren yer düzeldi
                        exerciseId: exerciseId, // Güncelleme için ID gidiyor
                        initialSugar: initialSugar, // Şeker verisi gidiyor
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
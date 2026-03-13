import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'profile_base_components.dart';

class ProfileGoalsLifestyleCard extends StatelessWidget {
  final TextEditingController targetMinCtrl;
  final TextEditingController targetMaxCtrl;
  final TextEditingController weeklyExerciseCtrl;
  final TextEditingController sleepHoursCtrl;
  final List<String> improvementGoals;
  final ValueChanged<List<String>> onGoalsChanged;

  const ProfileGoalsLifestyleCard({
    super.key,
    required this.targetMinCtrl,
    required this.targetMaxCtrl,
    required this.weeklyExerciseCtrl,
    required this.sleepHoursCtrl,
    required this.improvementGoals,
    required this.onGoalsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Hedefler ve Yaşam Tarzı'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.accentTeal,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ProfileBaseComponents.buildField(
                      'Hedef Min (mg/dL)',
                      targetMinCtrl,
                      keyboard: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileBaseComponents.buildField(
                      'Hedef Max (mg/dL)',
                      targetMaxCtrl,
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ProfileBaseComponents.buildField(
                      'Haftalık Egzersiz Günü',
                      weeklyExerciseCtrl,
                      keyboard: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileBaseComponents.buildField(
                      'Gecelik Uyku (Saat)',
                      sleepHoursCtrl,
                      keyboard: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildGoalsField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsField() {
    final availableGoals = [
      'Kilo Vermek',
      'Daha Aktif Olmak',
      'Şeker Dengesini Sağlamak',
      'Daha İyi Beslenmek'
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Geliştirme Hedefleri'),
        Wrap(
          spacing: 8,
          children: availableGoals.map((goal) {
            final isSelected = improvementGoals.contains(goal);
            return FilterChip(
              label: Text(
                goal,
                style: AppTextStyles.body.copyWith(
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppColors.secondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                final newGoals = List<String>.from(improvementGoals);
                if (selected) {
                  newGoals.add(goal);
                } else {
                  newGoals.remove(goal);
                }
                onGoalsChanged(newGoals);
              },
              selectedColor: AppColors.accentTeal,
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';

class StepLifestyleGoals extends StatefulWidget {
  const StepLifestyleGoals({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepLifestyleGoals> createState() => _StepLifestyleGoalsState();
}

class _StepLifestyleGoalsState extends State<StepLifestyleGoals> {
  int _exerciseDays = 2;
  double _sleepHours = 7.0;
  final List<String> _selectedGoals = [];

  static const _goals = [
    'Şeker kontrolü',
    'İlaç takibi',
    'Doktor raporları',
    'Beslenme',
    'Egzersiz',
    'Kilo yönetimi',
  ];

  @override
  void initState() {
    super.initState();
    _exerciseDays = widget.data.weeklyExerciseDays ?? 2;
    _sleepHours = widget.data.sleepHoursPerNight ?? 7.0;
    if (widget.data.improvementGoals != null) {
      _selectedGoals.addAll(widget.data.improvementGoals!);
    }
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      weeklyExerciseDays: _exerciseDays,
      sleepHoursPerNight: _sleepHours,
      improvementGoals: _selectedGoals.isEmpty ? null : List.from(_selectedGoals),
    ));
  }

  void _toggleGoal(String g) {
    setState(() {
      if (_selectedGoals.contains(g)) {
        _selectedGoals.remove(g);
      } else {
        _selectedGoals.add(g);
      }
      _emit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Yaşam Tarzı ve Hedefler',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Haftalık egzersiz, uyku ve iyileştirmek istediğiniz alanları seçin.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Haftalık egzersiz (gün)',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (_exerciseDays > 0) {
                    setState(() {
                      _exerciseDays--;
                      _emit();
                    });
                  }
                },
                icon: const Icon(Icons.remove_circle_outline,
                    color: AppColors.secondary, size: 36),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  '$_exerciseDays',
                  style: AppTextStyles.glucoseValue
                      .copyWith(fontSize: 42, color: AppColors.secondary),
                ),
              ),
              IconButton(
                onPressed: () {
                  if (_exerciseDays < 7) {
                    setState(() {
                      _exerciseDays++;
                      _emit();
                    });
                  }
                },
                icon: const Icon(Icons.add_circle_outline,
                    color: AppColors.secondary, size: 36),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),
          Text(
            'Ortalama uyku süresi (saat)',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _sleepHours,
            min: 4,
            max: 12,
            divisions: 16,
            activeColor: AppColors.secondary,
            label: '${_sleepHours.toStringAsFixed(1)} saat',
            onChanged: (v) {
              setState(() {
                _sleepHours = v;
                _emit();
              });
            },
          ),
          Center(
            child: Text(
              '${_sleepHours.toStringAsFixed(1)} saat',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                fontSize: 18,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          Text(
            'Neyi iyileştirmek istersiniz? (Birden fazla seçebilirsiniz)',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _goals.map((g) {
              final selected = _selectedGoals.contains(g);
              return FilterChip(
                label: Text(g),
                selected: selected,
                onSelected: (_) => _toggleGoal(g),
                selectedColor: AppColors.primary.withAlpha(51),
                checkmarkColor: AppColors.secondary,
                backgroundColor: AppColors.surfaceLight,
                side: BorderSide(
                  color: selected ? AppColors.secondary : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () { _emit(); widget.onNext(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
              ),
              child: const Text('Devam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/models/onboarding_data.dart';
import 'package:insula/presentation/widgets/onboarding/onboarding_select_card.dart';

class StepGlucoseMonitoring extends StatefulWidget {
  const StepGlucoseMonitoring({
    super.key,
    required this.data,
    required this.onChanged,
    required this.onNext,
  });

  final OnboardingData data;
  final ValueChanged<OnboardingData> onChanged;
  final VoidCallback onNext;

  @override
  State<StepGlucoseMonitoring> createState() => _StepGlucoseMonitoringState();
}

class _StepGlucoseMonitoringState extends State<StepGlucoseMonitoring> {
  String? _frequency;
  bool _usesCgm = false;
  RangeValues _targetRange = const RangeValues(70, 140);

  static const _frequencies = [
    ('Günde 1–2 kez', Icons.schedule),
    ('Günde 3–4 kez', Icons.bloodtype_outlined),
    ('Günde 5+ kez', Icons.monitor_heart_outlined),
    ('Nadiren', Icons.remove_circle_outline),
  ];

  @override
  void initState() {
    super.initState();
    _frequency = widget.data.glucoseMeasurementFrequency;
    _usesCgm = widget.data.usesCgm ?? false;
    _targetRange = RangeValues(
      (widget.data.targetGlucoseMin ?? 70).toDouble(),
      (widget.data.targetGlucoseMax ?? 140).toDouble(),
    );
  }

  void _emit() {
    widget.onChanged(widget.data.copyWith(
      glucoseMeasurementFrequency: _frequency,
      usesCgm: _usesCgm,
      targetGlucoseMin: _targetRange.start.round(),
      targetGlucoseMax: _targetRange.end.round(),
    ));
  }

  bool get _canNext => _frequency != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Glikoz İzleme',
            style: AppTextStyles.h1.copyWith(
              fontSize: 26,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kan şekeri ölçüm alışkanlıklarınızı ve hedef aralığınızı belirleyin.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecLight,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text(
            'Günlük ölçüm sıklığı',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._frequencies.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OnboardingSelectCard(
                  label: f.$1,
                  icon: f.$2,
                  selected: _frequency == f.$1,
                  onTap: () {
                    setState(() {
                      _frequency = f.$1;
                      _emit();
                    });
                  },
                ),
              )),

          const SizedBox(height: AppSpacing.lg),
          Material(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            child: SwitchListTile(
              value: _usesCgm,
              onChanged: (v) {
                setState(() {
                  _usesCgm = v;
                  _emit();
                });
              },
              title: Text(
                'CGM (Sürekli Glikoz Monitörü) kullanıyorum',
                style: AppTextStyles.body.copyWith(fontSize: 16),
              ),
              activeThumbColor: AppColors.secondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
          Text(
            'Hedef şeker aralığı (mg/dL)',
            style: AppTextStyles.label.copyWith(fontSize: 16, color: AppColors.textMainLight),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.secondary.withAlpha(26),
              borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            ),
            child: Column(
              children: [
                RangeSlider(
                  values: _targetRange,
                  min: 54,
                  max: 250,
                  divisions: 196,
                  activeColor: AppColors.secondary,
                  inactiveColor: AppColors.secondary.withAlpha(64),
                  onChanged: (v) {
                    setState(() {
                      _targetRange = v;
                      _emit();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_targetRange.start.round()} – ${_targetRange.end.round()} mg/dL',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _canNext ? () { _emit(); widget.onNext(); } : null,
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

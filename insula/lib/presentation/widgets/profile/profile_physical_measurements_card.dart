import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_base_components.dart';

class ProfilePhysicalMeasurementsCard extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;

  const ProfilePhysicalMeasurementsCard({
    super.key,
    required this.heightController,
    required this.weightController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Fiziksel Ölçümler'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.primary,
          child: Row(
            children: [
              Expanded(
                child: ProfileBaseComponents.buildField(
                  'Boy (cm)',
                  heightController,
                  hintText: 'Örn: 182',
                  keyboard: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ProfileBaseComponents.buildField(
                  'Kilo (kg)',
                  weightController,
                  hintText: 'Örn: 78',
                  keyboard: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_base_components.dart';

class ProfileDiabetesProfileCard extends StatelessWidget {
  final String? diabetesType;
  final TextEditingController diagnosisYearCtrl;
  final ValueChanged<String?> onDiabetesTypeChanged;

  const ProfileDiabetesProfileCard({
    super.key,
    required this.diabetesType,
    required this.diagnosisYearCtrl,
    required this.onDiabetesTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Diyabet Profili'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.accentTeal,
          child: Column(
            children: [
              _buildDiabetesTypeField(),
              const SizedBox(height: 8),
              ProfileBaseComponents.buildField(
                'Tanı Yılı',
                diagnosisYearCtrl,
                hintText: 'Örn: 2018',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiabetesTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Diyabet Tipi'),
        DropdownButtonFormField<String>(
          value: diabetesType,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('Diyabet Tipi Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Tip 1', child: Text('Tip 1')),
            DropdownMenuItem(value: 'Tip 2', child: Text('Tip 2')),
            DropdownMenuItem(value: 'Gestasyonel', child: Text('Gestasyonel')),
            DropdownMenuItem(value: 'Prediyabet', child: Text('Prediyabet')),
          ],
          onChanged: onDiabetesTypeChanged,
        ),
      ],
    );
  }
}

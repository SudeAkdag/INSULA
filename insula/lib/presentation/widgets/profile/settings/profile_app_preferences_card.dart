import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../profile_base_components.dart';

class ProfileAppPreferencesCard extends StatelessWidget {
  final String language;
  final ValueChanged<String?> onLanguageChanged;

  const ProfileAppPreferencesCard({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Uygulama Tercihleri'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.accentTeal,
          child: Column(
            children: [
              _buildLanguageField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Dil'),
        DropdownButtonFormField<String>(
          value: language,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('Dil Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Türkçe', child: Text('Türkçe')),
            DropdownMenuItem(value: 'English', child: Text('English')),
            DropdownMenuItem(value: 'Deutsch', child: Text('Deutsch')),
          ],
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}

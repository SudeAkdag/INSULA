import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_base_components.dart';

class ProfileHealthInfoCard extends StatelessWidget {
  final TextEditingController chronicCtrl;
  final TextEditingController allergyCtrl;

  const ProfileHealthInfoCard({
    super.key,
    required this.chronicCtrl,
    required this.allergyCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Sağlık Bilgileri'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.primary,
          child: Column(
            children: [
              ProfileBaseComponents.buildField(
                'Kronik Hastalıklar',
                chronicCtrl,
                hintText: 'Örn: Tip 2 Diyabet',
              ),
              const SizedBox(height: 8),
              ProfileBaseComponents.buildField(
                'Alerjiler',
                allergyCtrl,
                hintText: 'Örn: Penisilin',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

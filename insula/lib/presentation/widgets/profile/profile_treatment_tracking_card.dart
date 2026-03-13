import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_base_components.dart';

class ProfileTreatmentTrackingCard extends StatelessWidget {
  final bool usesInsulin;
  final String? insulinType;
  final String? insulinDeliveryMethod;
  final bool usesCgm;
  final String? glucoseMeasurementFrequency;
  final ValueChanged<bool> onUsesInsulinChanged;
  final ValueChanged<String?> onInsulinTypeChanged;
  final ValueChanged<String?> onInsulinMethodChanged;
  final ValueChanged<bool> onUsesCgmChanged;
  final ValueChanged<String?> onFrequencyChanged;

  const ProfileTreatmentTrackingCard({
    super.key,
    required this.usesInsulin,
    this.insulinType,
    this.insulinDeliveryMethod,
    required this.usesCgm,
    this.glucoseMeasurementFrequency,
    required this.onUsesInsulinChanged,
    required this.onInsulinTypeChanged,
    required this.onInsulinMethodChanged,
    required this.onUsesCgmChanged,
    required this.onFrequencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Tedavi ve İzleme'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.primary,
          child: Column(
            children: [
              ProfileBaseComponents.buildSwitchField(
                'İnsülin Kullanıyor musunuz?',
                usesInsulin,
                onUsesInsulinChanged,
              ),
              if (usesInsulin) ...[
                const SizedBox(height: 8),
                _buildInsulinTypeField(),
                const SizedBox(height: 8),
                _buildInsulinMethodField(),
              ],
              const SizedBox(height: 8),
              ProfileBaseComponents.buildSwitchField(
                'CGM Kullanıyor musunuz?',
                usesCgm,
                onUsesCgmChanged,
              ),
              const SizedBox(height: 8),
              _buildFrequencyField(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsulinTypeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('İnsülin Tipi'),
        DropdownButtonFormField<String>(
          value: insulinType,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('İnsülin Tipi Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Hızlı etkili', child: Text('Hızlı etkili')),
            DropdownMenuItem(value: 'Uzun etkili', child: Text('Uzun etkili')),
            DropdownMenuItem(value: 'Karma', child: Text('Karma')),
          ],
          onChanged: onInsulinTypeChanged,
        ),
      ],
    );
  }

  Widget _buildInsulinMethodField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('İnsülin Uygulama Yöntemi'),
        DropdownButtonFormField<String>(
          value: insulinDeliveryMethod,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('Yöntem Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Kalem', child: Text('Kalem')),
            DropdownMenuItem(value: 'Pompa', child: Text('Pompa')),
          ],
          onChanged: onInsulinMethodChanged,
        ),
      ],
    );
  }

  Widget _buildFrequencyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Glikoz Ölçüm Sıklığı'),
        DropdownButtonFormField<String>(
          value: glucoseMeasurementFrequency,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('Sıklık Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Günde 1–2 kez', child: Text('Günde 1–2 kez')),
            DropdownMenuItem(value: 'Günde 3–4 kez', child: Text('Günde 3–4 kez')),
            DropdownMenuItem(value: 'Günde 5+ kez', child: Text('Günde 5+ kez')),
            DropdownMenuItem(value: 'Nadiren', child: Text('Nadiren')),
          ],
          onChanged: onFrequencyChanged,
        ),
      ],
    );
  }
}

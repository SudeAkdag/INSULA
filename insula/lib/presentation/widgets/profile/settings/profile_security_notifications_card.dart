import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../profile_base_components.dart';

class ProfileSecurityNotificationsCard extends StatelessWidget {
  final bool hasSevereHypoHistory;
  final bool reminderMedication;
  final bool reminderMeasurement;
  final bool reminderWater;
  final ValueChanged<bool> onHypoHistoryChanged;
  final ValueChanged<bool> onMedicationReminderChanged;
  final ValueChanged<bool> onMeasurementReminderChanged;
  final ValueChanged<bool> onWaterReminderChanged;

  const ProfileSecurityNotificationsCard({
    super.key,
    required this.hasSevereHypoHistory,
    required this.reminderMedication,
    required this.reminderMeasurement,
    required this.reminderWater,
    required this.onHypoHistoryChanged,
    required this.onMedicationReminderChanged,
    required this.onMeasurementReminderChanged,
    required this.onWaterReminderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Güvenlik ve Bildirimler'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.tertiary,
          child: Column(
            children: [
              ProfileBaseComponents.buildSwitchField(
                'Şiddetli Hipoglisemi Geçmişi',
                hasSevereHypoHistory,
                onHypoHistoryChanged,
              ),
              const Divider(height: 16),
              ProfileBaseComponents.buildSwitchField(
                'İlaç Hatırlatıcısı',
                reminderMedication,
                onMedicationReminderChanged,
              ),
              ProfileBaseComponents.buildSwitchField(
                'Ölçüm Hatırlatıcısı',
                reminderMeasurement,
                onMeasurementReminderChanged,
              ),
              ProfileBaseComponents.buildSwitchField(
                'Su Hatırlatıcısı',
                reminderWater,
                onWaterReminderChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../screens/profile_screen.dart'; // To access EmergencyContact model
import 'profile_base_components.dart';

class ProfileEmergencyContactCard extends StatelessWidget {
  final List<EmergencyContact> emergencyContacts;
  final VoidCallback onAddContact;
  final ValueChanged<int> onRemoveContact;
  final bool isLoading;

  const ProfileEmergencyContactCard({
    super.key,
    required this.emergencyContacts,
    required this.onAddContact,
    required this.onRemoveContact,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Acil Durum Bilgisi', danger: true),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.tertiary,
          child: Column(
            children: [
              ...List.generate(emergencyContacts.length, (index) {
                final contact = emergencyContacts[index];
                return Column(
                  children: [
                    if (index > 0) const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ProfileBaseComponents.buildField(
                            'Ad Soyad',
                            contact.nameController,
                            hintText: 'Örn: Ayşe Yılmaz',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ProfileBaseComponents.buildField(
                            'Telefon',
                            contact.phoneController,
                            keyboard: TextInputType.phone,
                            hintText: 'Örn: +90 555 123 45 67',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.tertiary,
                              size: 24,
                            ),
                            onPressed: () => onRemoveContact(index),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onAddContact,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Kişi Ekle'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.tertiary,
                    side: const BorderSide(color: AppColors.tertiary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

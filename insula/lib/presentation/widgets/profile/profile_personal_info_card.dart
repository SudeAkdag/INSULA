// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'profile_base_components.dart';

class ProfilePersonalInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final String? gender;
  final DateTime? dob;
  final VoidCallback onPickDob;
  final ValueChanged<String?> onGenderChanged;

  const ProfilePersonalInfoCard({
    super.key,
    required this.nameController,
    required this.emailController,
    this.gender,
    this.dob,
    required this.onPickDob,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Kişisel Bilgiler'),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.accentTeal,
          child: Column(
            children: [
              ProfileBaseComponents.buildField(
                'Ad Soyad',
                nameController,
                suffixIcon: Icons.person,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ad Soyad boş olamaz' : null,
              ),
              const SizedBox(height: 8),
              ProfileBaseComponents.buildField(
                'E-posta',
                emailController,
                keyboard: TextInputType.emailAddress,
                suffixIcon: Icons.email,
                readOnly: false,
              ),
              const SizedBox(height: 8),
              _buildGenderField(),
              const SizedBox(height: 8),
              _buildDobField(),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Cinsiyet'),
        DropdownButtonFormField<String>(
          value: gender,
          isExpanded: true,
          decoration: ProfileBaseComponents.dropdownDecoration('Cinsiyet Seçiniz'),
          items: const [
            DropdownMenuItem(value: 'Erkek', child: Text('Erkek')),
            DropdownMenuItem(value: 'Kadın', child: Text('Kadın')),
            DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
            DropdownMenuItem(value: 'Belirtmek İstemiyorum', child: Text('Belirtmek İstemiyorum')),
          ],
          onChanged: onGenderChanged,
        ),
      ],
    );
  }

  Widget _buildDobField() {
    final text = dob == null ? '' : _formatDate(dob!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildLabel('Doğum Tarihi'),
        InkWell(
          onTap: onPickDob,
          child: InputDecorator(
            decoration: ProfileBaseComponents.dropdownDecoration('Örn: 15/05/1990').copyWith(
              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.accentTeal, size: 22),
            ),
            child: Text(
              text.isEmpty ? 'Tarih seçiniz' : text,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                color: text.isEmpty ? Colors.grey : AppColors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../profile_base_components.dart';

class ProfileAccountActionsCard extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const ProfileAccountActionsCard({
    super.key,
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileBaseComponents.buildSectionTitle('Hesap İşlemleri', danger: true),
        ProfileBaseComponents.buildAccentCard(
          accent: AppColors.tertiary,
          child: Column(
            children: [
              _buildActionButton(
                label: 'Oturumu Sonlandır',
                icon: Icons.logout,
                color: AppColors.secondary,
                onTap: onLogout,
              ),
              const Divider(height: 16),
              _buildActionButton(
                label: 'Hesabı Sil',
                icon: Icons.delete_forever,
                color: AppColors.tertiary,
                onTap: onDeleteAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

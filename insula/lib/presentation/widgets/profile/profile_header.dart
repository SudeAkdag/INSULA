import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'Ad Soyad' : name;
    final displayEmail = email.isEmpty ? 'E-posta' : email;

    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.surfaceLight,
                child: const Icon(Icons.person, size: 48, color: AppColors.secondary),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.camera_alt, size: 16, color: AppColors.secondary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          displayName,
          style: AppTextStyles.h1.copyWith(fontSize: 19),
        ),
        const SizedBox(height: 4),
        Text(
          displayEmail,
          style: AppTextStyles.body.copyWith(color: AppColors.textSecLight),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

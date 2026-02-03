// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _QuickActionButton(
            label: "Ölçüm",
            icon: Icons.water_drop,
            isPrimary: true,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _QuickActionButton(
            label: "Öğün",
            icon: Icons.restaurant,
            isPrimary: false,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _QuickActionButton(
            label: "İnsülin",
            icon: Icons.vaccines,
            isPrimary: false,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _QuickActionButton(
            label: "İlaç",
            icon: Icons.medication,
            isPrimary: false,
            onTap: () {},
          ),
          const SizedBox(width: 16),
          _QuickActionButton(
            label: "Acil Durum",
            icon: Icons.warning,
            isPrimary: false,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPrimary ? AppColors.primary : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary
                  ? null
                  : Border.all(color: AppColors.navBar.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: (isPrimary ? AppColors.primary : Colors.black)
                      .withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: isPrimary ? AppColors.secondary : AppColors.secondary,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecLight,
          ),
        ),
      ],
    );
  }
}

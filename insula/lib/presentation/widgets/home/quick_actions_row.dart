// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class QuickActionsRow extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const QuickActionsRow({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {"label": "İnsülin", "icon": Icons.vaccines},
      {"label": "Uyku Takibi", "icon": Icons.nightlight},
      {"label": "Su Takibi", "icon": Icons.water_drop},
      {"label": "İlaç", "icon": Icons.medication},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(actions.length, (index) {
          final action = actions[index];
          final isSelected = selectedIndex == index;
          final bool isPrimary = isSelected;

          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _QuickActionButton(
              label: action['label'],
              icon: action['icon'],
              isPrimary: isPrimary,
              onTap: () => onItemTapped(index),
            ),
          );
        }),
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
            width: 72,
            height: 72,
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
              color: AppColors.secondary,
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

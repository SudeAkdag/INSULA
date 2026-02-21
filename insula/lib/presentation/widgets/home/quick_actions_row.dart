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
    // List of quick actions
    final List<Map<String, dynamic>> actions = [
      {"label": "Su Takibi", "icon": Icons.water_drop},
      {"label": "Uyku Takibi", "icon": Icons.nightlight},
      {"label": "İnsülin", "icon": Icons.vaccines},
      {"label": "İlaç", "icon": Icons.medication},
      {"label": "Acil Durum", "icon": Icons.warning},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(actions.length, (index) {
          final action = actions[index];
          final isSelected = selectedIndex == index;
          // Emergency button is never "selected" in the scroll view context in the same way,
          // but if we want it to highlight when pressed, we can handle it.
          // For now, let's keep the logic simple: if it's the active index, it's highlighted.
          // Exception: Emergency might not be part of the PageView index logic for highlighting
          // if we don't want it to stay highlighted while viewing other cards.
          // But user said "scrol açılmasın" for it.
          // Let's assume passed selectedIndex matches the PageView.

          // Special case regarding color for the "Acil Durum" button from user request:
          // "butona basıldığında butonun belirgin olması adına farklı renk alsın"
          // We can handle temporary highlighting or just keep standard selection logic if it was selectable.
          // Since it's not part of the scroll, it won't be `selectedIndex` from PageView.
          // So it effectively works as a momentary button or we need a separate state for it.
          // However, existing logic uses `selectedIndex` to highlight.

          bool isPrimary = isSelected;
          if (index == 4)
            isPrimary = false; // Never permanently selected for scroll view

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

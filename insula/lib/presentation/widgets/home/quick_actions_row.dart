// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/nutrient_colors.dart';

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
      {
        "label": "İnsülin",
        "icon": Icons.vaccines,
        "color": AppColors.secondary
      },
      {"label": "Uyku", "icon": Icons.nightlight, "color": AppColors.primary},
      {"label": "Su", "icon": Icons.water_drop, "color": AppColors.tertiary},
      {"label": "İlaç", "icon": Icons.medication, "color": NutrientColors.fat},
    ];

    return Padding(
      // Sayfa kenarlarındaki boşlukla hizalıyoruz
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        // Butonları sayfa genişliğine eşit yayıyoruz
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(actions.length, (index) {
          final action = actions[index];
          final isSelected = selectedIndex == index;

          return _QuickActionButton(
            label: action['label'],
            icon: action['icon'],
            // İkon rengini pastel tonlardan alıyoruz
            iconColor: action['color'],
            isSelected: isSelected,
            onTap: () => onItemTapped(index),
          );
        }),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Ekran genişliğine göre buton boyutunu ayarlamak için LayoutBuilder veya sabit değer
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 65, // Biraz küçülttük ki küçük ekranlarda taşmasın
            height: 65,
            decoration: BoxDecoration(
              // Arka planı her zaman beyaz (veya çok açık gri) yapıp seçileni border ile belli edebiliriz
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? iconColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              // İkon rengini pastel tonlarda yapıyoruz
              color: isSelected ? iconColor : iconColor.withOpacity(0.6),
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.label.copyWith(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.surfaceDark : AppColors.textSecLight,
          ),
        ),
      ],
    );
  }
}

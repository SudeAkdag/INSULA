// presentation/widgets/drawers/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<IconData> _icons = [
    Icons.medication_outlined,       // 0 – İlaç
    Icons.restaurant_menu_outlined,  // 1 – Beslenme
    Icons.home_outlined,             // 2 – Ana Sayfa (ORTADA)
    Icons.fitness_center_outlined,   // 3 – Egzersiz
    Icons.person_outline,            // 4 – Profil
  ];

  static const List<IconData> _activeIcons = [
    Icons.medication,       // 0 – İlaç
    Icons.restaurant_menu,  // 1 – Beslenme
    Icons.home,             // 2 – Ana Sayfa (ORTADA)
    Icons.fitness_center,   // 3 – Egzersiz
    Icons.person,           // 4 – Profil
  ];

  static const List<String> _labels = [
    'İlaç',       // 0
    'Beslenme',   // 1
    'Ana Sayfa',  // 2
    'Egzersiz',   // 3
    'Profil',     // 4
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 74,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(5, (index) => _buildNavItem(index)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(
                0,
                isSelected ? -10 : 0,
                0,
              ),
              padding: isSelected
                  ? const EdgeInsets.all(10)
                  : EdgeInsets.zero,
              decoration: isSelected
                  ? const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                isSelected ? _activeIcons[index] : _icons[index],
                color: isSelected
                    ? Colors.white
                    : AppColors.secondary.withAlpha(100),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[index],
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.secondary
                    : AppColors.secondary.withAlpha(100),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
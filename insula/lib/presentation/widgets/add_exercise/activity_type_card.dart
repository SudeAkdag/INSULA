import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ActivityTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityTypeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Column(
          children: [
            // İkon Konteynırı
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16), // Biraz daha genişletildi
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20), // Daha yumuşak köşeler
                border: isSelected 
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : Border.all(color: AppColors.backgroundLight),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade500,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            // Aktivite Metni
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.secondary : Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExerciseSummaryCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isFullWidth;

  const ExerciseSummaryCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.secondary)),
          Text(label, style: const TextStyle(color: AppColors.textSecLight, fontSize: 10)),
        ],
      ),
    );
  }
}
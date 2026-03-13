import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryActivityTile extends StatelessWidget {
  final String title;
  final IconData icon; // İkon artık dinamik
  final String time;
  final String duration;
  final String calories;
  final String? glucoseBefore;
  final String? glucoseAfter;
  final bool isDecrease;

  const HistoryActivityTile({
    super.key,
    required this.title,
    required this.icon,
    required this.time,
    required this.duration,
    required this.calories,
    this.glucoseBefore,
    this.glucoseAfter,
    required this.isDecrease,
  });

  @override
  Widget build(BuildContext context) {
    // Hem başlangıç hem bitiş şekeri varsa tam veri modu aktif olur
    final bool hasBoth = (glucoseBefore != null && glucoseBefore != "null") && 
                         (glucoseAfter != null && glucoseAfter != "null");

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                child: Icon(icon, color: AppColors.secondary), // İkon buradan geliyor
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Dinamik Kan Şekeri Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: hasBoth 
                      ? (isDecrease ? AppColors.secondary.withValues(alpha: 0.08) : AppColors.tertiary.withValues(alpha: 0.08))
                      : AppColors.secondary.withValues(alpha: 0.05), // Veri eksikken yumuşak mavi
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "KAN ŞEKERİ",
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: hasBoth 
                            ? (isDecrease ? AppColors.secondary : AppColors.tertiary)
                            : AppColors.secondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      hasBoth 
                          ? "$glucoseBefore ➔ $glucoseAfter"
                          : "${glucoseBefore ?? '...'} - ${glucoseAfter ?? '...'}",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: hasBoth 
                            ? (isDecrease ? AppColors.secondary : AppColors.tertiary)
                            : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              height: 1,
              color: AppColors.backgroundLight.withValues(alpha: 0.5),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _infoItem(Icons.timer_outlined, duration),
              Container(height: 15, width: 1, color: AppColors.backgroundLight),
              _infoItem(Icons.local_fire_department_outlined, calories),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
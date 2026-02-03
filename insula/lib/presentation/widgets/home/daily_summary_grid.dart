// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DailySummaryGrid extends StatelessWidget {
  const DailySummaryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Günlük Özet",
            style: AppTextStyles.h1.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _SummaryStatCard(
                icon: Icons.directions_walk,
                iconColor: Colors.blue.shade400,
                iconBgColor: Colors.blue.shade50,
                value: "4,200",
                unit:
                    "", // Adım usually doesn't need unit textual styling separation like 'g'
                label: "Adım",
              ),
              _SummaryStatCard(
                icon: Icons.bakery_dining,
                iconColor: AppColors.tertiary,
                iconBgColor: Colors.orange.shade50,
                value: "45",
                unit: "g",
                label: "Karbonhidrat",
              ),
              _SummaryStatCard(
                icon: Icons.colorize, // syringe-like
                iconColor: Colors.purple.shade400,
                iconBgColor: Colors.purple.shade50,
                value: "12",
                unit: "Ü",
                label: "İnsülin",
              ),
              _SummaryStatCard(
                icon: Icons.bedtime,
                iconColor: Colors.indigo.shade400,
                iconBgColor: Colors.indigo.shade50,
                value: "7.5",
                unit: "s",
                label: "Uyku",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String value;
  final String unit;
  final String label;

  const _SummaryStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: AppTextStyles.h1.copyWith(fontSize: 24),
                    ),
                    if (unit.isNotEmpty)
                      TextSpan(
                        text: unit,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.label,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

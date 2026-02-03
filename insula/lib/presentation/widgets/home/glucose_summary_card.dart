// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GlucoseSummaryCard extends StatelessWidget {
  const GlucoseSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Decor (Blur) - Simplified as Flutter shadow/blur handling can be complex
          // Leaving out the absolute positioned blur for performance/simplicity for now, can add if needed as a blurred container.

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ŞEKER SEVİYESİ",
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        "Bugün, 10:42",
                        style: AppTextStyles.label.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Normal",
                          style: AppTextStyles.label.copyWith(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Value
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "105",
                    style: AppTextStyles.glucoseValue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "mg/dL",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Gradient Range Bar
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Düşük",
                          style: AppTextStyles.label.copyWith(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                      Text("Hedef Aralık",
                          style: AppTextStyles.label.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary)),
                      Text("Yüksek",
                          style: AppTextStyles.label.copyWith(
                              fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 12,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.tertiary, // Orange
                                AppColors.primary, // Yellow
                                AppColors.secondary, // Teal (Target)
                                AppColors.primary,
                                AppColors.tertiary,
                              ],
                              stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                            ),
                            color: Colors.grey.shade200, // Fallback
                          ),
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(),
                          ),
                        ),
                        // Indicator
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Positioned(
                              left: constraints.maxWidth *
                                  0.5, // Center it for now (matches 105/Normal approx)
                              top: 0,
                              bottom: 0,
                              child: Transform.translate(
                                offset: const Offset(
                                    -3, 0), // Center the marker width (6px)
                                child: Container(
                                  width: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(3),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

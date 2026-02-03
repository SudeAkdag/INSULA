// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class GlucoseTrendCard extends StatelessWidget {
  const GlucoseTrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Son 24 Saat",
                style: AppTextStyles.h1.copyWith(fontSize: 18),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "DETAYLAR",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart Area
          SizedBox(
            height: 128,
            child: Stack(
              children: [
                // Dashed Line (Target)
                Positioned(
                  top: 128 * 0.4, // 40% from top
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: DashedLinePainter(),
                  ),
                ),
                // Bars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _ChartBar(heightFactor: 0.40, color: Colors.grey.shade300),
                    _ChartBar(heightFactor: 0.55, color: Colors.grey.shade300),
                    _ChartBar(heightFactor: 0.45, color: Colors.grey.shade300),
                    _ChartBar(
                        heightFactor: 0.60,
                        color: AppColors.secondary.withOpacity(0.4)),
                    _ChartBar(
                        heightFactor: 0.75,
                        color: AppColors.secondary.withOpacity(0.6)),
                    _ChartBar(heightFactor: 0.65, color: AppColors.secondary),
                    _ChartBar(heightFactor: 0.50, color: AppColors.secondary),
                    _ChartBar(heightFactor: 0.55, color: AppColors.tertiary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final double heightFactor;
  final Color color;

  const _ChartBar({required this.heightFactor, required this.color});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        width: 24, // Approximate width
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimerDisplay extends StatelessWidget {
  final String formattedTime;
  final double progress;
  final int seconds;

  const TimerDisplay({super.key, required this.formattedTime, required this.progress, required this.seconds});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240, height: 240,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, boxShadow: [
            BoxShadow(color: AppColors.secondary.withValues(alpha: 0.05), blurRadius: 30, spreadRadius: 10)
          ]),
        ),
        SizedBox(
          width: 260, height: 260,
          child: CircularProgressIndicator(
            value: progress, strokeWidth: 8,
            color: const Color(0xFF148377),
            backgroundColor: Colors.grey.shade100,
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(formattedTime, style: const TextStyle(fontSize: 68, fontWeight: FontWeight.w900, color: Color(0xFF148377), letterSpacing: -2)),
              ),
            ),
            const Text("KALAN SÜRE", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ],
        ),
      ],
    );
  }
}
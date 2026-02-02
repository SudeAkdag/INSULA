
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DurationSelectorCard extends StatelessWidget {
  final double duration;
  final ValueChanged<double> onChanged;

  const DurationSelectorCard({super.key, required this.duration, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SÜRE", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text("${duration.toInt()} dk", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.secondary)),
                ],
              ),
              const Icon(Icons.access_time_filled, color: Color(0xFFFFC107), size: 36),
            ],
          ),
          Slider(
            value: duration,
            min: 5, max: 180,
            activeColor: const Color(0xFFFFC107),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
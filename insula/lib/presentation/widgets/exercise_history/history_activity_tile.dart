import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HistoryActivityTile extends StatelessWidget {
  final String title;
  final String time;
  final String duration;
  final String calories;
  final String glucoseChange;
  final bool isDecrease;

  const HistoryActivityTile({
    super.key,
    required this.title,
    required this.time,
    required this.duration,
    required this.calories,
    required this.glucoseChange,
    required this.isDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE0F7FA),
                child: Icon(Icons.directions_walk, color: Colors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary)),
                    Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecLight)),
                  ],
                ),
              ),
              // Kan Şekeri Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDecrease ? Colors.green.withAlpha(20) : Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text("KAN ŞEKERİ", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.cyan)),
                    Text(
                      glucoseChange, 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDecrease ? Colors.green : Colors.orange)
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem(Icons.timer_outlined, duration),
              _infoItem(Icons.local_fire_department_outlined, calories),
              TextButton(
                onPressed: () {},
                child: const Text("DETAYLAR >", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.cyan)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
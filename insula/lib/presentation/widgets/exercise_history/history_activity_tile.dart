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
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.05), 
            blurRadius: 10
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                // Koyu mavi tonu (secondary) arka plan için çok açık kullanıldı
                backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                child: const Icon(Icons.directions_walk, color: AppColors.secondary),
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
                        color: AppColors.secondary
                      )
                    ),
                    Text(
                      time, 
                      style: const TextStyle(
                        fontSize: 10, 
                        color: AppColors.textSecLight
                      )
                    ),
                  ],
                ),
              ),
              // Kan Şekeri Rozeti
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // Azalma durumunda koyu mavi (secondary), artışta turuncu (tertiary)
                  color: isDecrease 
                      ? AppColors.secondary.withValues(alpha: 0.1) 
                      : AppColors.tertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      "KAN ŞEKERİ", 
                      style: TextStyle(
                        fontSize: 7, 
                        fontWeight: FontWeight.bold, 
                        color: isDecrease ? AppColors.secondary : AppColors.tertiary
                      )
                    ),
                    Text(
                      glucoseChange, 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: FontWeight.bold, 
                        color: isDecrease ? AppColors.secondary : AppColors.tertiary
                      )
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(
              height: 1, 
              color: AppColors.backgroundLight 
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoItem(Icons.timer_outlined, duration),
              _infoItem(Icons.local_fire_department_outlined, calories),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "DETAYLAR >", 
                  style: TextStyle(
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: AppColors.secondary // Buton rengi koyu mavi yapıldı
                  )
                ),
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
        Icon(icon, size: 16, color: AppColors.textSecLight), 
        const SizedBox(width: 4),
        Text(
          label, 
          style: const TextStyle(
            fontSize: 12, 
            color: AppColors.secondary, 
            fontWeight: FontWeight.w500
          )
        ),
      ],
    );
  }
}
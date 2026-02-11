import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            // withAlpha yerine modern withValues kullanıldı
            color: AppColors.secondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "BU AY ÖZETİ", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 12,
                  color: AppColors.secondary, 
                )
              ),
              Icon(
                Icons.calendar_month, 
                // Sabit Colors.cyan yerine AppColors.primary kullanıldı
                color: AppColors.primary, 
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Egzersiz", "12"),
              _statItem("Kalori", "4,200"),
              // Vurgu rengi AppColors.primary olarak güncellendi
              _statItem("Ort. Düşüş", "25 mg/dL", valueColor: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          label, 
          style: TextStyle(
            fontSize: 10, 
            color: AppColors.textSecLight, 
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16, 
            color: valueColor ?? AppColors.secondary, 
          )
        ),
      ],
    );
  }
}
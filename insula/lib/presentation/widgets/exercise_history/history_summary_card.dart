import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HistorySummaryCard extends StatelessWidget {
  const HistorySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Colors.cyan.shade50 yerine AppColors'tan bir yüzey rengi veya yumuşak bir ton kullanıyoruz
        color: AppColors.surfaceLight, 
        borderRadius: BorderRadius.circular(20),
        // Border rengini de temadan çekiyoruz
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withAlpha(50),
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
              const Text(
                "BU AY ÖZETİ", 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 12,
                  color: AppColors.secondary, // Ana koyu renk
                )
              ),
              const Icon(
                Icons.calendar_month, 
                color: Colors.cyan, // Vurgu rengi olarak AppColors.primary da seçilebilir
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Egzersiz", "12"),
              _statItem("Kalori", "4,200"),
              // Ort. Düşüş vurgusu için AppColors içindeki ana rengi veya cyan tonunu kullanıyoruz
              _statItem("Ort. Düşüş", "25 mg/dL", valueColor: Colors.cyan),
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
          style: const TextStyle(
            fontSize: 10, 
            color: AppColors.textSecLight, // İkincil metin rengi (Gri tonları)
          )
        ),
        Text(
          value, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16, 
            color: valueColor ?? AppColors.secondary, // Değer rengi
          )
        ),
      ],
    );
  }
}
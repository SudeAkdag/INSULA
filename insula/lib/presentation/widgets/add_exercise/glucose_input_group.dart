import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GlucoseInputGroup extends StatelessWidget {
  const GlucoseInputGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.water_drop, color: Colors.redAccent, size: 20),
            SizedBox(width: 8),
            Text(
              "KAN ŞEKERİ ETKİSİ",
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textSecLight 
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Egzersiz sonrası alanı çıkarıldı, sadece öncesi kaldı
        _buildGlucoseField("EGZERSİZ ÖNCESİ"),
        const SizedBox(height: 12),
        const Text(
          "* Şeker seviyelerinizi takip etmek, egzersizin vücudunuzu nasıl etkilediğini anlamanıza yardımcı olur.",
          style: TextStyle(
            fontSize: 11, 
            color: AppColors.textSecLight, 
            fontStyle: FontStyle.italic
          ),
        ),
      ],
    );
  }

  Widget _buildGlucoseField(String label) {
    return Container(
      width: double.infinity, // Tek alan olduğu için tam genişlik verildi
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.backgroundLight), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10, 
              color: AppColors.textSecLight, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "-- mg/dL",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: AppColors.secondary 
            ),
          ),
        ],
      ),
    );
  }
}
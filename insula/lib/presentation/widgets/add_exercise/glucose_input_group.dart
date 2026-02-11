import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class GlucoseInputGroup extends StatelessWidget {
  final TextEditingController controller; // Kontrolcü eklendi

  const GlucoseInputGroup({super.key, required this.controller});

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
        _buildGlucoseInputField("EGZERSİZ ÖNCESİ"), // Input fonksiyonu güncellendi
        const SizedBox(height: 12),
        const Text(
          "* Şeker seviyelerinizi takip etmek, egzersizin vücudunuzu nasıl etkilediğini anlamanıza yardımcı olur.",
          style: TextStyle(fontSize: 11, color: AppColors.textSecLight, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildGlucoseInputField(String label) {
    return Container(
      width: double.infinity,
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
            style: const TextStyle(fontSize: 10, color: AppColors.textSecLight, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number, // Sadece sayı girişi
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.secondary),
            decoration: const InputDecoration(
               hintText: "---",
              suffixText: "mg/dL",
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
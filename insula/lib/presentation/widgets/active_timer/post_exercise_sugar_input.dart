import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PostExerciseSugarInput extends StatelessWidget {
  final TextEditingController controller;

  const PostExerciseSugarInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "EGZERSİZ SONRASI ŞEKER",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecLight, // Gri tonu için ikincil metin rengi
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            // Çok açık sarı zemin için primary renginin yüksek şeffaflı hali
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(16),
            // Sarı çerçeve
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.secondary, // Turkuaz/Koyu yeşil metin
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.water_drop_outlined, color: AppColors.secondary),
              hintText: "---",
              suffixText: "mg/dL",
              suffixStyle: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.bold,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            ),
          ),
        ),
      ],
    );
  }
}
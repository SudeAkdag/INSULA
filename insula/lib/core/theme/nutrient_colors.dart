import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Tüm beslenme ekranlarında besin değeri renklerinin
/// tek kaynaktan yönetilmesini sağlar.
class NutrientColors {
  static const Color carbs = AppColors.primary; // Sarı
  static const Color protein = AppColors.secondary; // Teal
  static Color fat = Colors.purple.shade300; // Mor
  static Color sugar = AppColors.tertiary; // Turuncu
  static Color fiber = Colors.green.shade400; // Yeşil
}

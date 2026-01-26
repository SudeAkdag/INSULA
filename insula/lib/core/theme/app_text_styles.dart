import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'SplineSans';

  // Örn: ana sayfadaki Ahmet Yılmaz yazısı
  static TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );

  // Örn: ana sayfadaki 105 mg/dL
  static TextStyle glucoseValue = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 60,
    fontWeight: FontWeight.bold,
    letterSpacing: -2,
    color: AppColors.secondary,
  );

  // Gövde
  static TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textMainLight,
  );

  // Küçük etiketler Örn: ana sayfadaki "Bugün, 10:42" yazısı
  static TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecLight,
  );
}
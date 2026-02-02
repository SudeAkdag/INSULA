import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Renk Şemasını Bağlıyoruz
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textMainLight,
        secondary: AppColors.secondary,
      ),

      // Font Stillerini Bağlıyoruz
      textTheme: TextTheme(
        displayLarge: AppTextStyles.h1,
        bodyLarge: AppTextStyles.body,
        labelSmall: AppTextStyles.label,
      ),

      // Kart Tasarımları (HTML'deki borderRadius değerlerini buraya işliyoruz)
     cardTheme: CardThemeData(
  color: AppColors.surfaceLight,
  elevation: 2,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
  ),
),

      // Navigasyon Çubuğu Teması
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.navBar,
      ),
    );
  }
}
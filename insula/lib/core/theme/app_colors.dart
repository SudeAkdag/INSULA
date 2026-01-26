import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFF2C12E);
  static const primaryDark = Color(0xFFDCB02A); // İlaç sayfası için mvp kodlarında vardı
  static const secondary = Color(0xFF024959);
  static const tertiary = Color(0xFFFF5A33);
  static const backgroundLight = Color(0xFFF5F5F5);
  static const backgroundDark = Color(0xFF012A33);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF023845);
  static const navBar = Color(0xFFE0E0E0);
  static const accent = Color(0xFFFF5A33); // Beslenme sayfası için mvp kodlarında vardı
  static const accentTeal = Color(0xFF024959); // İlaç sayfası için mvp kodlarında vardı
  static const accentOrange = Color(0xFFFF5A33); // İlaç sayfası için mvp kodlarında vardı
  static const textMainLight = Color(0xFF181811); // İlaç sayfası için mvp kodlarında vardı NavBar için
  static const textMainDark = Color(0xFFFFFFFF); // İlaç sayfası için mvp kodlarında vardı bütün sayfalardaki textlerin düzenlenmesi için bakılabilir daha sonra
  static const textSecLight = Color(0xFF555555); // İlaç sayfası için mvp kodlarında vardı bütün sayfalardaki textlerin düzenlenmesi için bakılabilir daha sonra
  static const textSecDark = Color(0xFFB0AF80); // İlaç sayfası için mvp kodlarında vardı bütün sayfalardaki textlerin düzenlenmesi için bakılabilir daha sonra

  static const MaterialColor stone = MaterialColor( // Egzersiz sayfasının mvp kodlarında vardı. muhtemelen ulaşılan milestone için kullanılıyordur.
  0xFF78716C, // stone[500] defaultunu stone[500] yapmış oldum burada.
  <int, Color>{
    50:  Color(0xFFFAFAF9),
    100: Color(0xFFF5F5F4),
    200: Color(0xFFE7E5E4),
    300: Color(0xFFD6D3D1),
    400: Color(0xFFA8A29E),
    500: Color(0xFF78716C),
    600: Color(0xFF57534E),
    700: Color(0xFF44403C),
    800: Color(0xFF292524),
    900: Color(0xFF1C1917),
  },
);
}

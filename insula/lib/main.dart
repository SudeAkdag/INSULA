import 'package:flutter/material.dart';
import 'package:insula/presentation/screens/main_screen.dart';
import 'core/theme/app_theme.dart'; // Temayı içe aktar

void main() {
  runApp(const InsulaApp());
}

class InsulaApp extends StatelessWidget {
  const InsulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insula',
      debugShowCheckedModeBanner: false,
      // Oluşturduğun merkezi temayı buraya bağlıyoruz
      theme: AppTheme.lightTheme, 
      // Uygulama açıldığında direkt Beslenme Takibi ekranı gelsin
      home: const MainScreen(), 
    );
  }
}
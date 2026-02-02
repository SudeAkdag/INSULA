// presentation/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/drawers/custom_bottom_nav.dart';
import '../widgets/drawers/custom_side_drawer.dart';
import 'nutrition_screen.dart';
import 'medication_screen.dart';
import 'exercise_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Uygulama ilk açıldığında Ana Sayfa (Index 1) gelsin istiyorsan burayı 1 yap:
  int _selectedIndex = 1; 
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // SIRALAMA KESİNLİKLE BU ŞEKİLDE OLMALI:
  final List<Widget> _screens = [
    const MedicationScreen(),                       // İndeks 0 (İlaç)
    const Center(child: Text("Ana Sayfa İçeriği")), // İndeks 1 (Ana Sayfa)
    const NutritionScreen(),                        // İndeks 2 (Beslenme)
    const ExerciseScreen(),                         // İndeks 3 (Egzersiz)
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomSideDrawer(), 
      body: Stack(
        children: [
          // Aktif Sayfa (Listenin doğru elemanını çeker)
          _screens[_selectedIndex],
          
          // Hamburger Menü Butonu
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 30),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
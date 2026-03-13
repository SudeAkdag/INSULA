// presentation/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/home_viewmodel.dart';
import 'package:insula/core/theme/app_colors.dart';
import '../widgets/drawers/custom_bottom_nav.dart';
import 'nutrition_screen.dart';
import 'medication_screen.dart';
import 'exercise_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'chatbot_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 2; // Ana Sayfa artık index 2'de

  final List<Widget> _screens = [
    const MedicationScreen(), // 0 – İlaç
    const NutritionScreen(),  // 1 – Beslenme
    const HomeScreen(),       // 2 – Ana Sayfa (ORTADA)
    ExerciseScreen(),         // 3 – Egzersiz
    const ProfileScreen(),    // 4 – Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        body: Stack(
          children: [
            _screens[_selectedIndex],
            _DraggableChatButton(),
          ],
        ),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sürüklenebilir Chatbot Floating Butonu (Snap-to-Corner)
// ---------------------------------------------------------------------------

class _DraggableChatButton extends StatefulWidget {
  @override
  State<_DraggableChatButton> createState() => _DraggableChatButtonState();
}

class _DraggableChatButtonState extends State<_DraggableChatButton> {
  double _x = 16;
  double _y = 0;
  bool _positionInitialized = false;

  // Sürükleme sırasında animasyonu kısa tut, snap'te 300ms kullan
  Duration _animDuration = Duration.zero;

  static const double _buttonSize = 56;
  static const double _edgePadding = 16;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final statusBarHeight = mediaQuery.padding.top;
    // Nav bar: 74px (bar yüksekliği) + SafeArea bottom (home indicator)
    final navBarHeight = 74.0 + mediaQuery.padding.bottom;

    if (!_positionInitialized) {
      _x = _edgePadding;
      _y = screenHeight - _buttonSize - navBarHeight - _edgePadding;
      _positionInitialized = true;
    }

    return AnimatedPositioned(
      duration: _animDuration,
      curve: Curves.easeOutCubic,
      left: _x,
      top: _y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Sürükleme sırasında animasyon süresi sıfır → gecikme yok
            _animDuration = Duration.zero;
            _x += details.delta.dx;
            _y += details.delta.dy;
            _x = _x.clamp(0.0, screenWidth - _buttonSize);
            _y = _y.clamp(statusBarHeight, screenHeight - _buttonSize - navBarHeight);
          });
        },
        onPanEnd: (_) {
          _snapToNearestCorner(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            statusBarHeight: statusBarHeight,
            navBarHeight: navBarHeight,
          );
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatbotScreen()),
          );
        },
        child: _buildButton(),
      ),
    );
  }

  void _snapToNearestCorner({
    required double screenWidth,
    required double screenHeight,
    required double statusBarHeight,
    required double navBarHeight,
  }) {
    final corners = [
      Offset(_edgePadding, statusBarHeight + _edgePadding), // Sol Üst
      Offset(screenWidth - _buttonSize - _edgePadding, statusBarHeight + _edgePadding), // Sağ Üst
      Offset(_edgePadding, screenHeight - _buttonSize - navBarHeight - _edgePadding), // Sol Alt
      Offset(screenWidth - _buttonSize - _edgePadding, screenHeight - _buttonSize - navBarHeight - _edgePadding), // Sağ Alt
    ];

    final buttonCenter = Offset(_x + _buttonSize / 2, _y + _buttonSize / 2);

    Offset nearest = corners[0];
    double minDistance = double.infinity;

    for (final corner in corners) {
      final cornerCenter = Offset(corner.dx + _buttonSize / 2, corner.dy + _buttonSize / 2);
      final distance = (buttonCenter - cornerCenter).distance;
      if (distance < minDistance) {
        minDistance = distance;
        nearest = corner;
      }
    }

    setState(() {
      // Snap animasyonu için 300ms aç
      _animDuration = const Duration(milliseconds: 300);
      _x = nearest.dx;
      _y = nearest.dy;
    });
  }

  Widget _buildButton() {
    return Container(
      width: _buttonSize,
      height: _buttonSize,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_outlined,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}
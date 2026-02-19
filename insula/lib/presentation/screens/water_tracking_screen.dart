import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class WaterTrackingScreen extends StatefulWidget {
  const WaterTrackingScreen({super.key});

  @override
  State<WaterTrackingScreen> createState() => _WaterTrackingScreenState();
}

class _WaterTrackingScreenState extends State<WaterTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  double _dailyTarget = 2500; // ml
  double _currentIntake = 1200; // ml

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addWater(double amount) {
    setState(() {
      _currentIntake += amount;
      if (_currentIntake > _dailyTarget) {
        _currentIntake =
            _dailyTarget; // Cap at target for now or let it overflow?
        // Usually overflow is fine but for wave animation mapping we need to be careful.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double percentage = (_currentIntake / _dailyTarget).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: AppColors.textMainLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Su Takibi",
          style: AppTextStyles.h1.copyWith(color: AppColors.textMainLight),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textMainLight),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Main Visualization
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer border/container
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.1),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                  ),
                  // Wave
                  ClipOval(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: AnimatedBuilder(
                        animation: _waveAnimation,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: WavePainter(
                              animationValue: _waveAnimation.value,
                              percentage: percentage,
                              color: Colors.blueAccent.withOpacity(0.8),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Text overlay
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(percentage * 100).toInt()}%",
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 48,
                          color: percentage > 0.5
                              ? Colors.white
                              : AppColors.textMainLight,
                        ),
                      ),
                      Text(
                        "${_currentIntake.toInt()} / ${_dailyTarget.toInt()} ml",
                        style: AppTextStyles.body.copyWith(
                          color: percentage > 0.5
                              ? Colors.white.withOpacity(0.9)
                              : AppColors.textSecLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Quick Add Section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    )
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hızlı Ekle",
                    style: AppTextStyles.h1,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAddButton(200, Icons.local_drink),
                      _buildQuickAddButton(350,
                          Icons.coffee), // Placeholder icon for simple glass
                      _buildQuickAddButton(500,
                          Icons.local_cafe_outlined), // Placeholder for bottle
                    ],
                  ),
                  const Spacer(),
                  // Manual Add Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Open manual input dialog
                        _addWater(100);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        "Manuel Ekle",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(double amount, IconData icon) {
    return InkWell(
      onTap: () => _addWater(amount),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 32),
            const SizedBox(height: 8),
            Text(
              "${amount.toInt()} ml",
              style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w600, color: AppColors.textMainLight),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 12, color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;
  final Color color;

  WavePainter({
    required this.animationValue,
    required this.percentage,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (percentage == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    // Wave parameters
    final double waveHeight = size.height * 0.05; // Amplitude
    final double baseHeight = size.height * (1 - percentage); // Water level

    path.moveTo(0, baseHeight);

    for (double x = 0; x <= size.width; x++) {
      double y = baseHeight +
          sin((x / size.width * 2 * pi) + animationValue) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.percentage != percentage;
  }
}

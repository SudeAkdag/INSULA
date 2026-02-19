import 'package:flutter/material.dart';
import 'package:insula/presentation/widgets/home/daily_summary_grid.dart';
import 'package:insula/presentation/widgets/home/glucose_summary_card.dart';
import 'package:insula/presentation/widgets/home/glucose_trend_card.dart';
import 'package:insula/presentation/widgets/home/home_header.dart';
import 'package:insula/presentation/widgets/home/quick_actions_section.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold kaldırıldı, MainScreen'in Scaffold'unu kullanacak
    return Container(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              HomeHeader(),
              SizedBox(height: 12),
              GlucoseSummaryCard(),
              SizedBox(height: 12),
              QuickActionsSection(),
              SizedBox(height: 24),
              DailySummaryGrid(),
              GlucoseTrendCard(),
              // Extra space for bottom nav
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

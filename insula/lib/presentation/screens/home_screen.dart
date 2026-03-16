import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/home_viewmodel.dart';
import 'package:insula/presentation/widgets/home/daily_summary_grid.dart';
import 'package:insula/presentation/widgets/home/glucose_summary_card.dart';
import 'package:insula/presentation/widgets/home/glucose_trend_card.dart';
import 'package:insula/presentation/widgets/home/home_header.dart';
import 'package:insula/presentation/widgets/home/quick_actions_section.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundLight,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeViewModel>().refresh(),
          color: AppColors.secondary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HomeHeader(),
                const SizedBox(height: 12),
                Consumer<HomeViewModel>(
                  builder: (context, vm, _) {
                    if (vm.isLoading) {
                      return const _GlucoseCardPlaceholder();
                    }
                    return const GlucoseSummaryCard();
                  },
                ),
                const SizedBox(height: 12),
                const QuickActionsSection(),
                const SizedBox(height: 24),
                const DailySummaryGrid(),
                const GlucoseTrendCard(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Yükleme sırasında kısa süre gösterilecek placeholder
class _GlucoseCardPlaceholder extends StatelessWidget {
  const _GlucoseCardPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}

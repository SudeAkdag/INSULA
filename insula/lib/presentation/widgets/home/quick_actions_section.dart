import 'package:flutter/material.dart';
import 'package:insula/presentation/widgets/home/quick_actions_row.dart';
import 'package:insula/presentation/widgets/home/water_intake_card.dart';
import 'package:insula/presentation/widgets/home/sleep_tracking_card.dart';
import 'package:insula/presentation/widgets/home/insulin_card.dart';
import 'package:insula/presentation/widgets/home/medicine_card.dart';

class QuickActionsSection extends StatefulWidget {
  const QuickActionsSection({super.key});

  @override
  State<QuickActionsSection> createState() => _QuickActionsSectionState();
}

class _QuickActionsSectionState extends State<QuickActionsSection> {
  late PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const WaterIntakeCard(),
    const SleepTrackingCard(),
    const InsulinCard(),
    const MedicineCard(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategorySelected(int index) {
    if (index == 4) {
      // Acil Durum / Emergency - do not scroll, handle separately
      // For now, maybe show a dialog or do nothing as requested "scrol açılmasın"
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        QuickActionsRow(
          selectedIndex: _selectedIndex,
          onItemTapped: _onCategorySelected,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180, // Adjust height based on card content
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _pages,
          ),
        ),
      ],
    );
  }
}

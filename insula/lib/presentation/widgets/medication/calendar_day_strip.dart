import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Seçilen ayın günlerini yatay kaydırılabilir şerit olarak gösterir.
/// Bugün, dün, yarın etiketlerini ve seçili gün vurgusunu yönetir.
/// Tarih seçildiğinde [onDateSelected] callback'i çağrılır.
class CalendarDayStrip extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarDayStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<CalendarDayStrip> createState() => _CalendarDayStripState();
}

class _CalendarDayStripState extends State<CalendarDayStrip> {
  final ScrollController _scrollController = ScrollController();
  static const double _itemWidth = 84; // fixed width for predictable scrolling
  static const double _itemSpacing = 8; // matches padding right

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant CalendarDayStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  void _scrollToSelected() {
    final now = DateTime.now();
    final selected = widget.selectedDate;

    // If selected date is not in current month, fallback to today
    final inCurrentMonth = selected.year == now.year && selected.month == now.month;
    final index = inCurrentMonth ? (selected.day - 1) : (now.day - 1);

    final double fullItem = _itemWidth + _itemSpacing;
    // Position the selected item slightly from the left (16 px padding)
    final target = (fullItem * index) - 16;
    final maxScroll = _scrollController.hasClients ? _scrollController.position.maxScrollExtent : 0.0;
    final clamped = target.clamp(0.0, maxScroll);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final days = List.generate(daysInMonth, (index) => DateTime(now.year, now.month, index + 1));

    return SizedBox(
      height: 70,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, widget.selectedDate);
          final yesterday = now.subtract(const Duration(days: 1));
          final tomorrow = now.add(const Duration(days: 1));
          final isYesterday = _isSameDay(day, yesterday);
          final isTomorrow = _isSameDay(day, tomorrow);

          String dayLabel;
          if (_isSameDay(day, now)) {
            dayLabel = 'BUGÜN';
          } else if (isYesterday) {
            dayLabel = 'DÜN';
          } else if (isTomorrow) {
            dayLabel = 'YARIN';
          } else {
            final weekdays = ['PZT', 'SAL', 'ÇAR', 'PER', 'CUM', 'CMT', 'PAZ'];
            dayLabel = weekdays[day.weekday - 1];
          }

          return Padding(
            padding: const EdgeInsets.only(right: _itemSpacing),
            child: GestureDetector(
              onTap: () => widget.onDateSelected(day),
              child: SizedBox(
                width: _itemWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayLabel,
                        style: AppTextStyles.label.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.secondary : AppColors.textSecLight,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.secondary : AppColors.textMainLight,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

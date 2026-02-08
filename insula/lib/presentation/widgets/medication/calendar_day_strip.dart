import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Seçilen ayın günlerini yatay kaydırılabilir şerit olarak gösterir.
/// Bugün, dün, yarın etiketlerini ve seçili gün vurgusunu yönetir.
/// Tarih seçildiğinde [onDateSelected] callback'i çağrılır.
class CalendarDayStrip extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const CalendarDayStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final days = List.generate(daysInMonth, (index) {
      return DateTime(now.year, now.month, index + 1);
    });

    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = _isSameDay(day, selectedDate);
          final isToday = _isSameDay(day, now);
          final yesterday = now.subtract(const Duration(days: 1));
          final tomorrow = now.add(const Duration(days: 1));
          final isYesterday = _isSameDay(day, yesterday);
          final isTomorrow = _isSameDay(day, tomorrow);

          String dayLabel;
          if (isToday) {
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
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onDateSelected(day),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.backgroundLight,
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
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textSecLight,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: AppTextStyles.body.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.textMainLight,
                        fontSize: 18,
                      ),
                    ),
                  ],
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

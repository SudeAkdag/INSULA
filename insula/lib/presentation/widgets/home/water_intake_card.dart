// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../screens/water_tracking_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/services/water_service.dart';

class WaterIntakeCard extends StatelessWidget {
  WaterIntakeCard({super.key});

  final WaterService _waterService = WaterService();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 1. Dışarıdaki StreamBuilder: Kullanıcının SU HEDEFİNİ dinler
    return StreamBuilder<double>(
      stream: _waterService.getWaterTarget(),
      builder: (context, targetSnap) {
        final double dailyTargetMl = targetSnap.data ?? 2500.0;

        // 2. İçerideki StreamBuilder: Su İÇME LOGLARINI dinler
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _waterService.getLogs(),
          builder: (context, snapshot) {
            double todayTotalMl = 0;

            if (snapshot.hasData) {
              final allLogs = snapshot.data!;
              final todayLogs =
                  allLogs.where((l) => (l['date'] as String?) == todayKey);
              todayTotalMl = todayLogs.fold<double>(
                  0,
                  (sum, item) =>
                      sum + ((item['amountMl'] as num?)?.toDouble() ?? 0));
            }

            final todayTotalLiters = todayTotalMl / 1000;
            final progressValue =
                (todayTotalMl / dailyTargetMl).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.tertiary.withOpacity(0.2), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffffffff).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.water_drop,
                          color: AppColors.tertiary, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "SU TAKİBİ",
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.tertiary, fontSize: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  todayTotalLiters.toStringAsFixed(2),
                                  style: AppTextStyles.h1.copyWith(
                                      color: AppColors.tertiary, fontSize: 36),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Litre",
                                  style: AppTextStyles.body
                                      .copyWith(color: AppColors.tertiary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.black.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.tertiary),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon:
                              const Icon(Icons.add, color: AppColors.tertiary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WaterTrackingScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

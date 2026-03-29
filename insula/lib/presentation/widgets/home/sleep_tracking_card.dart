// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../screens/sleep_tracking_screen.dart';
import '../../../data/services/sleep_service.dart';

class SleepTrackingCard extends StatelessWidget {
  SleepTrackingCard({super.key});

  final SleepService _sleepService = SleepService();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // 1. Dışarıdaki StreamBuilder: Kullanıcının belirlediği HEDEFİ dinler
    return StreamBuilder<int>(
      stream: _sleepService.getSleepTarget(),
      builder: (context, targetSnap) {
        final double targetHours = (targetSnap.data ?? 8).toDouble();

        // 2. İçerideki StreamBuilder: Uyku LOGLARINI dinler
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _sleepService.getLogs(),
          builder: (context, snapshot) {
            int todayTotalMinutes = 0;

            if (snapshot.hasData) {
              final allLogs = snapshot.data!;
              final todayLogs = allLogs
                  .where((l) => (l['date'] as String?) == todayKey)
                  .toList();

              if (todayLogs.isNotEmpty) {
                todayTotalMinutes =
                    (todayLogs.first['durationMinutes'] as num?)?.toInt() ?? 0;
              }
            }

            // 1. Saat ve dakikayı ayrı ayrı hesapla
            final int hours = todayTotalMinutes ~/
                60; // (Tam sayı bölmesi - sadece saati alır)
            final int minutes =
                todayTotalMinutes % 60; // (Mod alma - arta kalan dakikayı alır)

// 2. Çift haneli görünmesi için formatla (Örn: 9.05 veya 9.35)
            final String formattedSleepTime =
                "$hours.${minutes.toString().padLeft(2, '0')}";

// progressValue hesabını bozmamak için ondalıklı hesaplamayı tutmaya devam et
            final double todayTotalHours = todayTotalMinutes / 60.0;
            final double progressValue =
                (todayTotalHours / targetHours).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.primaryDark.withOpacity(0.2), width: 3),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.nightlight,
                              color: AppColors.primaryDark, size: 28),
                          const SizedBox(width: 8),
                          Text("UYKU TAKİBİ",
                              style: AppTextStyles.h1.copyWith(
                                  color: AppColors.primaryDark, fontSize: 20)),
                        ],
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
                                // Dinamik Uyunan / Hedef Saati

                                Text(
                                  "$formattedSleepTime / ${targetHours.toInt()}",
                                  style: AppTextStyles.h1.copyWith(
                                      color: AppColors.primaryDark,
                                      fontSize: 36),
                                ),
                                const SizedBox(width: 8),
                                Text("Saat",
                                    style: AppTextStyles.body.copyWith(
                                        color: AppColors.primaryDark)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: Colors.black.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
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
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add, color: AppColors.primary),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SleepTrackingScreen(),
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

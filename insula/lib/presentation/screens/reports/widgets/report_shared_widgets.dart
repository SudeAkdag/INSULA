// Rapor sekmelerinde ortak kullanılan yardımcı widget'lar.
// Tüm tab dosyaları bu sınıftaki static metodları kullanır.

import 'package:flutter/material.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/core/theme/app_constants.dart';

class ReportSharedWidgets {
  ReportSharedWidgets._(); // Örnekleme engellensin

  /// Boş veri durumunda gösterilen bilgilendirme widget'ı.
  static Widget buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_outlined,
                size: 64, color: AppColors.secondary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('Bu dönemde veri bulunamadı',
                style: AppTextStyles.h1.copyWith(fontSize: 18),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.label.copyWith(fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// Metrik değerini gösteren kompakt kart widget'ı.
  static Widget buildMetricCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border(left: BorderSide(color: color, width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Expanded(
                child: Text(label,
                    style: AppTextStyles.label,
                    overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          RichText(
              text: TextSpan(children: [
            TextSpan(
                text: value,
                style: AppTextStyles.h1.copyWith(fontSize: 20, color: color)),
            TextSpan(text: ' $unit', style: AppTextStyles.label),
          ])),
        ],
      ),
    );
  }

  /// Özet ve öneriler kartı.
  static Widget insightCard(List<String> insights) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text('Özet & Öneriler',
                style: AppTextStyles.h1.copyWith(fontSize: 15)),
          ]),
          const SizedBox(height: 16),
          ...insights.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          margin: const EdgeInsets.only(top: 6),
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(t,
                              style: AppTextStyles.body
                                  .copyWith(fontSize: 14, height: 1.5))),
                    ]),
              )),
        ],
      ),
    );
  }

  /// Grafik başlıklı kart container'ı.
  static Widget chartCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.h1.copyWith(fontSize: 15)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  /// Tarih formatlama yardımcısı (gün/ay).
  static String fmtDate(DateTime d) => '${d.day}/${d.month}';
}

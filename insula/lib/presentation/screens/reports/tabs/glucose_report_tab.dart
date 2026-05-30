// Kan şekeri raporu sekmesi.
// Ortalama kan şekeri, hedef aralık yüzdesi, hipoglisemi/hiperglisemi
// sayıları, trend grafiği ve ölçüm zamanı dağılımını gösterir.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/widgets/report_shared_widgets.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class GlucoseReportTab extends StatelessWidget {
  final FullReportData? fullReport;
  final ReportPeriod selectedPeriod;
  const GlucoseReportTab(
      {super.key, required this.fullReport, required this.selectedPeriod});

  /// PDF raporu için kan şekeri bölümünü oluşturur.
  static List<pw.Widget> buildPdfSection(FullReportData r, String Function(DateTime) fmtDate) {
    return [
      pw.Header(level: 1, text: 'Kan Şekeri Özeti'),
      pw.TableHelper.fromTextArray(headers: [
        'Ölçüm',
        'Değer'
      ], data: [
        ['Ort. Kan Şekeri', '${r.avgGlucose.toStringAsFixed(0)} mg/dL'],
        ['Hedef Aralığında', '%${r.glucoseInRangePercent}'],
        [
          'Hedef Aralık',
          '${r.targetGlucoseMin}–${r.targetGlucoseMax} mg/dL'
        ],
        [
          'Toplam Ölçüm',
          '${r.glucoseData.fold(0, (s, d) => s + d.readingCount)}'
        ],
      ]),
      pw.SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final r = fullReport;
    if (r == null || !r.glucoseData.any((d) => d.hasData))
      return ReportSharedWidgets.buildEmptyState(
          'Bu dönemde kan şekeri ölçümü bulunamadı.');
    final chartData = selectedPeriod.daysBack > 30
        ? ReportUtils.groupGlucoseByWeek(r.glucoseData)
        : r.glucoseData;
    final double interval =
        (chartData.length / 6).ceilToDouble().clamp(1.0, double.infinity);
    final pct = r.glucoseInRangePercent;
    final totalMeasurements =
        r.glucoseData.fold(0, (s, d) => s + d.readingCount);
    final insights = [
      pct >= 70
          ? 'Kan şekerinizin %$pct\'i hedef aralığında (${r.targetGlucoseMin}–${r.targetGlucoseMax} mg/dL). Mükemmel kontrol!'
          : pct >= 40
              ? 'Kan şekerinizin %$pct\'i hedef aralığında. Düzenli ölçüm yapmaya devam edin.'
              : 'Kan şekerinizin yalnızca %$pct\'i hedef aralığında. Doktorunuzla görüşmeniz önerilir.',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Ort. Kan Şekeri',
                      value: r.avgGlucose.toStringAsFixed(0),
                      unit: 'mg/dL',
                      color: AppColors.secondary,
                      icon: Icons.water_drop_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Hedef Aralığında',
                      value: '$pct',
                      unit: '%',
                      color: pct >= 70
                          ? Colors.green.shade400
                          : AppColors.tertiary,
                      icon: Icons.track_changes_outlined)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Toplam Ölçüm',
                      value: '$totalMeasurements',
                      unit: 'ölçüm',
                      color: AppColors.primary,
                      icon: Icons.format_list_numbered)),
              const SizedBox(width: 12),
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Hipoglisemi',
                      value: '${r.hypoCount}',
                      unit: 'kez',
                      color: Colors.orange.shade600,
                      icon: Icons.arrow_downward_rounded)),
            ]),
            const SizedBox(height: 12),
            ReportSharedWidgets.buildMetricCard(
                label: 'Hiperglisemi',
                value: '${r.hyperCount}',
                unit: 'kez',
                color: Colors.red.shade400,
                icon: Icons.arrow_upward_rounded),
          ]),
        ),
        const SizedBox(height: 16),
        if (chartData.isNotEmpty)
          ReportSharedWidgets.chartCard(
            title: 'Kan Şekeri Trendi',
            child: SizedBox(
                height: 190,
                child: LineChart(LineChartData(
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.backgroundLight, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                style: AppTextStyles.label
                                    .copyWith(fontSize: 9)))),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            interval: interval,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= chartData.length)
                                return const SizedBox.shrink();
                              return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      ReportSharedWidgets.fmtDate(
                                          chartData[i].date),
                                      style: AppTextStyles.label
                                          .copyWith(fontSize: 9)));
                            })),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  extraLinesData: ExtraLinesData(horizontalLines: [
                    HorizontalLine(
                        y: r.targetGlucoseMin.toDouble(),
                        color: AppColors.primary.withOpacity(0.5),
                        strokeWidth: 1.5,
                        dashArray: [6, 4]),
                    HorizontalLine(
                        y: r.targetGlucoseMax.toDouble(),
                        color: AppColors.primary.withOpacity(0.5),
                        strokeWidth: 1.5,
                        dashArray: [6, 4]),
                  ]),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                              e.value.hasData ? e.value.avgValue : 0))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.secondary,
                      barWidth: 2.5,
                      dotData: FlDotData(show: chartData.length <= 30),
                      belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.secondary.withOpacity(0.07)),
                    )
                  ],
                ))),
          ),
        const SizedBox(height: 16),
        if (r.glucoseContextCounts.isNotEmpty)
          _buildContextDistributionCard(r.glucoseContextCounts),
        const SizedBox(height: 16),
        ReportSharedWidgets.insightCard([
          ...insights,
          if (r.hypoCount > 0)
            'Bu dönemde ${r.hypoCount} hipoglisemi (düşük kan şekeri) olayı tespit edildi. Doktorunuza danışmanız önerilir.',
          if (r.hyperCount > 0)
            'Bu dönemde ${r.hyperCount} hiperglisemi (yüksek kan şekeri) olayı tespit edildi. İnsülin / ilaç dozunuzu gözden geçirin.',
          if (r.hypoCount == 0 && r.hyperCount == 0)
            'Bu dönemde hiç hipoglisemi veya hiperglisemi olayı yaşanmadı. Harika kontrol!',
        ]),
      ]),
    );
  }

  /// Context dağılım kartı
  Widget _buildContextDistributionCard(Map<String, int> counts) {
    final total = counts.values.fold(0, (s, v) => s + v);
    if (total == 0) return const SizedBox.shrink();

    final contextColors = <String, Color>{
      'Açlık': Colors.blue.shade400,
      'Tokluk': Colors.green.shade400,
      'Gece': Colors.indigo.shade400,
      'Yemek öncesi': Colors.teal.shade400,
      'Yemek sonrası': Colors.green.shade300,
      'Egzersiz öncesi': Colors.orange.shade400,
      'Egzersiz sonrası': Colors.deepOrange.shade400,
      'Genel': AppColors.textSecLight,
    };
    final contextIcons = <String, IconData>{
      'Açlık': Icons.no_food_rounded,
      'Tokluk': Icons.restaurant_rounded,
      'Gece': Icons.nightlight_round,
      'Yemek öncesi': Icons.restaurant_menu_rounded,
      'Yemek sonrası': Icons.restaurant_rounded,
      'Egzersiz öncesi': Icons.directions_run_rounded,
      'Egzersiz sonrası': Icons.fitness_center_rounded,
      'Genel': Icons.more_horiz_rounded,
    };

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
            const Icon(Icons.access_time_rounded,
                color: AppColors.secondary, size: 18),
            const SizedBox(width: 8),
            Text('Ölçüm Zamanı Dağılımı',
                style: AppTextStyles.h1.copyWith(fontSize: 15)),
          ]),
          const SizedBox(height: 16),
          ...counts.entries.map((entry) {
            final pct = entry.value / total;
            final color =
                contextColors[entry.key] ?? AppColors.secondary;
            final icon =
                contextIcons[entry.key] ?? Icons.circle_outlined;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: 14, color: color),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(entry.key,
                              style: AppTextStyles.label
                                  .copyWith(fontWeight: FontWeight.w600))),
                      Text(
                          '${entry.value} ölçüm  (${(pct * 100).toStringAsFixed(0)}%)',
                          style: AppTextStyles.label
                              .copyWith(fontSize: 11, color: AppColors.textSecLight)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: color.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

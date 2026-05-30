// Egzersiz raporu sekmesi.
// Egzersiz günü sayısı, toplam süre, yakılan kalori ve
// günlük kalori trend grafiğini gösterir.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/widgets/report_shared_widgets.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class ExerciseReportTab extends StatelessWidget {
  final FullReportData? fullReport;
  final ReportPeriod selectedPeriod;
  const ExerciseReportTab(
      {super.key, required this.fullReport, required this.selectedPeriod});

  /// PDF raporu için egzersiz bölümünü oluşturur.
  static List<pw.Widget> buildPdfSection(FullReportData r, String Function(DateTime) fmtDate) {
    return [
      pw.Header(level: 1, text: 'Egzersiz Özeti'),
      pw.TableHelper.fromTextArray(headers: [
        'Metrik',
        'Değer'
      ], data: [
        ['Egzersiz Günü', '${r.exerciseDaysCount} gün'],
        ['Toplam Süre', '${r.totalExerciseMinutes} dk'],
        ['Toplam Kalori', '${r.totalExerciseCalories} kcal'],
      ]),
      pw.SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final r = fullReport;
    if (r == null || r.exerciseDaysCount == 0)
      return ReportSharedWidgets.buildEmptyState(
          'Bu dönemde egzersiz verisi bulunamadı. Egzersiz ekleyerek başlayabilirsin!');
    final chartData = selectedPeriod.daysBack > 30
        ? ReportUtils.groupExerciseByWeek(r.exerciseData)
        : r.exerciseData;
    final double interval =
        (chartData.length / 6).ceilToDouble().clamp(1.0, double.infinity);
    final double maxBarY = chartData
        .map((d) => d.totalCalories.toDouble())
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final weeksInPeriod = (selectedPeriod.daysBack / 7).ceil();
    final avgDaysPerWeek = r.exerciseDaysCount / weeksInPeriod;
    final insights = [
      avgDaysPerWeek >= 3
          ? 'Haftada ortalama ${avgDaysPerWeek.toStringAsFixed(1)} gün egzersiz yaptınız. Harika!'
          : avgDaysPerWeek >= 1
              ? 'Haftada ortalama ${avgDaysPerWeek.toStringAsFixed(1)} gün egzersiz yaptınız. Daha fazlası faydalı olur.'
              : 'Bu dönemde çok az egzersiz kaydı var. Düzenli hareket sağlığınız için önemlidir.',
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
                      label: 'Egzersiz Günü',
                      value: '${r.exerciseDaysCount}',
                      unit: 'gün',
                      color: AppColors.secondary,
                      icon: Icons.calendar_today_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Toplam Süre',
                      value: '${r.totalExerciseMinutes}',
                      unit: 'dk',
                      color: AppColors.primary,
                      icon: Icons.timer_outlined)),
            ]),
            const SizedBox(height: 12),
            ReportSharedWidgets.buildMetricCard(
                label: 'Yakılan Kalori',
                value: '${r.totalExerciseCalories}',
                unit: 'kcal',
                color: AppColors.tertiary,
                icon: Icons.local_fire_department_outlined),
          ]),
        ),
        const SizedBox(height: 16),
        if (chartData.isNotEmpty)
          ReportSharedWidgets.chartCard(
            title: 'Günlük Yakılan Kalori',
            child: SizedBox(
                height: 190,
                child: BarChart(BarChartData(
                  maxY: maxBarY * 1.3,
                  gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                          color: AppColors.backgroundLight, strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
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
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                style: AppTextStyles.label
                                    .copyWith(fontSize: 9)))),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: chartData
                      .asMap()
                      .entries
                      .map((e) => BarChartGroupData(x: e.key, barRods: [
                            BarChartRodData(
                              toY: e.value.totalCalories.toDouble(),
                              color: AppColors.secondary,
                              width: (280 / chartData.length).clamp(4.0, 28.0),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(4)),
                              backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxBarY * 1.3,
                                  color: AppColors.backgroundLight),
                            ),
                          ]))
                      .toList(),
                ))),
          ),
        const SizedBox(height: 16),
        ReportSharedWidgets.insightCard(insights),
      ]),
    );
  }
}

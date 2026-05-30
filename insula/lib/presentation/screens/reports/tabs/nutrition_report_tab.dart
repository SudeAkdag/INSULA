// Beslenme raporu sekmesi.
// Karbonhidrat, kalori, protein, yağ gibi besin değerlerinin
// ortalamalarını, trendini ve dağılımını gösterir.

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/core/theme/nutrient_colors.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/widgets/report_shared_widgets.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class NutritionReportTab extends StatelessWidget {
  final FullReportData? fullReport;
  final ReportPeriod selectedPeriod;
  const NutritionReportTab(
      {super.key, required this.fullReport, required this.selectedPeriod});

  /// PDF raporu için beslenme bölümünü oluşturur.
  static List<pw.Widget> buildPdfSection(FullReportData r, String Function(DateTime) fmtDate) {
    return [
      pw.Header(level: 1, text: 'Beslenme Özeti'),
      pw.TableHelper.fromTextArray(headers: [
        'Besin',
        'Ortalama / Gün'
      ], data: [
        ['Karbonhidrat', '${r.nutrition.avgCarbs.toStringAsFixed(0)} g'],
        ['Kalori', '${r.nutrition.avgCalories.toStringAsFixed(0)} kcal'],
        ['Protein', '${r.nutrition.avgProtein.toStringAsFixed(0)} g'],
        ['Yağ', '${r.nutrition.avgFat.toStringAsFixed(0)} g'],
        ['Şeker', '${r.nutrition.avgSugar.toStringAsFixed(0)} g'],
        ['Lif', '${r.nutrition.avgFiber.toStringAsFixed(0)} g'],
        ['Karb Hedef', '${r.nutrition.carbGoal} g'],
        [
          'Hedef Uyumu',
          '%${r.nutrition.carbGoalMetPercentage.toStringAsFixed(0)}'
        ],
      ]),
      pw.SizedBox(height: 16),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final r = fullReport;
    if (r == null)
      return ReportSharedWidgets.buildEmptyState(
          'Beslenme takibine başladıktan sonra burada raporlarını görebilirsin.');
    final n = r.nutrition;
    final chartData =
        selectedPeriod.daysBack > 30 ? ReportUtils.groupNutritionByWeek(n.dailyData) : n.dailyData;
    final double interval =
        (chartData.length / 6).ceilToDouble().clamp(1.0, double.infinity);
    final nutrients = [
      NutrientBar('Karb', n.avgCarbs, NutrientColors.carbs),
      NutrientBar('Protein', n.avgProtein, NutrientColors.protein),
      NutrientBar('Yağ', n.avgFat, Colors.purple.shade300),
      NutrientBar('Şeker', n.avgSugar, NutrientColors.sugar),
      NutrientBar('Lif', n.avgFiber, Colors.green.shade400),
    ];
    final maxBarY = nutrients
        .map((x) => x.value)
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final pct = n.carbGoalMetPercentage;
    final insights = [
      pct >= 70
          ? 'Hedefinizi günlerin %${pct.toStringAsFixed(0)}\'inde karşıladınız, mükemmel!'
          : pct >= 40
              ? 'Hedefinizi günlerin %${pct.toStringAsFixed(0)}\'inde karşıladınız, iyi gidiyorsunuz.'
              : 'Hedefinizi yalnızca %${pct.toStringAsFixed(0)} oranında karşıladınız. Hedef: ${n.carbGoal}g/gün.',
      if (n.avgCarbs > n.carbGoal * 1.2)
        'Ort. karb alımı (${n.avgCarbs.toStringAsFixed(0)}g) hedefinizin belirgin üzerinde.',
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
                      label: 'Ort. Karbonhidrat',
                      value: n.avgCarbs.toStringAsFixed(0),
                      unit: 'g',
                      color: NutrientColors.carbs,
                      icon: Icons.grain)),
              const SizedBox(width: 12),
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Ort. Kalori',
                      value: n.avgCalories.toStringAsFixed(0),
                      unit: 'kcal',
                      color: AppColors.tertiary,
                      icon: Icons.local_fire_department_outlined)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Ort. Protein',
                      value: n.avgProtein.toStringAsFixed(0),
                      unit: 'g',
                      color: NutrientColors.protein,
                      icon: Icons.fitness_center_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: ReportSharedWidgets.buildMetricCard(
                      label: 'Ort. Yağ',
                      value: n.avgFat.toStringAsFixed(0),
                      unit: 'g',
                      color: Colors.purple.shade300,
                      icon: Icons.opacity_outlined)),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        if (chartData.isNotEmpty)
          ReportSharedWidgets.chartCard(
            title: 'Karbonhidrat Trendi',
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
                            reservedSize: 36,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}g',
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
                        y: n.carbGoal.toDouble(),
                        color: AppColors.tertiary.withOpacity(0.6),
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            labelResolver: (_) => 'Hedef',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.tertiary, fontSize: 10))),
                  ]),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                              e.value.hasData ? e.value.carbs : 0))
                          .toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: AppColors.secondary,
                      barWidth: 2.5,
                      dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                              radius: chartData[i].hasData ? 3 : 2,
                              color: chartData[i].hasData
                                  ? AppColors.secondary
                                  : AppColors.backgroundLight,
                              strokeWidth: 1.5,
                              strokeColor:
                                  AppColors.secondary.withOpacity(0.4))),
                      belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.secondary.withOpacity(0.08)),
                    )
                  ],
                ))),
          ),
        const SizedBox(height: 16),
        ReportSharedWidgets.chartCard(
          title: 'Ortalama Besin Dağılımı',
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
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= nutrients.length)
                              return const SizedBox.shrink();
                            return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(nutrients[i].label,
                                    style: AppTextStyles.label
                                        .copyWith(fontSize: 10)));
                          })),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}g',
                              style:
                                  AppTextStyles.label.copyWith(fontSize: 9)))),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: nutrients
                    .asMap()
                    .entries
                    .map((e) => BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(
                              toY: e.value.value,
                              color: e.value.color,
                              width: 26,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: maxBarY * 1.3,
                                  color: AppColors.backgroundLight)),
                        ]))
                    .toList(),
                barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.secondary,
                  getTooltipItem: (g, gi, rod, _) => BarTooltipItem(
                      '${nutrients[gi].label}\n${rod.toY.toStringAsFixed(1)}g',
                      AppTextStyles.label.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                )),
              ))),
        ),
        const SizedBox(height: 16),
        ReportSharedWidgets.insightCard(insights),
      ]),
    );
  }
}

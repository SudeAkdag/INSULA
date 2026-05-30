// İlaç uyumu raporu sekmesi.
// İlaç uyum oranını gauge ile, alınan/atlanan doz sayılarını
// ve önerileri gösterir.

import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/widgets/report_shared_widgets.dart';

class MedicationReportTab extends StatelessWidget {
  final FullReportData? fullReport;
  final ReportPeriod selectedPeriod;
  const MedicationReportTab(
      {super.key, required this.fullReport, required this.selectedPeriod});

  /// PDF raporu için ilaç uyumu bölümünü oluşturur.
  static List<pw.Widget> buildPdfSection(FullReportData r, String Function(DateTime) fmtDate) {
    return [
      pw.Header(level: 1, text: 'İlaç Uyumu'),
      pw.TableHelper.fromTextArray(headers: [
        'Metrik',
        'Değer'
      ], data: [
        [
          'Uyum Oranı',
          '%${r.medicationCompliance.complianceRate.toStringAsFixed(0)}'
        ],
        ['Alınan Doz', '${r.medicationCompliance.takenDoses}'],
        [
          'Atlanan Doz',
          '${r.medicationCompliance.totalDoses - r.medicationCompliance.takenDoses}'
        ],
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final r = fullReport;
    if (r == null || r.medicationCompliance.totalDoses == 0)
      return ReportSharedWidgets.buildEmptyState(
          'İlaç kaydı bulunamadı. İlaçlarınızı ekleyerek takip edebilirsiniz.');
    final c = r.medicationCompliance;
    final skipped = c.totalDoses - c.takenDoses;
    final pct = c.complianceRate;
    final insights = [
      pct >= 90
          ? 'Mükemmel uyum! İlaç takibiniz çok iyi.'
          : pct >= 70
              ? 'İyi bir uyum seviyesi. Birkaç dozu atlıyorsunuz.'
              : 'İlaç uyumunuzu artırmanız önerilir. Doktorunuzla görüşün.',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(children: [
        const SizedBox(height: 16),
        MedicationGauge(percentage: pct),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
                child: ReportSharedWidgets.buildMetricCard(
                    label: 'Alınan Doz',
                    value: '${c.takenDoses}',
                    unit: 'doz',
                    color: Colors.green.shade400,
                    icon: Icons.check_circle_outline)),
            const SizedBox(width: 12),
            Expanded(
                child: ReportSharedWidgets.buildMetricCard(
                    label: 'Atlanan Doz',
                    value: '$skipped',
                    unit: 'doz',
                    color: AppColors.tertiary,
                    icon: Icons.cancel_outlined)),
          ]),
        ),
        const SizedBox(height: 16),
        ReportSharedWidgets.insightCard(insights),
      ]),
    );
  }
}

// ── Medication Gauge ─────────────────────────────────────────────────────────

/// İlaç uyum yüzdesini dairesel gösterge ile görselleştirir.
/// Eskiden _MedicationGauge idi, dosyalar arası erişim için public yapıldı.
class MedicationGauge extends StatelessWidget {
  final double percentage;
  const MedicationGauge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: CustomPaint(
        painter: _GaugePainter(percentage: percentage),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('%${percentage.toStringAsFixed(0)}',
                style: AppTextStyles.h1
                    .copyWith(fontSize: 36, color: AppColors.secondary)),
            Text('İlaç Uyumu',
                style: AppTextStyles.label.copyWith(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  const _GaugePainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * (percentage / 100);

    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = AppColors.backgroundLight
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round);
    canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.percentage != percentage;
}

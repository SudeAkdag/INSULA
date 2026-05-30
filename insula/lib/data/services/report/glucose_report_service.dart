// Kan şekeri raporu veri servisi.
// Firestore'dan kan şekeri ölçümlerini çekip GlucoseReportResult olarak döndürür.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class GlucoseReportService {
  GlucoseReportService._();

  /// Belirtilen kullanıcı ve dönem için kan şekeri verilerini yükler.
  static Future<GlucoseReportResult> loadGlucoseData({
    required String uid,
    required int daysBack,
    required int targetMin,
    required int targetMax,
  }) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: daysBack - 1));

    final glucoseSnap = await fs
        .collection('users')
        .doc(uid)
        .collection('glucoseReadings')
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .get();

    final glucoseByDay = <String, List<double>>{};
    int inRange = 0, totalReadings = 0;
    int hypoCount = 0, hyperCount = 0;
    final contextCounts = <String, int>{};
    for (final doc in glucoseSnap.docs) {
      final d = doc.data() as Map<String, dynamic>;
      final ts = d['timestamp'];
      DateTime? dt;
      if (ts is Timestamp) dt = ts.toDate();
      if (dt == null) continue;
      final key = ReportUtils.dateKey(dt);
      final val = (d['value'] as num?)?.toDouble() ?? 0;
      glucoseByDay.putIfAbsent(key, () => []).add(val);
      totalReadings++;
      if (val >= targetMin && val <= targetMax) {
        inRange++;
      } else if (val < targetMin) {
        hypoCount++;
      } else {
        hyperCount++;
      }
      // Context etiketini grupla (Açlık / Tokluk / Gece)
      final rawCtx = ((d['context'] as String?) ?? '').trim();
      final String ctxLabel;
      if (rawCtx == 'Açlık' || rawCtx == 'Yemek öncesi') {
        ctxLabel = 'Açlık';
      } else if (rawCtx == 'Yemek sonrası') {
        ctxLabel = 'Tokluk';
      } else if (rawCtx == 'Gece') {
        ctxLabel = 'Gece';
      } else {
        ctxLabel = rawCtx.isEmpty ? 'Genel' : rawCtx;
      }
      contextCounts[ctxLabel] = (contextCounts[ctxLabel] ?? 0) + 1;
    }

    final glucoseList = <DailyGlucose>[];
    double glucoseSum = 0;
    for (int i = daysBack - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final vals = glucoseByDay[ReportUtils.dateKey(date)];
      if (vals == null || vals.isEmpty) {
        glucoseList.add(DailyGlucose(
            date: date,
            avgValue: 0,
            minValue: 0,
            maxValue: 0,
            readingCount: 0,
            hasData: false));
      } else {
        final avg = vals.fold(0.0, (a, b) => a + b) / vals.length;
        glucoseSum += avg;
        glucoseList.add(DailyGlucose(
          date: date,
          avgValue: avg,
          minValue: vals.reduce((a, b) => a < b ? a : b),
          maxValue: vals.reduce((a, b) => a > b ? a : b),
          readingCount: vals.length,
          hasData: true,
        ));
      }
    }
    final daysWithGlucose = glucoseList.where((d) => d.hasData).length;
    final avgGlucose =
        daysWithGlucose == 0 ? 0.0 : glucoseSum / daysWithGlucose;
    final inRangePct =
        totalReadings == 0 ? 0 : (inRange * 100 ~/ totalReadings);

    return GlucoseReportResult(
      glucoseData: glucoseList,
      avgGlucose: avgGlucose,
      glucoseInRangePercent: inRangePct,
      hypoCount: hypoCount,
      hyperCount: hyperCount,
      glucoseContextCounts: contextCounts,
    );
  }
}

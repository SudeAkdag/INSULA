// Egzersiz raporu veri servisi.
// Firestore'dan egzersiz verilerini çekip ExerciseReportResult olarak döndürür.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class ExerciseReportService {
  ExerciseReportService._();

  /// Belirtilen kullanıcı ve dönem için egzersiz verilerini yükler.
  static Future<ExerciseReportResult> loadExerciseData({
    required String uid,
    required int daysBack,
  }) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = today.subtract(Duration(days: daysBack - 1));

    // Egzersiz: composite index sorununu önlemek için sadece isCompleted filtresi kullan,
    // tarih filtresi Dart tarafında yapılır.
    final exerciseSnap = await fs
        .collection('users')
        .doc(uid)
        .collection('exercises')
        .where('isCompleted', isEqualTo: true)
        .get();

    final exerciseByDay = <String, List<Map<String, dynamic>>>{};
    for (final doc in exerciseSnap.docs) {
      final d = doc.data() as Map<String, dynamic>;
      final dateStr = d['date'] as String?;
      if (dateStr == null) continue;
      try {
        final dt = DateTime.parse(dateStr);
        if (!dt.isBefore(startDate)) {
          exerciseByDay.putIfAbsent(ReportUtils.dateKey(dt), () => []).add(d);
        }
      } catch (_) {}
    }

    final exerciseList = <DailyExercise>[];
    int totalExMins = 0, totalExCal = 0;
    for (int i = daysBack - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final entries = exerciseByDay[ReportUtils.dateKey(date)];
      if (entries == null || entries.isEmpty) {
        exerciseList.add(DailyExercise(
            date: date, totalCalories: 0, totalMinutes: 0, hasData: false));
      } else {
        int mins = 0, cal = 0;
        for (final e in entries) {
          mins += (e['durationMinutes'] as num?)?.toInt() ?? 0;
          cal += (e['estimatedCalories'] as num?)?.toInt() ?? 0;
        }
        totalExMins += mins;
        totalExCal += cal;
        exerciseList.add(DailyExercise(
            date: date,
            totalCalories: cal,
            totalMinutes: mins,
            hasData: true));
      }
    }
    final exerciseDays = exerciseList.where((d) => d.hasData).length;

    return ExerciseReportResult(
      exerciseData: exerciseList,
      totalExerciseMinutes: totalExMins,
      totalExerciseCalories: totalExCal,
      exerciseDaysCount: exerciseDays,
    );
  }
}

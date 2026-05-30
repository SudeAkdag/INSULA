// Rapor modülleri tarafından ortaklaşa kullanılan yardımcı fonksiyonlar.
// Haftalık gruplama ve tarih anahtarı oluşturma işlemlerini içerir.

import 'package:insula/presentation/screens/reports/models/report_models.dart';

class ReportUtils {
  ReportUtils._(); // Örnekleme engellensin

  /// Firestore doküman anahtarı olarak kullanılan tarih formatı (yyyy-MM-dd).
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Beslenme verilerini haftalık ortalamalara gruplar.
  static List<DailyNutrition> groupNutritionByWeek(List<DailyNutrition> data) {
    final grouped = <DailyNutrition>[];
    for (int i = 0; i < data.length; i += 7) {
      final week = data.skip(i).take(7).where((d) => d.hasData).toList();
      if (week.isEmpty) continue;
      double avg(double Function(DailyNutrition) f) =>
          week.fold(0.0, (s, d) => s + f(d)) / week.length;
      grouped.add(DailyNutrition(
        date: data[i].date,
        carbs: avg((d) => d.carbs),
        calories: avg((d) => d.calories),
        protein: avg((d) => d.protein),
        fat: avg((d) => d.fat),
        sugar: avg((d) => d.sugar),
        fiber: avg((d) => d.fiber),
        hasData: true,
      ));
    }
    return grouped;
  }

  /// Kan şekeri verilerini haftalık ortalamalara gruplar.
  static List<DailyGlucose> groupGlucoseByWeek(List<DailyGlucose> data) {
    final grouped = <DailyGlucose>[];
    for (int i = 0; i < data.length; i += 7) {
      final week = data.skip(i).take(7).where((d) => d.hasData).toList();
      if (week.isEmpty) continue;
      final avg = week.fold(0.0, (s, d) => s + d.avgValue) / week.length;
      grouped.add(DailyGlucose(
        date: data[i].date,
        avgValue: avg,
        minValue: week.map((d) => d.minValue).reduce((a, b) => a < b ? a : b),
        maxValue: week.map((d) => d.maxValue).reduce((a, b) => a > b ? a : b),
        readingCount: week.fold(0, (s, d) => s + d.readingCount),
        hasData: true,
      ));
    }
    return grouped;
  }

  /// Egzersiz verilerini haftalık toplamlara gruplar.
  static List<DailyExercise> groupExerciseByWeek(List<DailyExercise> data) {
    final grouped = <DailyExercise>[];
    for (int i = 0; i < data.length; i += 7) {
      final week = data.skip(i).take(7).where((d) => d.hasData).toList();
      if (week.isEmpty) continue;
      grouped.add(DailyExercise(
        date: data[i].date,
        totalCalories: week.fold(0, (s, d) => s + d.totalCalories),
        totalMinutes: week.fold(0, (s, d) => s + d.totalMinutes),
        hasData: true,
      ));
    }
    return grouped;
  }
}

// Rapor ekranı için veri modelleri, enum'lar ve extension'lar.
// Tüm tab dosyaları ve ana ekran bu dosyadaki modelleri kullanır.

import 'package:flutter/material.dart';

// ── Enum ──────────────────────────────────────────────────────────────────────

enum ReportPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  biannual,
  annual,
  biennial
}

extension ReportPeriodExt on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.daily:
        return 'Günlük';
      case ReportPeriod.weekly:
        return 'Haftalık';
      case ReportPeriod.monthly:
        return 'Aylık';
      case ReportPeriod.quarterly:
        return '3 Aylık';
      case ReportPeriod.biannual:
        return '6 Aylık';
      case ReportPeriod.annual:
        return '1 Yıllık';
      case ReportPeriod.biennial:
        return '2 Yıllık';
    }
  }

  int get daysBack {
    switch (this) {
      case ReportPeriod.daily:
        return 1;
      case ReportPeriod.weekly:
        return 7;
      case ReportPeriod.monthly:
        return 30;
      case ReportPeriod.quarterly:
        return 90;
      case ReportPeriod.biannual:
        return 180;
      case ReportPeriod.annual:
        return 365;
      case ReportPeriod.biennial:
        return 730;
    }
  }
}

// ── Modeller ─────────────────────────────────────────────────────────────────

class DailyNutrition {
  final DateTime date;
  final double carbs, calories, protein, fat, sugar, fiber;
  final bool hasData;
  const DailyNutrition({
    required this.date,
    required this.carbs,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.hasData,
  });
}

class ReportData {
  final List<DailyNutrition> dailyData;
  final double avgCarbs, avgCalories, avgProtein, avgFat, avgSugar, avgFiber;
  final int totalDaysWithData, carbGoalMetDays, carbGoal;
  const ReportData({
    required this.dailyData,
    required this.avgCarbs,
    required this.avgCalories,
    required this.avgProtein,
    required this.avgFat,
    required this.avgSugar,
    required this.avgFiber,
    required this.totalDaysWithData,
    required this.carbGoalMetDays,
    required this.carbGoal,
  });
  double get carbGoalMetPercentage =>
      totalDaysWithData == 0 ? 0 : carbGoalMetDays / totalDaysWithData * 100;
}

class DailyGlucose {
  final DateTime date;
  final double avgValue, minValue, maxValue;
  final int readingCount;
  final bool hasData;
  const DailyGlucose({
    required this.date,
    required this.avgValue,
    required this.minValue,
    required this.maxValue,
    required this.readingCount,
    required this.hasData,
  });
}

class DailyExercise {
  final DateTime date;
  final int totalCalories, totalMinutes;
  final bool hasData;
  const DailyExercise({
    required this.date,
    required this.totalCalories,
    required this.totalMinutes,
    required this.hasData,
  });
}

class MedicationCompliance {
  final int totalDoses, takenDoses;
  final double complianceRate;
  const MedicationCompliance({
    required this.totalDoses,
    required this.takenDoses,
    required this.complianceRate,
  });
}

/// Kan şekeri rapor servisinin döndürdüğü sonuç sınıfı.
class GlucoseReportResult {
  final List<DailyGlucose> glucoseData;
  final double avgGlucose;
  final int glucoseInRangePercent;
  final int hypoCount;
  final int hyperCount;
  final Map<String, int> glucoseContextCounts;
  const GlucoseReportResult({
    required this.glucoseData,
    required this.avgGlucose,
    required this.glucoseInRangePercent,
    required this.hypoCount,
    required this.hyperCount,
    required this.glucoseContextCounts,
  });
}

/// Egzersiz rapor servisinin döndürdüğü sonuç sınıfı.
class ExerciseReportResult {
  final List<DailyExercise> exerciseData;
  final int totalExerciseMinutes;
  final int totalExerciseCalories;
  final int exerciseDaysCount;
  const ExerciseReportResult({
    required this.exerciseData,
    required this.totalExerciseMinutes,
    required this.totalExerciseCalories,
    required this.exerciseDaysCount,
  });
}

class FullReportData {
  final ReportData nutrition;
  final List<DailyGlucose> glucoseData;
  final List<DailyExercise> exerciseData;
  final MedicationCompliance medicationCompliance;
  final double avgGlucose;
  final int glucoseInRangePercent;
  final int targetGlucoseMin, targetGlucoseMax;
  final int totalExerciseMinutes, totalExerciseCalories, exerciseDaysCount;
  // Yeni: hipoglisemi / hiperglisemi sayıları
  final int hypoCount;
  final int hyperCount;
  // Yeni: context bazında ölçüm sayıları
  final Map<String, int> glucoseContextCounts;
  const FullReportData({
    required this.nutrition,
    required this.glucoseData,
    required this.exerciseData,
    required this.medicationCompliance,
    required this.avgGlucose,
    required this.glucoseInRangePercent,
    required this.targetGlucoseMin,
    required this.targetGlucoseMax,
    required this.totalExerciseMinutes,
    required this.totalExerciseCalories,
    required this.exerciseDaysCount,
    this.hypoCount = 0,
    this.hyperCount = 0,
    this.glucoseContextCounts = const {},
  });
}

/// Besin dağılımı bar grafiği için yardımcı model.
/// Eskiden _NutrientBar idi, dosyalar arası erişim için public yapıldı.
class NutrientBar {
  final String label;
  final double value;
  final Color color;
  const NutrientBar(this.label, this.value, this.color);
}

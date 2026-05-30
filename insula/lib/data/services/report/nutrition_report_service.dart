// Beslenme raporu veri servisi.
// Firestore'dan günlük beslenme verilerini çekip ReportData olarak döndürür.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/utils/report_utils.dart';

class NutritionReportService {
  NutritionReportService._();

  /// Belirtilen kullanıcı ve dönem için beslenme verilerini yükler.
  static Future<ReportData> loadNutritionData({
    required String uid,
    required int daysBack,
    required int carbGoal,
  }) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Beslenme: günlük döngü (ayrı await – tip çakışmasını önler)
    // TODO: Büyük periyotlar için batch okuma optimize edilebilir
    final nutritionList = <DailyNutrition>[];
    for (int i = daysBack - 1; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      try {
        final snap = await fs
            .collection('users')
            .doc(uid)
            .collection('meals')
            .doc(ReportUtils.dateKey(date))
            .collection('mealEntries')
            .get();
        if (snap.docs.isEmpty) {
          nutritionList.add(DailyNutrition(
              date: date,
              carbs: 0,
              calories: 0,
              protein: 0,
              fat: 0,
              sugar: 0,
              fiber: 0,
              hasData: false));
        } else {
          double c = 0, cal = 0, p = 0, f = 0, s = 0, fi = 0;
          for (final doc in snap.docs) {
            final d = doc.data() as Map<String, dynamic>;
            c += (d['carbs'] as num?)?.toDouble() ?? 0;
            cal += (d['calories'] as num?)?.toDouble() ?? 0;
            p += (d['protein'] as num?)?.toDouble() ?? 0;
            f += (d['fat'] as num?)?.toDouble() ?? 0;
            s += (d['sugar'] as num?)?.toDouble() ?? 0;
            fi += (d['fiber'] as num?)?.toDouble() ?? 0;
          }
          nutritionList.add(DailyNutrition(
              date: date,
              carbs: c,
              calories: cal,
              protein: p,
              fat: f,
              sugar: s,
              fiber: fi,
              hasData: true));
        }
      } catch (e) {
        debugPrint('Beslenme günü yüklenemedi ($date): $e');
        nutritionList.add(DailyNutrition(
            date: date,
            carbs: 0,
            calories: 0,
            protein: 0,
            fat: 0,
            sugar: 0,
            fiber: 0,
            hasData: false));
      }
    }

    // ── Beslenme hesapla ────────────────────────────────────────────────
    final daysWithData = nutritionList.where((d) => d.hasData).toList();
    final count = daysWithData.length;
    double nSum(double Function(DailyNutrition) f) =>
        count == 0 ? 0 : daysWithData.fold(0.0, (s, d) => s + f(d)) / count;
    final carbGoalMetDays =
        daysWithData.where((d) => d.carbs > 0 && d.carbs <= carbGoal).length;

    return ReportData(
      dailyData: nutritionList,
      avgCarbs: nSum((d) => d.carbs),
      avgCalories: nSum((d) => d.calories),
      avgProtein: nSum((d) => d.protein),
      avgFat: nSum((d) => d.fat),
      avgSugar: nSum((d) => d.sugar),
      avgFiber: nSum((d) => d.fiber),
      totalDaysWithData: count,
      carbGoalMetDays: carbGoalMetDays,
      carbGoal: carbGoal,
    );
  }
}

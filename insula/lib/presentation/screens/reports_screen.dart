import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/core/theme/app_constants.dart';
import 'package:insula/core/theme/nutrient_colors.dart';

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

class FullReportData {
  final ReportData nutrition;
  final List<DailyGlucose> glucoseData;
  final List<DailyExercise> exerciseData;
  final MedicationCompliance medicationCompliance;
  final double avgGlucose;
  final int glucoseInRangePercent;
  final int targetGlucoseMin, targetGlucoseMax;
  final int totalExerciseMinutes, totalExerciseCalories, exerciseDaysCount;
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
  });
}

class _NutrientBar {
  final String label;
  final double value;
  final Color color;
  const _NutrientBar(this.label, this.value, this.color);
}

// ── Ekran ────────────────────────────────────────────────────────────────────

class ReportsScreen extends StatefulWidget {
 final int initialTab;
  const ReportsScreen({super.key, this.initialTab = 0});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  ReportPeriod _selectedPeriod = ReportPeriod.daily;
  FullReportData? _fullReport;
  bool _isLoading = false;
  late TabController _tabController;

 @override
void initState() {
  super.initState();
  // Dışarıdan gelen initialTab değerini başlangıç indeksi olarak atıyoruz
  _tabController = TabController(
    length: 4, 
    vsync: this, 
    initialIndex: widget.initialTab // Bu satırı ekle
  );
  _loadData();
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<DailyNutrition> _groupByWeek(List<DailyNutrition> data) {
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final fs = FirebaseFirestore.instance;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final startDate =
          today.subtract(Duration(days: _selectedPeriod.daysBack - 1));
      final daysBack = _selectedPeriod.daysBack;

      // Firestore sorgularını paralel başlat
      final userDocFuture = fs.collection('users').doc(uid).get();
      final medicationsFuture =
          fs.collection('users').doc(uid).collection('medications').get();
      final glucoseFuture = fs
          .collection('users')
          .doc(uid)
          .collection('glucoseReadings')
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();
      // Egzersiz: composite index sorununu önlemek için sadece isCompleted filtresi kullan,
      // tarih filtresi Dart tarafında yapılır.
      final exerciseFuture = fs
          .collection('users')
          .doc(uid)
          .collection('exercises')
          .where('isCompleted', isEqualTo: true)
          .get();

      // Firestore sorgularını paralel bekle (tip güvenli)
      final firestoreResults = await Future.wait<dynamic>([
        userDocFuture,
        medicationsFuture,
        glucoseFuture,
        exerciseFuture,
      ]);

      final userDoc = firestoreResults[0] as DocumentSnapshot;
      final medicationsSnap = firestoreResults[1] as QuerySnapshot;
      final glucoseSnap = firestoreResults[2] as QuerySnapshot;
      final exerciseSnap = firestoreResults[3] as QuerySnapshot;

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
              .doc(_dateKey(date))
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

      final userData = userDoc.data() as Map<String, dynamic>?;
      final carbGoal = (userData?['dailyCarbGoal'] as num?)?.toInt() ?? 200;
      final targetMin = (userData?['targetGlucoseMin'] as num?)?.toInt() ?? 70;
      final targetMax = (userData?['targetGlucoseMax'] as num?)?.toInt() ?? 140;

      // ── Beslenme hesapla ────────────────────────────────────────────────
      final daysWithData = nutritionList.where((d) => d.hasData).toList();
      final count = daysWithData.length;
      double nSum(double Function(DailyNutrition) f) =>
          count == 0 ? 0 : daysWithData.fold(0.0, (s, d) => s + f(d)) / count;
      final carbGoalMetDays =
          daysWithData.where((d) => d.carbs > 0 && d.carbs <= carbGoal).length;
      final nutrition = ReportData(
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

      // ── Kan şekeri hesapla ──────────────────────────────────────────────
      final glucoseByDay = <String, List<double>>{};
      int inRange = 0, totalReadings = 0;
      for (final doc in glucoseSnap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final ts = d['timestamp'];
        DateTime? dt;
        if (ts is Timestamp) dt = ts.toDate();
        if (dt == null) continue;
        final key = _dateKey(dt);
        final val = (d['value'] as num?)?.toDouble() ?? 0;
        glucoseByDay.putIfAbsent(key, () => []).add(val);
        totalReadings++;
        if (val >= targetMin && val <= targetMax) inRange++;
      }
      final glucoseList = <DailyGlucose>[];
      double glucoseSum = 0;
      for (int i = daysBack - 1; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final vals = glucoseByDay[_dateKey(date)];
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

      // ── Egzersiz hesapla ────────────────────────────────────────────────
      final exerciseByDay = <String, List<Map<String, dynamic>>>{};
      for (final doc in exerciseSnap.docs) {
        final d = doc.data() as Map<String, dynamic>;
        final dateStr = d['date'] as String?;
        if (dateStr == null) continue;
        try {
          final dt = DateTime.parse(dateStr);
          if (!dt.isBefore(startDate)) {
            exerciseByDay.putIfAbsent(_dateKey(dt), () => []).add(d);
          }
        } catch (_) {}
      }
      final exerciseList = <DailyExercise>[];
      int totalExMins = 0, totalExCal = 0;
      for (int i = daysBack - 1; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        final entries = exerciseByDay[_dateKey(date)];
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

      // ── İlaç uyumu ─────────────────────────────────────────────────────
      int totalDoses = 0, takenDoses = 0;
      for (final doc in medicationsSnap.docs) {
        final flags =
            ((doc.data() as Map)['takenFlags'] as List?)?.cast<bool>() ?? [];
        totalDoses += flags.length;
        takenDoses += flags.where((f) => f).length;
      }
      final compliance = MedicationCompliance(
        totalDoses: totalDoses,
        takenDoses: takenDoses,
        complianceRate: totalDoses == 0 ? 0 : takenDoses / totalDoses * 100,
      );

      if (mounted) {
        setState(() {
          _fullReport = FullReportData(
            nutrition: nutrition,
            glucoseData: glucoseList,
            exerciseData: exerciseList,
            medicationCompliance: compliance,
            avgGlucose: avgGlucose,
            glucoseInRangePercent: inRangePct,
            targetGlucoseMin: targetMin,
            targetGlucoseMax: targetMax,
            totalExerciseMinutes: totalExMins,
            totalExerciseCalories: totalExCal,
            exerciseDaysCount: exerciseDays,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ReportsScreen._loadData hata: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: AppColors.secondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Sağlık Raporu',
            style: AppTextStyles.h1.copyWith(fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            color: AppColors.secondary,
            tooltip: 'PDF İndir',
            onPressed: _isLoading || _fullReport == null ? null : _exportPdf,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecLight,
          labelStyle: AppTextStyles.label
              .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.restaurant, size: 18), text: 'Beslenme'),
            Tab(icon: Icon(Icons.water_drop, size: 18), text: 'Kan Şekeri'),
            Tab(icon: Icon(Icons.directions_run, size: 18), text: 'Egzersiz'),
            Tab(icon: Icon(Icons.medication, size: 18), text: 'İlaç'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildPeriodSelector(),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildNutritionTab(),
                      _buildGlucoseTab(),
                      _buildExerciseTab(),
                      _buildMedicationTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Periyot Seçici ────────────────────────────────────────────────────────

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ReportPeriod.values.map((p) {
          final sel = p == _selectedPeriod;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.label),
              selected: sel,
              onSelected: (_) {
                setState(() => _selectedPeriod = p);
                _loadData();
              },
              selectedColor: AppColors.secondary,
              backgroundColor: AppColors.surfaceLight,
              labelStyle: TextStyle(
                  color: sel ? Colors.white : AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              shape: const StadiumBorder(),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Shared Helpers ────────────────────────────────────────────────────────

  Widget _buildEmptyState(String message) {
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

  Widget _buildMetricCard({
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

  Widget _insightCard(List<String> insights) {
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

  Widget _chartCard({required String title, required Widget child}) {
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

  String _fmtDate(DateTime d) => '${d.day}/${d.month}';

  // ── TAB 1: Beslenme ───────────────────────────────────────────────────────

  Widget _buildNutritionTab() {
    final r = _fullReport;
    if (r == null)
      return _buildEmptyState(
          'Beslenme takibine başladıktan sonra burada raporlarını görebilirsin.');
    final n = r.nutrition;
    final chartData =
        _selectedPeriod.daysBack > 30 ? _groupByWeek(n.dailyData) : n.dailyData;
    final double interval =
        (chartData.length / 6).ceilToDouble().clamp(1.0, double.infinity);
    final nutrients = [
      _NutrientBar('Karb', n.avgCarbs, NutrientColors.carbs),
      _NutrientBar('Protein', n.avgProtein, NutrientColors.protein),
      _NutrientBar('Yağ', n.avgFat, Colors.purple.shade300),
      _NutrientBar('Şeker', n.avgSugar, NutrientColors.sugar),
      _NutrientBar('Lif', n.avgFiber, Colors.green.shade400),
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
                  child: _buildMetricCard(
                      label: 'Ort. Karbonhidrat',
                      value: n.avgCarbs.toStringAsFixed(0),
                      unit: 'g',
                      color: NutrientColors.carbs,
                      icon: Icons.grain)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricCard(
                      label: 'Ort. Kalori',
                      value: n.avgCalories.toStringAsFixed(0),
                      unit: 'kcal',
                      color: AppColors.tertiary,
                      icon: Icons.local_fire_department_outlined)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _buildMetricCard(
                      label: 'Ort. Protein',
                      value: n.avgProtein.toStringAsFixed(0),
                      unit: 'g',
                      color: NutrientColors.protein,
                      icon: Icons.fitness_center_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricCard(
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
          _chartCard(
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
                                  child: Text(_fmtDate(chartData[i].date),
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
        _chartCard(
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
        _insightCard(insights),
      ]),
    );
  }

  // ── TAB 2: Kan Şekeri ────────────────────────────────────────────────────

  Widget _buildGlucoseTab() {
    final r = _fullReport;
    if (r == null || !r.glucoseData.any((d) => d.hasData))
      return _buildEmptyState('Bu dönemde kan şekeri ölçümü bulunamadı.');
    final chartData = _selectedPeriod.daysBack > 30
        ? _groupGlucoseByWeek(r.glucoseData)
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
                  child: _buildMetricCard(
                      label: 'Ort. Kan Şekeri',
                      value: r.avgGlucose.toStringAsFixed(0),
                      unit: 'mg/dL',
                      color: AppColors.secondary,
                      icon: Icons.water_drop_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricCard(
                      label: 'Hedef Aralığında',
                      value: '$pct',
                      unit: '%',
                      color: pct >= 70
                          ? Colors.green.shade400
                          : AppColors.tertiary,
                      icon: Icons.track_changes_outlined)),
            ]),
            const SizedBox(height: 12),
            _buildMetricCard(
                label: 'Toplam Ölçüm',
                value: '$totalMeasurements',
                unit: 'ölçüm',
                color: AppColors.primary,
                icon: Icons.format_list_numbered),
          ]),
        ),
        const SizedBox(height: 16),
        if (chartData.isNotEmpty)
          _chartCard(
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
                                  child: Text(_fmtDate(chartData[i].date),
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
        _insightCard(insights),
      ]),
    );
  }

  List<DailyGlucose> _groupGlucoseByWeek(List<DailyGlucose> data) {
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

  // ── TAB 3: Egzersiz ──────────────────────────────────────────────────────

  Widget _buildExerciseTab() {
    final r = _fullReport;
    if (r == null || r.exerciseDaysCount == 0)
      return _buildEmptyState(
          'Bu dönemde egzersiz verisi bulunamadı. Egzersiz ekleyerek başlayabilirsin!');
    final chartData = _selectedPeriod.daysBack > 30
        ? _groupExerciseByWeek(r.exerciseData)
        : r.exerciseData;
    final double interval =
        (chartData.length / 6).ceilToDouble().clamp(1.0, double.infinity);
    final double maxBarY = chartData
        .map((d) => d.totalCalories.toDouble())
        .reduce((a, b) => a > b ? a : b)
        .clamp(1.0, double.infinity);
    final weeksInPeriod = (_selectedPeriod.daysBack / 7).ceil();
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
                  child: _buildMetricCard(
                      label: 'Egzersiz Günü',
                      value: '${r.exerciseDaysCount}',
                      unit: 'gün',
                      color: AppColors.secondary,
                      icon: Icons.calendar_today_outlined)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildMetricCard(
                      label: 'Toplam Süre',
                      value: '${r.totalExerciseMinutes}',
                      unit: 'dk',
                      color: AppColors.primary,
                      icon: Icons.timer_outlined)),
            ]),
            const SizedBox(height: 12),
            _buildMetricCard(
                label: 'Yakılan Kalori',
                value: '${r.totalExerciseCalories}',
                unit: 'kcal',
                color: AppColors.tertiary,
                icon: Icons.local_fire_department_outlined),
          ]),
        ),
        const SizedBox(height: 16),
        // ... (üstteki kartlar aynı kalabilir)

if (chartData.isNotEmpty)
  _chartCard(
    title: 'Günlük Yakılan Kalori',
    child: SizedBox(
      height: 220, // Tarihlerin sığması için yüksekliği biraz artırdık
      child: BarChart(
        BarChartData(
          maxY: maxBarY * 1.3,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.backgroundLight,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            // ALT TARİH ETİKETLERİ
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Tarihlerin dikey sığması için alan açtık
                // Interval değerini veriye göre dinamik seçiyoruz
                interval: chartData.length > 10 ? (chartData.length / 5) : 1, 
              getTitlesWidget: (double v, TitleMeta meta) { // Meta parametresini ekledik
  final i = v.toInt();
  if (i < 0 || i >= chartData.length) return const SizedBox.shrink();
  
  return SideTitleWidget(
    meta: meta, // axisSide yerine doğrudan meta objesini veriyoruz
    space: 8,
    child: Transform.rotate(
      angle: -0.5,
      child: Text(
        _fmtDate(chartData[i].date),
        style: AppTextStyles.label.copyWith(fontSize: 10),
      ),
    ),
  );
},
              ),
            ),
            // SOL KALORİ ETİKETLERİ
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => Text(
                  '${v.toInt()}',
                  style: AppTextStyles.label.copyWith(fontSize: 10),
                ),
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: chartData.asMap().entries.map((e) {
            // Bar genişliğini dinamik hesapla
            double barWidth = (MediaQuery.of(context).size.width / (chartData.length * 1.5)).clamp(4.0, 20.0);
            
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.totalCalories.toDouble(),
                  color: AppColors.secondary,
                  width: barWidth,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  // Arka plan barları (isteğe bağlı, görseldeki gri alanlar)
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxBarY * 1.3,
                    color: AppColors.backgroundLight.withOpacity(0.5),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    ),
  ),
        const SizedBox(height: 16),
        _insightCard(insights),
      ]),
    );
  }

  List<DailyExercise> _groupExerciseByWeek(List<DailyExercise> data) {
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

  // ── TAB 4: İlaç Uyumu ────────────────────────────────────────────────────

  Widget _buildMedicationTab() {
    final r = _fullReport;
    if (r == null || r.medicationCompliance.totalDoses == 0)
      return _buildEmptyState(
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
        _MedicationGauge(percentage: pct),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(
                child: _buildMetricCard(
                    label: 'Alınan Doz',
                    value: '${c.takenDoses}',
                    unit: 'doz',
                    color: Colors.green.shade400,
                    icon: Icons.check_circle_outline)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildMetricCard(
                    label: 'Atlanan Doz',
                    value: '$skipped',
                    unit: 'doz',
                    color: AppColors.tertiary,
                    icon: Icons.cancel_outlined)),
          ]),
        ),
        const SizedBox(height: 16),
        _insightCard(insights),
      ]),
    );
  }

  // ── PDF Export ───────────────────────────────────────────────────────────

  Future<void> _exportPdf() async {
    try {
      final r = _fullReport!;
      final now = DateTime.now();
      final startDate =
          now.subtract(Duration(days: _selectedPeriod.daysBack - 1));
      final doc = pw.Document();

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Header(
              level: 0,
              child: pw.Text('Insula Sağlık Raporu',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold))),
          pw.Text(
              'Dönem: ${_fmtDate(startDate)} – ${_fmtDate(now)}  |  ${_selectedPeriod.label}'),
          pw.SizedBox(height: 20),
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
        ],
      ));

      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e) {
      debugPrint('ReportsScreen._exportPdf hata: $e');
    }
  }
}

// ── Medication Gauge ─────────────────────────────────────────────────────────

class _MedicationGauge extends StatelessWidget {
  final double percentage;
  const _MedicationGauge({required this.percentage});

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
    const startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * (percentage / 100);

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

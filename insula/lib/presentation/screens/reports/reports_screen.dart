// Raporlar ana ekranı.
// TabBar, periyot seçici, veri yükleme orchestration ve PDF export
// işlemlerini yönetir. Tab içeriklerini ayrı widget'lardan çeker.
// Veri yükleme, modül bazlı servislere delege edilir.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:insula/core/theme/app_colors.dart';
import 'package:insula/core/theme/app_text_styles.dart';
import 'package:insula/presentation/screens/reports/models/report_models.dart';
import 'package:insula/presentation/screens/reports/tabs/nutrition_report_tab.dart';
import 'package:insula/presentation/screens/reports/tabs/glucose_report_tab.dart';
import 'package:insula/presentation/screens/reports/tabs/exercise_report_tab.dart';
import 'package:insula/presentation/screens/reports/tabs/medication_report_tab.dart';
import 'package:insula/presentation/screens/reports/widgets/report_shared_widgets.dart';
import 'package:insula/data/services/report/nutrition_report_service.dart';
import 'package:insula/data/services/report/glucose_report_service.dart';
import 'package:insula/data/services/report/exercise_report_service.dart';
import 'package:insula/data/services/report/medication_report_service.dart';

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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final fs = FirebaseFirestore.instance;
      final userDoc = await fs.collection('users').doc(uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      final carbGoal = (userData?['dailyCarbGoal'] as num?)?.toInt() ?? 200;
      final targetMin = (userData?['targetGlucoseMin'] as num?)?.toInt() ?? 70;
      final targetMax = (userData?['targetGlucoseMax'] as num?)?.toInt() ?? 140;
      final daysBack = _selectedPeriod.daysBack;

      // Tüm modül servislerini paralel çağır
      final results = await Future.wait([
        NutritionReportService.loadNutritionData(
            uid: uid, daysBack: daysBack, carbGoal: carbGoal),
        GlucoseReportService.loadGlucoseData(
            uid: uid,
            daysBack: daysBack,
            targetMin: targetMin,
            targetMax: targetMax),
        ExerciseReportService.loadExerciseData(uid: uid, daysBack: daysBack),
        MedicationReportService.loadMedicationData(uid: uid),
      ]);

      final nutrition = results[0] as ReportData;
      final glucoseResult = results[1] as GlucoseReportResult;
      final exerciseResult = results[2] as ExerciseReportResult;
      final compliance = results[3] as MedicationCompliance;

      if (mounted) {
        setState(() {
          _fullReport = FullReportData(
            nutrition: nutrition,
            glucoseData: glucoseResult.glucoseData,
            exerciseData: exerciseResult.exerciseData,
            medicationCompliance: compliance,
            avgGlucose: glucoseResult.avgGlucose,
            glucoseInRangePercent: glucoseResult.glucoseInRangePercent,
            targetGlucoseMin: targetMin,
            targetGlucoseMax: targetMax,
            totalExerciseMinutes: exerciseResult.totalExerciseMinutes,
            totalExerciseCalories: exerciseResult.totalExerciseCalories,
            exerciseDaysCount: exerciseResult.exerciseDaysCount,
            hypoCount: glucoseResult.hypoCount,
            hyperCount: glucoseResult.hyperCount,
            glucoseContextCounts: glucoseResult.glucoseContextCounts,
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
                      NutritionReportTab(
                          fullReport: _fullReport,
                          selectedPeriod: _selectedPeriod),
                      GlucoseReportTab(
                          fullReport: _fullReport,
                          selectedPeriod: _selectedPeriod),
                      ExerciseReportTab(
                          fullReport: _fullReport,
                          selectedPeriod: _selectedPeriod),
                      MedicationReportTab(
                          fullReport: _fullReport,
                          selectedPeriod: _selectedPeriod),
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
              'Dönem: ${ReportSharedWidgets.fmtDate(startDate)} – ${ReportSharedWidgets.fmtDate(now)}  |  ${_selectedPeriod.label}'),
          pw.SizedBox(height: 20),
          ...NutritionReportTab.buildPdfSection(r, ReportSharedWidgets.fmtDate),
          ...GlucoseReportTab.buildPdfSection(r, ReportSharedWidgets.fmtDate),
          ...ExerciseReportTab.buildPdfSection(r, ReportSharedWidgets.fmtDate),
          ...MedicationReportTab.buildPdfSection(r, ReportSharedWidgets.fmtDate),
        ],
      ));

      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e) {
      debugPrint('ReportsScreen._exportPdf hata: $e');
    }
  }
}

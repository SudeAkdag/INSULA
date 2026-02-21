import 'package:flutter/material.dart';
import 'package:insula/data/services/exercise_service.dart';
import 'package:insula/data/models/exercise_model.dart';
import 'package:insula/presentation/widgets/exercise_history/history_activity_tile.dart';
import 'package:insula/presentation/widgets/exercise_history/history_summary_card.dart';
import '../../../../core/theme/app_colors.dart';


class ExerciseHistoryScreen extends StatefulWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  String _selectedCategory = "Hepsi";

  final List<Map<String, dynamic>> _categories = [
    {"label": "Hepsi", "icon": Icons.check},
    {"label": "Yürüyüş", "icon": null},
    {"label": "Koşu", "icon": null},
    {"label": "Bisiklet", "icon": null},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          "Tamamlanan Egzersizler",
          style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<List<ExerciseModel>>(
        stream: _exerciseService.getExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          List<ExerciseModel> allItems = snapshot.data ?? [];

          // 1. Kategoriye göre filtreleme
          if (_selectedCategory != "Hepsi") {
            allItems = allItems.where((ex) => ex.activityName == _selectedCategory).toList();
          }

          // 2. Tarihlere göre gruplama mantığı
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));

          final todayItems = allItems.where((ex) => _isSameDay(ex.date, today)).toList();
          final yesterdayItems = allItems.where((ex) => _isSameDay(ex.date, yesterday)).toList();
          final olderItems = allItems.where((ex) => ex.date.isBefore(yesterday)).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // GÖRSELDEKİ SABİT ÜST KISIM
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: HistorySummaryCard(),
                ),

                // KATEGORİ BARI (Özetin hemen altında)
                _buildCategoryBar(),

                const SizedBox(height: 16),

                // GRUPLANMIŞ LİSTELER
                if (todayItems.isNotEmpty) ...[
                  _buildSectionHeader("Bugün"),
                  ...todayItems.map((ex) => _buildHistoryTile(ex)),
                ],

                if (yesterdayItems.isNotEmpty) ...[
                  _buildSectionHeader("Dün"),
                  ...yesterdayItems.map((ex) => _buildHistoryTile(ex)),
                ],

                if (olderItems.isNotEmpty) ...[
                  _buildSectionHeader("Daha Eski"),
                  ...olderItems.map((ex) => _buildHistoryTile(ex)),
                ],

                if (allItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("Kayıt bulunamadı.", style: TextStyle(color: Colors.grey)),
                    ),
                  ),

                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }

  // Kategori Barı Tasarımı (Görseldeki gibi Sarı/Beyaz Hap Stil)
  Widget _buildCategoryBar() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          bool isSelected = _selectedCategory == cat['label'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['label']),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.secondary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  if (cat['icon'] != null && isSelected) ...[
                    Icon(cat['icon'], size: 16, color: AppColors.secondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    cat['label'],
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildHistoryTile(ExerciseModel ex) {
    double diff = (ex.glucoseAfter ?? 0) - (ex.glucoseBefore ?? 0);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HistoryActivityTile(
        title: ex.activityName,
        time: "${ex.date.day} ${_getMonthName(ex.date.month)}",
        duration: "${ex.durationMinutes} dk",
        calories: "${ex.estimatedCalories} kcal",
        glucoseChange: diff == 0 ? "---" : "${diff.abs().toInt()} mg/dL",
        isDecrease: diff <= 0,
      ),
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getMonthName(int month) {
    const months = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return months[month - 1];
  }
}
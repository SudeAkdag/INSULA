import 'package:flutter/material.dart';
import 'package:insula/data/services/exercise_service.dart';
import 'package:insula/data/models/exercise_model.dart';
// Yeni widget'ını doğru dosyadan import ettiğinden emin ol:
import 'package:insula/presentation/widgets/exercise_history/history_activity_tile.dart'; 
import '../../../../core/theme/app_colors.dart';

class ExerciseHistoryScreen extends StatefulWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  final ExerciseService _exerciseService = ExerciseService();
  String _selectedCategory = "Hepsi";
  late Stream<List<ExerciseModel>> _exerciseStream;

  final List<Map<String, dynamic>> _categories = [
    {"label": "Hepsi", "icon": Icons.check},
    {"label": "Yürüyüş", "icon": Icons.directions_walk},
    {"label": "Koşu", "icon": Icons.directions_run},
    {"label": "Bisiklet", "icon": Icons.directions_bike},
  ];

  @override
  void initState() {
    super.initState();
    _exerciseStream = _exerciseService.getExercises();
  }

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
        stream: _exerciseStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          List<ExerciseModel> allItems = snapshot.data ?? [];

          if (_selectedCategory != "Hepsi") {
            allItems = allItems.where((ex) => ex.activityName == _selectedCategory).toList();
          }

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
                // --- BURASI DEĞİŞTİ: Eski kart yerine yeni butonlu widget ve FutureBuilder geldi ---
                FutureBuilder<Map<String, dynamic>>(
                  future: _exerciseService.getMonthlyComparison(),
                  builder: (context, summarySnapshot) {
                    if (!summarySnapshot.hasData) return const SizedBox(height: 100);
                    // Yeni yazdığımız class'ı burada çağırıyoruz:
                    return MonthlySummaryCard(stats: summarySnapshot.data!);
                  },
                ),
                // -----------------------------------------------------------------------------

                _buildCategoryBar(),
                const SizedBox(height: 16),
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

  // ... Diğer yardımcı metodlar (_buildCategoryBar, _buildHistoryTile vb.) aynı kalacak
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

  Widget _buildHistoryTile(ExerciseModel ex) {
    IconData activityIcon;
    switch (ex.activityName) {
      case 'Koşu': activityIcon = Icons.directions_run; break;
      case 'Bisiklet': activityIcon = Icons.directions_bike; break;
      case 'Yürüyüş': activityIcon = Icons.directions_walk; break;
      case 'Yoga': activityIcon = Icons.self_improvement; break;
      case 'Ağırlık': activityIcon = Icons.fitness_center; break;
      default: activityIcon = Icons.directions_walk;
    }

    double diff = (ex.glucoseAfter ?? 0) - (ex.glucoseBefore ?? 0);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HistoryActivityTile(
        title: ex.activityName,
        icon: activityIcon,
        time: "${ex.date.day} ${_getMonthName(ex.date.month)}",
        duration: "${ex.durationMinutes} dk",
        calories: "${ex.estimatedCalories.toStringAsFixed(2)} kcal",
        glucoseBefore: ex.glucoseBefore?.toInt().toString(),
        glucoseAfter: ex.glucoseAfter?.toInt().toString(),
        isDecrease: diff <= 0,
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

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  String _getMonthName(int month) {
    const months = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"];
    return months[month - 1];
  }
}
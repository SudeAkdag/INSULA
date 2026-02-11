import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/exercise_history/history_summary_card.dart';
import '../widgets/exercise_history/history_activity_tile.dart';
import '../widgets/exercise_history/featured_history_card.dart';

class ExerciseHistoryScreen extends StatelessWidget {
  const ExerciseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tamamlanan Egzersizler",
          style: TextStyle(
            color: AppColors.secondary, 
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             HistorySummaryCard(), // Üst özet kartı
            const SizedBox(height: 24),
            
            // Filtreleme butonları (Hepsi, Yürüyüş, Koşu...)
            _buildFilterRow(),
            
            const SizedBox(height: 24),
            const Text(
              "Bugün", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: AppColors.secondary // Başlık rengi AppColors'tan alındı
              )
            ),
            const SizedBox(height: 12),
            const HistoryActivityTile(
              title: "Sabah Yürüyüşü",
              time: "Bugün, 08:30",
              duration: "45 dk",
              calories: "320 kcal",
              glucoseChange: "140 ➔ 110",
              isDecrease: true,
            ),
            
            const SizedBox(height: 24),
            const Text(
              "Dün", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: AppColors.secondary
              )
            ),
            const SizedBox(height: 12),
            const HistoryActivityTile(
              title: "Bisiklet Sürüşü",
              time: "Dün, 18:15",
              duration: "30 dk",
              calories: "450 kcal",
              glucoseChange: "165 ➔ 125",
              isDecrease: true,
            ),
            
            const SizedBox(height: 24),
            const Text(
              "Bu Hafta", 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: AppColors.secondary
              )
            ),
            const SizedBox(height: 12),
            const FeaturedHistoryCard(), // Resimli sahil koşusu kartı
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip("Hepsi", true),
          _filterChip("Yürüyüş", false),
          _filterChip("Koşu", false),
          _filterChip("Bisiklet", false),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (val) {},
        // Renkler tamamen AppColors üzerinden yönetiliyor
        selectedColor: AppColors.primary, 
        backgroundColor: AppColors.surfaceLight,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.backgroundLight,
          ),
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.secondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
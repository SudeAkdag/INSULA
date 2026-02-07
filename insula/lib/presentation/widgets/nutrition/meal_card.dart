import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart'; //
import '/core/theme/app_text_styles.dart'; //
import '/core/theme/app_constants.dart'; //
import '/data/models/index.dart'; //

class MealCard extends StatelessWidget {
  final Meal meal;

  const MealCard({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    // Öğün tipine göre renk ve ikon seçimi
    final Color mealColor = _getMealColor(meal.type);
    final IconData mealIcon = _getMealIcon(meal.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight, //
        borderRadius: BorderRadius.circular(AppRadius.lg), //
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Sol taraftaki renkli şerit
            Positioned(
              left: 0, top: 0, bottom: 0,
              child: Container(width: 6, color: mealColor),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Başlık Satırı: İkon, Başlık, Saat ve Toplam Karb Badge
                  _buildHeader(mealColor, mealIcon),
                  const SizedBox(height: 16),
                  // Besin Listesi
                  ...meal.items.map((item) => _buildFoodItemRow(item)).toList(),
                  const SizedBox(height: 12),
                  // Besin Ekle Butonu
                  _buildAddButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(meal.type, style: AppTextStyles.h1.copyWith(fontSize: 16)),
            if (meal.time != null)
              Text(meal.time!, style: AppTextStyles.label) //
            else if (meal.items.isEmpty)
              Text("Henüz girilmedi", style: AppTextStyles.label.copyWith(color: AppColors.textSecLight)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "${meal.totalCarbs.toInt()}g Karb", //
            style: AppTextStyles.label.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodItemRow(FoodItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
              Text("${item.portion} • ${item.calories} kcal", style: AppTextStyles.label), //
            ],
          ),
          Text("${item.carbs.toInt()}g", style: AppTextStyles.body.copyWith(color: AppColors.secondary.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: InkWell(
        onTap: () {}, // Ekleme fonksiyonu buraya gelecek
        child: Row(
          children: [
            const Icon(Icons.add, color: AppColors.tertiary, size: 18),
            const SizedBox(width: 4),
            Text("Besin Ekle", style: AppTextStyles.body.copyWith(color: AppColors.tertiary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Yardımcı Metotlar
  Color _getMealColor(String type) {
    if (type == "Kahvaltı") return AppColors.primary;
    if (type == "Öğle Yemeği") return AppColors.tertiary;
    if (type == "Akşam Yemeği") return AppColors.secondary;
    return AppColors.secondary;
  }

  IconData _getMealIcon(String type) {
    if (type == "Kahvaltı") return Icons.wb_twilight;
    if (type == "Öğle Yemeği") return Icons.sunny;
    if (type == "Akşam Yemeği") return Icons.bedtime;
    return Icons.cookie_outlined;
  }
}
import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart'; //
import '/core/theme/app_text_styles.dart'; //
import '/core/theme/app_constants.dart'; //
import '/data/models/index.dart'; //
import '/data/repositories/nutrition_repository.dart';
import '/presentation/widgets/nutrition_summary_card.dart';
import '/presentation/widgets/meal_card.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final NutritionRepository _repository = NutritionRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight, //
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Beslenme Takibi", style: AppTextStyles.h1), //
        centerTitle: true,
      ),
      body: FutureBuilder<List<Meal>>( //
        future: _repository.getDailyMeals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (snapshot.hasError) {
            return Center(child: Text("Veri yüklenemedi: ${snapshot.error}"));
          }

          final meals = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDailySummary(meals), // Yukarıdaki o büyük özet kartı
              const SizedBox(height: 24),
              Text("Öğünler", style: AppTextStyles.h1.copyWith(fontSize: 20)),
              const SizedBox(height: 16),
              ...meals.map((meal) => MealCard(meal: meal)).toList(),
            ],
          );
        },
      ),
        // YENİ EKLEME: Hızlı Ekleme Butonu
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        // Buraya Besin Ekleme sayfası navigasyonu gelecek
        print("Hızlı ekleme butonuna basıldı.");
        },
        backgroundColor: AppColors.tertiary, // HTML'deki turuncu tonu
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full), // Tam yuvarlak
        ),
        child: const Icon(
          Icons.add,
        color: Colors.white,
        size: 32,
        ),
      ),
  // Butonu sağ alt köşede, navigasyon barının biraz üzerinde tutar
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

// nutrition_screen.dart içinde:
Widget _buildDailySummary(List<Meal> meals) {
  // Model içindeki fonksiyonları kullanarak toplamları alıyoruz
  double totalCarbs = meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double totalSugar = meals.fold(0, (sum, meal) => sum + meal.totalSugar);
  double totalFiber = meals.fold(0, (sum, meal) => sum + meal.totalFiber);

  return NutritionSummaryCard(
    currentCarbs: totalCarbs,
    carbGoal: 200, // Bu değer ilerde User modelinden gelecek
    sugar: totalSugar,
    fiber: totalFiber,
  );
}
}
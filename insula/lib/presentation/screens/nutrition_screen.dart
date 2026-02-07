import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart'; //
import '/core/theme/app_text_styles.dart'; //
import '/core/theme/app_constants.dart'; //
import '/data/models/index.dart'; //
import '/data/repositories/nutrition_repository.dart';
import '../widgets/nutrition/nutrition_summary_card.dart';
import '../widgets/nutrition/meal_card.dart';

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
              _buildDateSelector(),
              const SizedBox(height: 24),
              Text("Günlük Özet", style: AppTextStyles.h1.copyWith(fontSize: 28)), //
              Text(
                "Karbonhidrat hedefine ulaşmak üzeresin.",
                style: AppTextStyles.label.copyWith(fontSize: 14)
                ),
              SizedBox(height: 24),
              _buildDailySummary(meals), // Yukarıdaki o büyük özet kartı
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Öğünler", style: AppTextStyles.h1.copyWith(fontSize: 20)), //
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight, //
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.backgroundLight), //
                    ),
                    child: Text(
                      "Top. 1420 kcal", 
                      style: AppTextStyles.label.copyWith(fontWeight: FontWeight.bold, color: AppColors.secondary) //
                    ),
                  ),
                ],
              ),
              
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

Widget _buildDateSelector() {
  final List<String> days = ["Dün", "Bugün", "Yarın", "28 Eki"];
  
  return Row( // ListView yerine Row kullanarak butonların yayılmasını sağlıyoruz
    children: List.generate(days.length, (index) {
      bool isSelected = index == 1; // "Bugün" seçili
      
      return Expanded( // Expanded, her butona ekranın 1/4'ünü (eşit payı) verir
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4), // Butonlar arası boşluk
          child: ChoiceChip(
            // SizedBox.expand veya width: double.infinity ile Chip'in tüm alanı kaplamasını sağlıyoruz
            label: SizedBox(
              width: double.infinity, 
              child: Text(
                days[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.secondary : AppColors.textSecLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            selected: isSelected,
            onSelected: (val) {},
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surfaceLight,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            showCheckmark: false, // Tasarımdaki gibi temiz görünüm için tik işaretini kaldırdık
            // Chip'in iç boşluklarını sıfırlayarak tam yayılım sağlıyoruz
            labelPadding: EdgeInsets.zero,
            padding: const EdgeInsets.symmetric(vertical: 8), 
          ),
        ),
      );
    }),
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
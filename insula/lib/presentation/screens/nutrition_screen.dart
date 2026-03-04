import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/nutrition_viewmodel.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';
import '../widgets/nutrition/nutrition_summary_card.dart';
import '../widgets/nutrition/meal_card.dart';
import 'package:insula/presentation/screens/add_food_screen.dart';

/// Beslenme takip ekranı.
/// ChangeNotifierProvider + Consumer<NutritionViewModel> kullanır.
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NutritionViewModel(),
      child: const _NutritionScreenContent(),
    );
  }
}

class _NutritionScreenContent extends StatelessWidget {
  const _NutritionScreenContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          backgroundColor: AppColors.backgroundLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Beslenme Takibi', style: AppTextStyles.h1),
            centerTitle: true,
          ),
          body: _buildBody(context, vm),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showMealTypePicker(context, vm),
            backgroundColor: AppColors.tertiary,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, NutritionViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.tertiary, size: 48),
              const SizedBox(height: 12),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: AppColors.tertiary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => vm.loadMeals(vm.selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDateSelector(context, vm),
        const SizedBox(height: 24),
        Text(
          'Günlük Özet',
          style: AppTextStyles.h1.copyWith(fontSize: 28),
        ),
        Text(
          'Karbonhidrat takibini buradan yapabilirsin.',
          style: AppTextStyles.label.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 24),
        NutritionSummaryCard(
          currentCarbs: vm.totalCarbs,
          carbGoal: vm.carbGoal,
          sugar: vm.totalSugar,
          fiber: vm.totalFiber,
          protein: vm.totalProtein,
          fat: vm.totalFat,
          onCarbGoalChanged: (newGoal) => vm.updateCarbGoal(newGoal),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Öğünler', style: AppTextStyles.h1.copyWith(fontSize: 20)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.backgroundLight),
              ),
              child: Text(
                'Top. ${vm.totalCalories.toInt()} kcal',
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...vm.meals.map(
          (meal) => MealCard(
            meal: meal,
            onDeleteItem: (mealType, itemId) =>
                vm.removeFoodFromMeal(mealType, itemId, vm.selectedDate),
            onAddFood: (mealType) => _navigateToAddFood(
              context,
              mealType,
              vm.selectedDate,
            ),
          ),
        ),
        const SizedBox(height: 80), // FAB için alt boşluk
      ],
    );
  }

  /// Dinamik tarih seçici widget'ı.
  /// Önceki gün | Bugün | Sonraki gün + takvim butonu
  Widget _buildDateSelector(BuildContext context, NutritionViewModel vm) {
    final DateTime selected = vm.selectedDate;
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime tomorrow = today.add(const Duration(days: 1));

    // Gün etiketi üretir
    String _label(DateTime date) {
      if (_isSameDay(date, today)) return 'Bugün';
      if (_isSameDay(date, yesterday)) return 'Dün';
      if (_isSameDay(date, tomorrow)) return 'Yarın';
      return _formatShort(date);
    }

    // Gösterilecek üç günlük liste
    final List<DateTime> days = [
      selected.subtract(const Duration(days: 1)),
      selected,
      selected.add(const Duration(days: 1)),
    ];

    return Row(
      children: [
        // Önceki / seçili / sonraki gün butonları
        ...days.map((date) {
          final bool isSelected = _isSameDay(date, selected);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _label(date),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => vm.changeDate(date),
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surfaceLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                side: BorderSide.none,
                showCheckmark: false,
                labelPadding: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          );
        }),
        // Takvim ikonu butonu
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: InkWell(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selected,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                locale: const Locale('tr', 'TR'),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.secondary,
                        onPrimary: Colors.white,
                        surface: AppColors.surfaceLight,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                vm.changeDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Öğün tipi seçimi için BottomSheet açar, sonra AddFoodScreen'e gider.
  void _showMealTypePicker(BuildContext context, NutritionViewModel vm) {
    const List<String> mealTypes = [
      'Kahvaltı',
      'Öğle Yemeği',
      'Akşam Yemeği',
      'Ara Öğünler',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navBar,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hangi öğüne eklemek istiyorsunuz?',
                style: AppTextStyles.h1.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...mealTypes.map((type) {
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppRadius.defaultRadius),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getMealColor(type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getMealIcon(type),
                      color: _getMealColor(type),
                      size: 20,
                    ),
                  ),
                  title: Text(type, style: AppTextStyles.body),
                  onTap: () {
                    Navigator.of(sheetCtx).pop();
                    _navigateToAddFood(context, type, vm.selectedDate);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// AddFoodScreen'e yönlendirir.
  void _navigateToAddFood(
    BuildContext context,
    String mealType,
    DateTime date,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<NutritionViewModel>(),
          child: AddFoodScreen(mealType: mealType, date: date),
        ),
      ),
    );
  }

  // ─── Yardımcı metodlar ────────────────────────────────────────────────────

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatShort(DateTime date) {
    const List<String> months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  Color _getMealColor(String type) {
    if (type == 'Kahvaltı') return AppColors.primary;
    if (type == 'Öğle Yemeği') return AppColors.tertiary;
    if (type == 'Akşam Yemeği') return AppColors.secondary;
    return AppColors.secondary;
  }

  IconData _getMealIcon(String type) {
    if (type == 'Kahvaltı') return Icons.wb_twilight;
    if (type == 'Öğle Yemeği') return Icons.sunny;
    if (type == 'Akşam Yemeği') return Icons.bedtime;
    return Icons.cookie_outlined;
  }
}

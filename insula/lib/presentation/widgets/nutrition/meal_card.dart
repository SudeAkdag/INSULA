import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';
import '/data/models/index.dart';

/// Bir öğünü ve içindeki besin öğelerini gösteren kart bileşeni.
/// Besin satırına tıklandığında tam besin değerleri bottom sheet olarak açılır.
class MealCard extends StatelessWidget {
  final Meal meal;

  /// Besin silindiğinde çağrılır; [mealType] ve [itemId] parametrelerini alır.
  final void Function(String mealType, String itemId)? onDeleteItem;

  /// "Besin Ekle" butonuna tıklandığında çağrılır; [mealType] parametresini alır.
  final void Function(String mealType)? onAddFood;

  const MealCard({
    super.key,
    required this.meal,
    this.onDeleteItem,
    this.onAddFood,
  });

  @override
  Widget build(BuildContext context) {
    final Color mealColor = _getMealColor(meal.type);
    final IconData mealIcon = _getMealIcon(meal.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            // Sol taraftaki renkli şerit
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 6, color: mealColor),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık satırı
                  _buildHeader(mealColor, mealIcon),
                  const SizedBox(height: 16),

                  // Besin listesi
                  if (meal.items.isEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 44, bottom: 8),
                      child: Text(
                        'Henüz girilmedi',
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textSecLight,
                        ),
                      ),
                    ),
                  ] else ...[
                    ...meal.items
                        .map((item) => _buildFoodItemRow(context, item))
                        .toList(),
                  ],

                  const SizedBox(height: 4),
                  // Besin ekle butonu (her zaman görünür)
                  _buildAddButton(context),
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
              Text(meal.time!, style: AppTextStyles.label)
            else if (meal.items.isEmpty)
              Text(
                'Henüz eklenmedi',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textSecLight,
                ),
              ),
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
            '${meal.totalCarbs.toInt()}g Karb',
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Besin satırı – tıklanınca [_showFoodDetail] ile tam değerleri gösterir.
  Widget _buildFoodItemRow(BuildContext context, FoodItem item) {
    return Padding(
      padding: const EdgeInsets.only(left: 44, bottom: 12),
      child: InkWell(
        onTap: () => _showFoodDetail(context, item),
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTextStyles.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${item.portion} • ${item.calories} kcal',
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
              Text(
                '${item.carbs.toInt()}g',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.secondary.withOpacity(0.6),
                ),
              ),
              const SizedBox(width: 8),
              // Silme butonu – tıklama olayı InkWell'e yayılmasın
              GestureDetector(
                onTap: () {
                  if (item.id != null) {
                    onDeleteItem?.call(meal.type, item.id!);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Besin değerlerini gösteren bottom sheet.
  void _showFoodDetail(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutamaç çizgisi
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.navBar,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Besin adı + porsiyon
              Text(
                item.name,
                style: AppTextStyles.h1.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                item.portion,
                style: AppTextStyles.label.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Kalori – büyük vurgu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppColors.tertiary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.calories} kcal',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 26,
                            color: AppColors.tertiary,
                          ),
                        ),
                        Text(
                          'Kalori',
                          style: AppTextStyles.label,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2x3 besin değerleri grid'i
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.5,
                children: [
                  _buildNutrientTile(
                    label: 'Karbonhidrat',
                    value: '${item.carbs.toStringAsFixed(1)}g',
                    color: AppColors.primary,
                    icon: Icons.grain,
                  ),
                  _buildNutrientTile(
                    label: 'Protein',
                    value: '${item.protein.toStringAsFixed(1)}g',
                    color: AppColors.secondary,
                    icon: Icons.fitness_center,
                  ),
                  _buildNutrientTile(
                    label: 'Yağ',
                    value: '${item.fat.toStringAsFixed(1)}g',
                    color: Colors.purple.shade300,
                    icon: Icons.water_drop_outlined,
                  ),
                  _buildNutrientTile(
                    label: 'Şeker',
                    value: '${item.sugar.toStringAsFixed(1)}g',
                    color: AppColors.tertiary,
                    icon: Icons.icecream_outlined,
                  ),
                  _buildNutrientTile(
                    label: 'Lif',
                    value: '${item.fiber.toStringAsFixed(1)}g',
                    color: Colors.green.shade400,
                    icon: Icons.eco_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Tek bir besin değeri kutucuğu.
  Widget _buildNutrientTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.label.copyWith(fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 44),
      child: InkWell(
        onTap: () => onAddFood?.call(meal.type),
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, color: AppColors.tertiary, size: 18),
              const SizedBox(width: 4),
              Text(
                'Besin Ekle',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

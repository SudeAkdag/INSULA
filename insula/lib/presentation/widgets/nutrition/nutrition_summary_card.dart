import 'package:flutter/material.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';
import '/core/theme/nutrient_colors.dart';

/// Günlük beslenme özetini gösteren kart bileşeni.
/// Karbonhidrat ilerleme çubuğu ve besin değerleri grid'i içerir.
class NutritionSummaryCard extends StatelessWidget {
  final double currentCarbs;
  final int carbGoal;
  final double sugar;
  final double fiber;
  final double protein;
  final double fat;
  final ValueChanged<int>? onCarbGoalChanged;

  const NutritionSummaryCard({
    super.key,
    required this.currentCarbs,
    required this.carbGoal,
    required this.sugar,
    required this.fiber,
    this.protein = 0.0,
    this.fat = 0.0,
    this.onCarbGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentCarbs / carbGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg * 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Arka plan dekorasyon ikonu
          Positioned(
            right: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.05,
              child: Icon(
                Icons.restaurant,
                size: 140,
                color: AppColors.secondary,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOPLAM KARBONHİDRAT',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.secondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 12),

                // Karb değeri + hedef + kalem ikonu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentCarbs.toInt().toString(),
                      style: AppTextStyles.glucoseValue
                          .copyWith(fontSize: 48, height: 1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '/ ${carbGoal}g',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _showCarbGoalDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // İlerleme çubuğu
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: NutrientColors.carbs,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: NutrientColors.carbs.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3-2 Besin değerleri grid'i (3 üstte, 2 altta)
                Column(
                  children: [
                    // Üst satır: Şeker | Lif | Karbonhidrat
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutrientInfo(
                            'Şeker',
                            '${sugar.toInt()}g',
                            NutrientColors.sugar,
                          ),
                        ),
                        Expanded(
                          child: _buildNutrientInfo(
                            'Lif',
                            '${fiber.toInt()}g',
                            NutrientColors.fiber,
                          ),
                        ),
                        Expanded(
                          child: _buildNutrientInfo(
                            'Karbonhidrat',
                            '${currentCarbs.toInt()}g',
                            NutrientColors.carbs,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Alt satır: Protein | Yağ
                    Row(
                      children: [
                        Expanded(
                          child: _buildNutrientInfo(
                            'Protein',
                            '${protein.toInt()}g',
                            NutrientColors.protein,
                          ),
                        ),
                        Expanded(
                          child: _buildNutrientInfo(
                            'Yağ',
                            '${fat.toInt()}g',
                            NutrientColors.fat,
                          ),
                        ),
                        // Boş alan – simetri için
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Raporu Gör butonu
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Raporu Gör',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Renkli nokta badge'li besin değeri satırı oluşturur.
  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            Text(
              value,
              style: AppTextStyles.h1.copyWith(fontSize: 16, color: color),
            ),
          ],
        ),
      ],
    );
  }

  /// Karbonhidrat hedefini güncellemek için diyalog açar.
  void _showCarbGoalDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: carbGoal.toString(),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Karbonhidrat Hedefi',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Günlük hedef (g)',
              suffixText: 'g',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Değer girin';
              final n = int.tryParse(val);
              if (n == null || n <= 0) return 'Geçerli bir sayı girin';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'İptal',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecLight),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newGoal = int.parse(controller.text);
                onCarbGoalChanged?.call(newGoal);
                Navigator.of(ctx).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

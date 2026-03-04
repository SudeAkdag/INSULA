import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/nutrition_viewmodel.dart';
import 'package:insula/data/models/index.dart';
import 'package:insula/data/repositories/nutrition_repository.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';

/// Belirli bir öğüne besin ekleme ekranı.
/// Manuel form girişi ve (ilerleyen sürümde) Open Food Facts API araması içerir.
class AddFoodScreen extends StatefulWidget {
  /// Besinin ekleneceği öğün tipi (ör. "Kahvaltı")
  final String mealType;

  /// Besinin ekleneceği tarih
  final DateTime date;

  const AddFoodScreen({
    super.key,
    required this.mealType,
    required this.date,
  });

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final NutritionRepository _repository = NutritionRepository();

  // Arama
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _searchResults = [];
  bool _isSearching = false;

  // Form alanları
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _portionController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _fiberController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _portionController.dispose();
    _caloriesController.dispose();
    _carbsController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _fiberController.dispose();
    super.dispose();
  }

  /// Open Food Facts API araması (şimdilik boş liste döner)
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    final results = await _repository.searchFood(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  /// Arama sonucundan form alanlarını doldurur
  void _fillFromSearchResult(FoodItem item) {
    _nameController.text = item.name;
    _portionController.text = item.portion;
    _caloriesController.text = item.calories.toString();
    _carbsController.text = item.carbs.toString();
    _proteinController.text = item.protein.toString();
    _fatController.text = item.fat.toString();
    _sugarController.text = item.sugar.toString();
    _fiberController.text = item.fiber.toString();
    setState(() => _searchResults = []);
  }

  /// Formu kaydeder ve ViewModel'e iletir
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final item = FoodItem(
      name: _nameController.text.trim(),
      portion: _portionController.text.trim(),
      calories: int.tryParse(_caloriesController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0.0,
      protein: double.tryParse(_proteinController.text) ?? 0.0,
      fat: double.tryParse(_fatController.text) ?? 0.0,
      sugar: double.tryParse(_sugarController.text) ?? 0.0,
      fiber: double.tryParse(_fiberController.text) ?? 0.0,
    );

    try {
      await context
          .read<NutritionViewModel>()
          .addFoodToMeal(widget.mealType, item, widget.date);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _isSaving = false);
      debugPrint('AddFoodScreen._save hata: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kaydedilemedi: $e'),
            backgroundColor: AppColors.tertiary,
          ),
        );
      }
    }
  }

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
        title: Text(
          '${widget.mealType} – Besin Ekle',
          style: AppTextStyles.h1.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─ Arama Çubuğu ──────────────────────────────────────────────
            _buildSearchBar(),
            const SizedBox(height: 8),

            // Arama sonuçları (ileride API'den gelecek)
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (_searchResults.isNotEmpty) _buildSearchResults(),

            const SizedBox(height: 16),

            // ─ Manuel Giriş Formu ───────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manuel Giriş',
                      style: AppTextStyles.h1.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Zorunlu alanlar
                    _buildField(
                      controller: _nameController,
                      label: 'Besin adı',
                      hint: 'ör. Yulaf Ezmesi',
                      required: true,
                    ),
                    _buildField(
                      controller: _portionController,
                      label: 'Porsiyon',
                      hint: 'ör. 1 kase, 200g',
                      required: true,
                    ),
                    _buildField(
                      controller: _caloriesController,
                      label: 'Kalori (kcal)',
                      hint: 'ör. 220',
                      numeric: true,
                      required: true,
                    ),

                    const Divider(height: 24, color: AppColors.backgroundLight),
                    Text(
                      'Besin Değerleri (isteğe bağlı)',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 2 kolonlu grid – besin değerleri
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _carbsController,
                            label: 'Karbonhidrat – g',
                            hint: 'ör. 30',
                            numeric: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _proteinController,
                            label: 'Protein – g',
                            hint: 'ör. 5',
                            numeric: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildField(
                            controller: _fatController,
                            label: 'Yağ – g',
                            hint: 'ör. 3',
                            numeric: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            controller: _sugarController,
                            label: 'Şeker – g',
                            hint: 'ör. 5',
                            numeric: true,
                          ),
                        ),
                      ],
                    ),
                    _buildField(
                      controller: _fiberController,
                      label: 'Lif – g',
                      hint: 'ör. 8',
                      numeric: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ─ Kaydet Butonu ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Kaydet',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: _search,
        onChanged: (val) {
          if (val.isEmpty) setState(() => _searchResults = []);
        },
        decoration: InputDecoration(
          hintText: 'Besin ara (ör. elma, yulaf)…',
          hintStyle: AppTextStyles.label,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecLight,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecLight),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.backgroundLight),
      ),
      child: Column(
        children: _searchResults
            .map(
              (item) => ListTile(
                title: Text(item.name, style: AppTextStyles.body),
                subtitle: Text(
                  '${item.calories} kcal • ${item.carbs}g karb',
                  style: AppTextStyles.label,
                ),
                trailing: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.tertiary,
                ),
                onTap: () => _fillFromSearchResult(item),
              ),
            )
            .toList(),
      ),
    );
  }

  /// Tek bir form alanı oluşturur.
  /// [numeric] true ise yalnızca rakam ve ondalık nokta kabul edilir;
  /// harf girilmesi hem klavyede hem validator'da engellenir.
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool numeric = false,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        // Sayısal alanlarda harf girişini klavye seviyesinde engelle
        inputFormatters: numeric
            ? [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.,]'),
                ),
              ]
            : null,
        style: AppTextStyles.body,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: AppTextStyles.label,
          hintStyle: AppTextStyles.label.copyWith(
            color: AppColors.textSecLight.withOpacity(0.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
            borderSide: BorderSide(
              color: AppColors.backgroundLight.withOpacity(0.5),
            ),
          ),
          filled: true,
          fillColor: AppColors.backgroundLight.withOpacity(0.5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: (val) {
          // Zorunlu alan kontrolü
          if (required && (val == null || val.trim().isEmpty)) {
            return '$label alanı boş bırakılamaz';
          }
          // Sayısal alan kontrolü: dolu ise geçerli sayı olmalı
          if (numeric && val != null && val.trim().isNotEmpty) {
            // Virgülü noktaya çevirerek parse et (Türkçe klavye uyumluluğu)
            final normalized = val.trim().replaceAll(',', '.');
            final parsed = double.tryParse(normalized);
            if (parsed == null) {
              return 'Lütfen geçerli bir sayı girin (ör. 30 veya 3.5)';
            }
            if (parsed < 0) {
              return 'Değer sıfırdan küçük olamaz';
            }
          }
          return null;
        },
      ),
    );
  }
}

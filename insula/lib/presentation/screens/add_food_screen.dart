import 'dart:async';
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
/// Open Food Facts API araması (debounce) + manuel form içerir.
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
  bool _selectedFromSearch = false;

  // Debounce
  Timer? _debounce;

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
    _debounce?.cancel();
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

  /// 600ms debounce ile arama tetikler.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (query.trim().length >= 2) _performSearch(query.trim());
    });
  }

  /// Open Food Facts API araması
  Future<void> _performSearch(String query) async {
    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _selectedFromSearch = false;
    });
    final results = await _repository.searchFood(query);
    if (!mounted) return;
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
    _carbsController.text = item.carbs.toStringAsFixed(1);
    _proteinController.text = item.protein.toStringAsFixed(1);
    _fatController.text = item.fat.toStringAsFixed(1);
    _sugarController.text = item.sugar.toStringAsFixed(1);
    _fiberController.text = item.fiber.toStringAsFixed(1);
    setState(() {
      _searchResults = [];
      _selectedFromSearch = true;
    });
  }

  /// Formu kaydeder ve ViewModel'e iletir
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // Türkçe klavye için virgülü noktaya çevir
    double _parse(String raw) =>
        double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0.0;

    final item = FoodItem(
      name: _nameController.text.trim(),
      portion: _portionController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
      carbs: _parse(_carbsController.text),
      protein: _parse(_proteinController.text),
      fat: _parse(_fatController.text),
      sugar: _parse(_sugarController.text),
      fiber: _parse(_fiberController.text),
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

            // Arama sonuçları
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
            if (!_isSearching && _searchResults.isNotEmpty)
              _buildSearchResults(),

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
                    Row(
                      children: [
                        Text(
                          'Manuel Giriş',
                          style: AppTextStyles.h1.copyWith(fontSize: 16),
                        ),
                        if (_selectedFromSearch) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'API\'den dolduruldu',
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.secondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ],
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
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Besin ara (ör. elma, yulaf)…',
          hintStyle: AppTextStyles.label,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecLight,
          ),
          // Arama yapılırken sağda küçük progress göster
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.textSecLight,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _selectedFromSearch = false;
                        });
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

  /// Arama sonuçları listesi
  Widget _buildSearchResults() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(color: AppColors.backgroundLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _searchResults.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _searchResults.length - 1;
          return Column(
            children: [
              InkWell(
                onTap: () => _fillFromSearchResult(item),
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '100g başına • ${item.carbs.toStringAsFixed(1)}g karb',
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: AppColors.backgroundLight.withOpacity(0.8),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Tek bir form alanı oluşturur.
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
          if (required && (val == null || val.trim().isEmpty)) {
            return '$label alanı boş bırakılamaz';
          }
          if (numeric && val != null && val.trim().isNotEmpty) {
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

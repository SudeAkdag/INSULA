import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:insula/logic/viewmodels/nutrition_viewmodel.dart';
import 'package:insula/data/models/index.dart';
import 'package:insula/data/repositories/nutrition_repository.dart';
import 'package:insula/data/local/turkish_foods_data.dart';
import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/core/theme/app_constants.dart';

/// Belirli bir öğüne besin ekleme ekranı.
///
/// Arama UX:
///   • Kullanıcı yazdığı anda yerel Türk besin listesinden sonuçlar anında gösterilir.
///   • 600ms sonra arka planda API isteği başlar; sonuçlar yerel listenin altına eklenir.
///   • Kullanıcı hiçbir zaman boş ekranla karşılaşmaz.
class AddFoodScreen extends StatefulWidget {
  final String mealType;
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
  List<FoodItem> _localResults = []; // Anında gelen yerel sonuçlar
  List<FoodItem> _apiResults = []; // Arka planda gelen API sonuçları
  bool _isApiLoading = false; // Sadece API bekleniyor mu?
  bool _selectedFromSearch = false;

  // Debounce (yalnızca API için)
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionViewModel>().loadFavoritesAndFrequent();
    });
  }

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

  // ─ Arama Mantığı ──────────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    final trimmed = query.trim();

    if (trimmed.isEmpty) {
      _debounce?.cancel();
      setState(() {
        _localResults = [];
        _apiResults = [];
        _isApiLoading = false;
      });
      return;
    }

    // Adım 1: Yerel sonuçlar + kullanıcı besinlerini ANINDA göster (debounce yok)
    if (trimmed.length >= 2) {
      final vm = context.read<NutritionViewModel>();
      final localTr = TurkishFoodsData.search(trimmed);
      final normalizedQuery = trimmed.toLowerCase();
      final userMatches = vm.userFoods.where((food) {
        return food.name.toLowerCase().contains(normalizedQuery);
      }).toList();

      // Tekrarları filtrele ve birleştir
      final seen = <String>{};
      final merged = <FoodItem>[];
      for (final item in [...localTr, ...userMatches]) {
        final key = item.name.toLowerCase().trim();
        if (!seen.contains(key)) {
          seen.add(key);
          merged.add(item);
        }
      }

      setState(() {
        _localResults = merged;
        _isApiLoading = true;
      });
    }

    // Adım 2: API'yi 600ms debounce ile arka planda çağır
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (trimmed.length >= 2) _performApiSearch(trimmed);
    });
  }

  Future<void> _performApiSearch(String query) async {
    try {
      final vm = context.read<NutritionViewModel>();
      final results = await _repository.searchFoodLayered(
        query,
        userFoods: vm.userFoods,
      );
      if (!mounted) return;
      setState(() {
        // Yerel listede zaten olanları API sonuçlarından çıkar
        final localNames =
            _localResults.map((f) => f.name.toLowerCase().trim()).toSet();
        _apiResults = results
            .where((f) => !localNames.contains(f.name.toLowerCase().trim()))
            .toList();
        _isApiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isApiLoading = false);
      debugPrint('AddFoodScreen._performApiSearch hata: $e');
    }
  }

  // ─ Seçim & Kaydet ─────────────────────────────────────────────────────────

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
      _localResults = [];
      _apiResults = [];
      _isApiLoading = false;
      _selectedFromSearch = true;
      _searchController.clear();
    });
    _debounce?.cancel();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    double parse(String raw) =>
        double.tryParse(raw.trim().replaceAll(',', '.')) ?? 0.0;

    final item = FoodItem(
      name: _nameController.text.trim(),
      portion: _portionController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
      carbs: parse(_carbsController.text),
      protein: parse(_proteinController.text),
      fat: parse(_fatController.text),
      sugar: parse(_sugarController.text),
      fiber: parse(_fiberController.text),
    );

    try {
      final vm = context.read<NutritionViewModel>();
      await vm.addFoodToMeal(widget.mealType, item, widget.date);
      // Kayıt sonrası userFoods listesini güncelle (arka planda)
      vm.loadFavoritesAndFrequent();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
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

  // ─ Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isSearchActive = _searchController.text.trim().isNotEmpty;

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
            _buildWarningNote(),
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 8),

            // Arama aktifse sonuçları göster
            if (isSearchActive) _buildSearchResults(),

            // Arama aktif değilse: favoriler + son seçilenler
            if (!isSearchActive) _buildDefaultView(),

            const SizedBox(height: 16),
            _buildManualForm(),
            const SizedBox(height: 24),
            _buildSaveButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ─ Uyarı Notu ──────────────────────────────────────────────────────
  Widget _buildWarningNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Not: Besin değerleri standart ev yapımı tariflere göre hesaplanmıştır. '
              'Restoran ve hazır gıda ürünleri farklı değerler içerebilir. '
              'Seçtiğiniz besinlerin içeriğini kaydetmeden önce değiştirebilirsiniz.',
              style: AppTextStyles.label.copyWith(
                fontSize: 11,
                color: AppColors.secondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─ Arama Çubuğu ───────────────────────────────────────────────────────────
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
        onChanged: (v) {
          _onSearchChanged(v);
          setState(() {}); // arama durumunu güncelle
        },
        decoration: InputDecoration(
          hintText: 'Besin ara (ör. elma, yulaf)…',
          hintStyle: AppTextStyles.label,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecLight),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecLight),
                  onPressed: () {
                    _searchController.clear();
                    _debounce?.cancel();
                    setState(() {
                      _localResults = [];
                      _apiResults = [];
                      _isApiLoading = false;
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ─ Arama Sonuçları (iki bölüm + loading footer) ───────────────────────────
  Widget _buildSearchResults() {
    final hasLocal = _localResults.isNotEmpty;
    final hasApi = _apiResults.isNotEmpty;
    final hasBoth = hasLocal && hasApi;
    final hasAny = hasLocal || hasApi;

    // Hiç sonuç yok ve API de beklenmiyor → "Sonuç bulunamadı"
    if (!hasAny && !_isApiLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Sonuç bulunamadı',
          style: AppTextStyles.label.copyWith(color: AppColors.textSecLight),
        ),
      );
    }

    // Sadece API bekleniyor, henüz hiç sonuç yok → küçük spinner
    if (!hasAny && _isApiLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Consumer<NutritionViewModel>(
      builder: (context, vm, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Yerel sonuçlar ──────────────────────────────────────────
            if (hasLocal) ...[
              if (hasBoth) _buildResultSectionHeader('📍', 'Yerel Sonuçlar'),
              _buildResultList(_localResults, vm),
            ],

            // ── API sonuçları ───────────────────────────────────────────
            if (hasApi) ...[
              if (hasBoth) const SizedBox(height: 8),
              if (hasBoth) _buildResultSectionHeader('🌐', 'Diğer Sonuçlar'),
              _buildResultList(_apiResults, vm),
            ],

            // ── API hâlâ yükleniyor (footer) ────────────────────────────
            if (_isApiLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: AppColors.secondary,
                        strokeWidth: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daha fazla aranıyor…',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textSecLight,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildResultSectionHeader(String emoji, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        '$emoji  $label',
        style: AppTextStyles.label.copyWith(color: AppColors.textSecLight),
      ),
    );
  }

  Widget _buildResultList(List<FoodItem> items, NutritionViewModel vm) {
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
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          final isFav = vm.isFavorite(item);

          return Column(
            children: [
              InkWell(
                onTap: () => _fillFromSearchResult(item),
                borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
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
                              '${item.portion} • ${item.carbs.toStringAsFixed(1)}g karb',
                              style: AppTextStyles.label,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => vm.toggleFavorite(item),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: isFav
                                ? AppColors.primary
                                : AppColors.textSecLight,
                            size: 22,
                          ),
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

  // ─ Default View: Favoriler + son Seçilenler ───────────────────────────────
  Widget _buildDefaultView() {
    return Consumer<NutritionViewModel>(
      builder: (context, vm, _) {
        if (vm.isFavoritesLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (vm.favoriteFoods.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildSectionHeader(
                icon: Icons.star_rounded,
                iconColor: AppColors.primary,
                label: 'Favoriler',
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.favoriteFoods.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final item = vm.favoriteFoods[i];
                    return ActionChip(
                      avatar: const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: Text(
                        item.name,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () => _fillFromSearchResult(item),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            _buildSectionHeader(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.secondary,
              label: 'Son Seçilenler',
            ),
            const SizedBox(height: 8),
            if (vm.frequentFoods.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Henüz besin eklemediniz',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textSecLight,
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppRadius.defaultRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: vm.frequentFoods.asMap().entries.map((entry) {
                    final i = entry.key;
                    final item = entry.value;
                    final isLast = i == vm.frequentFoods.length - 1;
                    return Column(
                      children: [
                        InkWell(
                          onTap: () => _fillFromSearchResult(item),
                          borderRadius: BorderRadius.circular(
                            AppRadius.defaultRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: AppTextStyles.body.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        item.portion,
                                        style: AppTextStyles.label,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.secondary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.carbs.toStringAsFixed(0)}g karb',
                                    style: AppTextStyles.label.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textSecLight,
                                  size: 20,
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
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  // ─ Manuel Giriş Formu ─────────────────────────────────────────────────────
  Widget _buildManualForm() {
    return Container(
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
                      'Dolduruldu',
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
    );
  }

  // ─ Kaydet Butonu ──────────────────────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
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
    );
  }

  // ─ Form Alan Yardımcısı ───────────────────────────────────────────────────
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
            ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        validator: (val) {
          if (required && (val == null || val.trim().isEmpty)) {
            return '$label alanı boş bırakılamaz';
          }
          if (numeric && val != null && val.trim().isNotEmpty) {
            final normalized = val.trim().replaceAll(',', '.');
            if (double.tryParse(normalized) == null) {
              return 'Lütfen geçerli bir sayı girin (ör. 30 veya 3.5)';
            }
            if (double.parse(normalized) < 0) {
              return 'Değer sıfırdan küçük olamaz';
            }
          }
          return null;
        },
      ),
    );
  }
}

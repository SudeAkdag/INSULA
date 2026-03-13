import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insula/data/models/index.dart';

/// Beslenme modülünün MVVM ViewModel katmanı.
/// Firestore ile iletişim kurar, state yönetimini sağlar.
class NutritionViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── State ───────────────────────────────────────────────────────────────
  DateTime _selectedDate = DateTime.now();
  List<Meal> _meals = [];
  int _carbGoal = 200;
  bool _isLoading = false;
  String? _errorMessage;

  // Favoriler & son Seçilenler
  List<FoodItem> _favoriteFoods = [];
  List<FoodItem> _frequentFoods = [];
  List<FoodItem> _userFoods = []; // foodStats'tan gelen tüm kayıtlı besinler
  bool _isFavoritesLoading = false;

  // ─── Getters ─────────────────────────────────────────────────────────────
  DateTime get selectedDate => _selectedDate;
  List<Meal> get meals => _meals;
  int get carbGoal => _carbGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FoodItem> get favoriteFoods => _favoriteFoods;
  List<FoodItem> get frequentFoods => _frequentFoods;
  List<FoodItem> get userFoods => _userFoods;
  bool get isFavoritesLoading => _isFavoritesLoading;

  // Günlük toplam hesaplamaları (ViewModel seviyesinde computed getter'lar)
  double get totalCarbs => _meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double get totalCalories =>
      _meals.fold(0.0, (sum, meal) => sum + meal.totalCalories);
  double get totalProtein =>
      _meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get totalFat => _meals.fold(0, (sum, meal) => sum + meal.totalFat);
  double get totalSugar => _meals.fold(0, (sum, meal) => sum + meal.totalSugar);
  double get totalFiber => _meals.fold(0, (sum, meal) => sum + meal.totalFiber);

  // ─── Kullanıcı UID'si ─────────────────────────────────────────────────────
  String? get _uid => _auth.currentUser?.uid;

  // ─── Tarih → Firestore anahtarı ──────────────────────────────────────────
  String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  // ─── Tarih Değiştirme ─────────────────────────────────────────────────────
  void changeDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadMeals(date);
  }

  // ─── Öğünleri Yükleme ────────────────────────────────────────────────────
  Future<void> loadMeals(DateTime date) async {
    if (_uid == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Karbonhidrat hedefini kullanıcı dokümanından çek
      final userDoc = await _firestore.collection('users').doc(_uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        _carbGoal = (userDoc.data()!['dailyCarbGoal'] as num?)?.toInt() ?? 200;
      }

      // Öğün girdilerini Firestore'dan çek
      final dateKey = _dateKey(date);
      final snapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('meals')
          .doc(dateKey)
          .collection('mealEntries')
          .orderBy('addedAt')
          .get();

      // Öğün tiplerini sabit sırayla tanımla
      const mealTypes = [
        'Kahvaltı',
        'Öğle Yemeği',
        'Akşam Yemeği',
        'Ara Öğünler',
      ];

      // Belgeleri öğün tiplerine göre grupla
      final Map<String, List<FoodItem>> grouped = {
        for (var t in mealTypes) t: [],
      };

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final mealType = data['mealType'] as String? ?? 'Ara Öğünler';
        final item = FoodItem.fromMap(data, id: doc.id);
        grouped[mealType]?.add(item);
      }

      _meals = mealTypes
          .map((type) => Meal(type: type, items: grouped[type] ?? []))
          .toList();
    } catch (e) {
      _errorMessage = 'Veriler yüklenemedi: $e';
      debugPrint('NutritionViewModel.loadMeals hata: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Besin Ekleme ─────────────────────────────────────────────────────────
  Future<void> addFoodToMeal(
    String mealType,
    FoodItem item,
    DateTime date,
  ) async {
    if (_uid == null) return;

    try {
      final dateKey = _dateKey(date);
      // Firestore'a kaydet
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('meals')
          .doc(dateKey)
          .collection('mealEntries')
          .add(item.toMap(mealType));

      // Kullanım istatistiğini artır (arka planda, sonucu bekleme)
      _incrementFoodStat(item);

      // Local state'i güncelle (UI'ı anında yansıt)
      await loadMeals(date);
    } catch (e) {
      _errorMessage = 'Besin eklenemedi: $e';
      debugPrint('NutritionViewModel.addFoodToMeal hata: $e');
      notifyListeners();
    }
  }

  // ─── Besin Silme ──────────────────────────────────────────────────────────
  Future<void> removeFoodFromMeal(
    String mealType,
    String itemId,
    DateTime date,
  ) async {
    if (_uid == null) return;

    try {
      final dateKey = _dateKey(date);
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('meals')
          .doc(dateKey)
          .collection('mealEntries')
          .doc(itemId)
          .delete();

      // Local state'i güncelle
      await loadMeals(date);
    } catch (e) {
      _errorMessage = 'Besin silinemedi: $e';
      debugPrint('NutritionViewModel.removeFoodFromMeal hata: $e');
      notifyListeners();
    }
  }

  // ─── Karbonhidrat Hedefi Güncelleme ───────────────────────────────────────
  Future<void> updateCarbGoal(int newGoal) async {
    if (_uid == null) return;

    final previousGoal = _carbGoal;
    _carbGoal = newGoal;
    notifyListeners();

    try {
      await _firestore.collection('users').doc(_uid).set(
        {'dailyCarbGoal': newGoal},
        SetOptions(merge: true),
      );
    } catch (e) {
      // Hata durumunda önceki değere geri dön
      _carbGoal = previousGoal;
      _errorMessage = 'Hedef güncellenemedi: $e';
      debugPrint('NutritionViewModel.updateCarbGoal hata: $e');
      notifyListeners();
    }
  }

  // ─── Favoriler & son Seçilenler ───────────────────────────────────────────

  /// Favorileri ve son seçilenleri Firestore'dan yükler.
  /// AddFoodScreen açıldığında çağrılır.
  Future<void> loadFavoritesAndFrequent() async {
    if (_uid == null) return;

    _isFavoritesLoading = true;
    notifyListeners();

    try {
      // Favorileri çek
      final favSnap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('favoriteFoods')
          .get();

      _favoriteFoods = favSnap.docs
          .map((doc) => FoodItem.fromMap(doc.data(), id: doc.id))
          .toList();

      // Son seçilenleri useCount'a göre azalan sırada çek (ilk 8)
      final statsSnap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('foodStats')
          .orderBy('useCount', descending: true)
          .limit(3)
          .get();

      _frequentFoods = statsSnap.docs
          .map((doc) => FoodItem.fromMap(doc.data(), id: doc.id))
          .toList();

      // Kullanıcının tüm kayıtlı besinlerini çek (arama için)
      final allStatsSnap = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('foodStats')
          .get();

      _userFoods = allStatsSnap.docs
          .map((doc) => FoodItem.fromMap(doc.data(), id: doc.id))
          .toList();
    } catch (e) {
      debugPrint('NutritionViewModel.loadFavoritesAndFrequent hata: $e');
    } finally {
      _isFavoritesLoading = false;
      notifyListeners();
    }
  }

  /// Bir besini favorilere ekler veya çıkarır (toggle).
  /// Optimistic update: önce local state güncellenir, sonra Firestore'a yazılır.
  Future<void> toggleFavorite(FoodItem item) async {
    if (_uid == null) return;

    final docId = item.name.toLowerCase().replaceAll(' ', '_');
    final ref = _firestore
        .collection('users')
        .doc(_uid)
        .collection('favoriteFoods')
        .doc(docId);

    if (isFavorite(item)) {
      // Optimistic: önce local'dan kaldır
      _favoriteFoods.removeWhere(
        (f) => f.name.toLowerCase() == item.name.toLowerCase(),
      );
      notifyListeners();
      // Sonra Firestore'dan sil
      try {
        await ref.delete();
      } catch (e) {
        // Hata durumunda geri ekle
        _favoriteFoods.add(item);
        debugPrint('NutritionViewModel.toggleFavorite (sil) hata: $e');
        notifyListeners();
      }
    } else {
      // Optimistic: önce local'a ekle
      _favoriteFoods.add(item);
      notifyListeners();
      // Sonra Firestore'a yaz
      try {
        final data = item.toMap('favorite');
        data.remove('mealType');
        data['addedAt'] = FieldValue.serverTimestamp();
        await ref.set(data);
      } catch (e) {
        // Hata durumunda geri kaldır
        _favoriteFoods.removeWhere(
          (f) => f.name.toLowerCase() == item.name.toLowerCase(),
        );
        debugPrint('NutritionViewModel.toggleFavorite (ekle) hata: $e');
        notifyListeners();
      }
    }
  }

  /// Belirtilen besinin favorilerde olup olmadığını kontrol eder.
  bool isFavorite(FoodItem item) {
    return _favoriteFoods.any(
      (f) => f.name.toLowerCase() == item.name.toLowerCase(),
    );
  }

  /// Besin eklenince foodStats koleksiyonundaki useCount'u artırır.
  /// addFoodToMeal içinde otomatik çağrılır.
  Future<void> _incrementFoodStat(FoodItem item) async {
    if (_uid == null) return;
    try {
      final docId = item.name.toLowerCase().replaceAll(' ', '_');
      final ref = _firestore
          .collection('users')
          .doc(_uid)
          .collection('foodStats')
          .doc(docId);
      await ref.set(
        {
          'name': item.name,
          'portion': item.portion,
          'calories': item.calories,
          'carbs': item.carbs,
          'protein': item.protein,
          'fat': item.fat,
          'sugar': item.sugar,
          'fiber': item.fiber,
          'useCount': FieldValue.increment(1),
          'lastUsed': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('NutritionViewModel._incrementFoodStat hata: $e');
    }
  }

  // ─── İlk Yükleme ──────────────────────────────────────────────────────────
  NutritionViewModel() {
    loadMeals(_selectedDate);
  }
}

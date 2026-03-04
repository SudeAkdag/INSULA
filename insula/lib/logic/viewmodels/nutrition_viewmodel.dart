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

  // ─── Getters ─────────────────────────────────────────────────────────────
  DateTime get selectedDate => _selectedDate;
  List<Meal> get meals => _meals;
  int get carbGoal => _carbGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  // ─── İlk Yükleme ──────────────────────────────────────────────────────────
  NutritionViewModel() {
    loadMeals(_selectedDate);
  }
}

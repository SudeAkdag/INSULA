import 'package:cloud_firestore/cloud_firestore.dart';

/// Tek bir besin öğesini temsil eder.
class FoodItem {
  final String? id; // Firestore doküman ID'si (silme işlemi için)
  final String name; // Örn: "Yulaf Ezmesi"
  final String portion; // Örn: "1 kase"
  final int calories; // Örn: 220
  final double carbs; // Karbonhidrat (g)
  final double protein; // Protein (g)
  final double fat; // Yağ (g)
  final double sugar; // Şeker (g)
  final double fiber; // Lif (g)

  FoodItem({
    this.id,
    required this.name,
    required this.portion,
    required this.calories,
    required this.carbs,
    this.protein = 0.0,
    this.fat = 0.0,
    this.sugar = 0.0,
    this.fiber = 0.0,
  });

  /// Firestore'a yazmak için Map'e dönüştürür.
  Map<String, dynamic> toMap(String mealType) {
    return {
      'mealType': mealType,
      'name': name,
      'portion': portion,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'sugar': sugar,
      'fiber': fiber,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Firestore dokümanından FoodItem oluşturur.
  factory FoodItem.fromMap(Map<String, dynamic> map, {String? id}) {
    return FoodItem(
      id: id,
      name: map['name'] as String? ?? '',
      portion: map['portion'] as String? ?? '',
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      carbs: (map['carbs'] as num?)?.toDouble() ?? 0.0,
      protein: (map['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (map['fat'] as num?)?.toDouble() ?? 0.0,
      sugar: (map['sugar'] as num?)?.toDouble() ?? 0.0,
      fiber: (map['fiber'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Bir öğünü (Kahvaltı, Öğle, Akşam, Ara Öğün) temsil eder.
class Meal {
  final String type; // Kahvaltı, Öğle Yemeği, Akşam Yemeği, Ara Öğünler
  final String? time; // Örn: "08:30"
  final List<FoodItem> items;

  Meal({required this.type, this.time, required this.items});

  // Toplam besin değeri getter'ları
  double get totalCarbs => items.fold(0, (sum, item) => sum + item.carbs);
  double get totalSugar => items.fold(0, (sum, item) => sum + item.sugar);
  double get totalFiber => items.fold(0, (sum, item) => sum + item.fiber);
  double get totalProtein => items.fold(0, (sum, item) => sum + item.protein);
  double get totalFat => items.fold(0, (sum, item) => sum + item.fat);
  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
}

class FoodItem {
  final String name;      // Örn: "Yulaf Ezmesi"
  final String portion;   // Örn: "1 kase"
  final int calories;     // Örn: 220
  final double carbs;     // Örn: 30.0
  final double sugar;     // Yeni: Şeker miktarı (g)
  final double fiber;     // Yeni: Lif miktarı (g)

  FoodItem({
    required this.name, 
    required this.portion, 
    required this.calories, 
    required this.carbs,
    this.sugar = 0.0,
    this.fiber = 0.0,
  });
}

class Meal {
  final String type;      // Kahvaltı, Öğle, Akşam, Ara Öğün
  final String? time;     // Örn: "08:30"
  final List<FoodItem> items;

  Meal({required this.type, this.time, required this.items});

  // Toplam hesaplamaları artık Lif ve Şeker'i de kapsıyor
  double get totalCarbs => items.fold(0, (sum, item) => sum + item.carbs);
  double get totalSugar => items.fold(0, (sum, item) => sum + item.sugar);
  double get totalFiber => items.fold(0, (sum, item) => sum + item.fiber);
  int get totalCalories => items.fold(0, (sum, item) => sum + item.calories);
}
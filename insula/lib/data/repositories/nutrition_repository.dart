import 'package:insula/data/models/index.dart';

class NutritionRepository {
  /// Tasarımdaki günlük öğün listesini getirir.
  /// Future kullanımı, ileride gerçek bir API veya veritabanına 
  /// geçildiğinde kodun bozulmamasını sağlar.
  Future<List<Meal>> getDailyMeals() async {
    // İnternet veya veritabanı gecikmesini simüle etmek için 500ms bekleme ekliyoruz.
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      // KAHVALTI VERİSİ
      Meal(
        type: "Kahvaltı", 
        time: "08:30", 
        items: [
          FoodItem(
            name: "Yulaf Ezmesi (Sütlü)", 
            portion: "1 kase", 
            calories: 220, 
            carbs: 30.0, 
            sugar: 5.0,
            fiber: 8.0,
          ),
          FoodItem(
            name: "Yeşil Elma", 
            portion: "1 orta boy", 
            calories: 52, 
            carbs: 15.0, 
            sugar: 10.0,
            fiber: 4.0,
          ),
        ],
      ),
      
      // ÖĞLE YEMEĞİ VERİSİ
      Meal(
        type: "Öğle Yemeği", 
        time: "13:15", 
        items: [
          FoodItem(
            name: "Izgara Tavuk Göğsü", 
            portion: "200g", 
            calories: 330, 
            carbs: 0.0, 
            sugar: 0.0,
            fiber: 0.0,
          ),
          FoodItem(
            name: "Bulgur Pilavı", 
            portion: "1 porsiyon", 
            calories: 180, 
            carbs: 45.0, 
            sugar: 1.0,
            fiber: 6.0,
          ),
          FoodItem(
            name: "Yoğurt", 
            portion: "1 kase", 
            calories: 110, 
            carbs: 20.0, 
            sugar: 8.0,
            fiber: 0.0,
          ),
        ],
      ),
      // YENİ: Akşam Yemeği (Henüz girilmedi)
      Meal(type: "Akşam Yemeği", items: []),
  
      // YENİ: Ara Öğünler (Henüz girilmedi)
      Meal(type: "Ara Öğünler", items: []),
    ];
  }

  /// Yeni bir öğün veya besin eklemek için kullanılan fonksiyon iskeleti.
  Future<void> addFoodItem(String mealType, FoodItem item) async {
    // Burada ileride veritabanı (SQLite/Firebase) kodları olacak.
    print("${item.name} $mealType öğününe eklendi.");
  }
}
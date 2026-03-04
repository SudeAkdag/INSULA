import 'package:insula/data/models/index.dart';

/// Beslenme modülünün veri katmanı.
/// Firestore CRUD işlemleri NutritionViewModel'de yönetilir.
/// Bu sınıf yalnızca harici API entegrasyonu gibi ek veri kaynağı
/// işlemlerini barındırmak için kullanılır.
class NutritionRepository {
  /// Besin araması yapar.
  ///
  /// Bu metod ileride Open Food Facts API'sine
  /// (https://world.openfoodfacts.org/cgi/search.pl) bağlanacak.
  /// [query] parametresi ile ürün adı veya barkod ile arama yapılacak,
  /// dönen JSON yanıtı parse edilerek [FoodItem] listesi elde edilecek.
  /// Örnek endpoint:
  /// GET https://world.openfoodfacts.org/cgi/search.pl?search_terms={query}&search_simple=1&action=process&json=1
  /// Yanıttaki her ürün için: product_name, nutriments.carbohydrates_100g,
  /// nutriments.proteins_100g, nutriments.fat_100g, nutriments.sugars_100g,
  /// nutriments.fiber_100g, nutriments.energy-kcal_100g alanları kullanılacak.
  Future<List<FoodItem>> searchFood(String query) async {
    // TODO: Gerçek API entegrasyonu burada yapılacak
    // Şimdilik boş liste döndürülüyor; bu beklenen bir durumdur.
    return [];
  }
}

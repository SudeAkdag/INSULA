import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insula/data/local/turkish_foods_data.dart';
import 'package:insula/data/models/index.dart';

/// USDA FoodData Central API ile besin arama yapar.
/// 3 katmanlı arama: yerel Türk besinleri → kullanıcı kendi besinleri → USDA API.
class NutritionRepository {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = '1JriVZxocLV6445wwSLLyVhZpYDJe7peugsKb4Iu';
  static const Duration _timeout = Duration(seconds: 10);

  // ─── Nutrient ID Sabitleri ─────────────────────────────────────────────────
  static const int _nutrientCalories = 1008;
  static const int _nutrientCarbs = 1005;
  static const int _nutrientProtein = 1003;
  static const int _nutrientFat = 1004;
  static const int _nutrientSugar = 2000;
  static const int _nutrientFiber = 1079;

  // ─── Yardımcı: Nutrient Değeri Çek ───────────────────────────────────────

  double _getNutrientValue(List<dynamic> nutrients, int nutrientId) {
    for (final n in nutrients) {
      if ((n['nutrientId'] as num?)?.toInt() == nutrientId) {
        return (n['value'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return 0.0;
  }

  // ─── USDA API Arama ───────────────────────────────────────────────────────

  Future<List<FoodItem>> _searchUSDA(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/foods/search').replace(
        queryParameters: {
          'query': trimmed,
          'api_key': _apiKey,
          'pageSize': '10',
          'dataType': 'Foundation,SR Legacy',
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint('NutritionRepository.searchUSDA – HTTP ${response.statusCode}');
        return [];
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> foods = body['foods'] as List<dynamic>? ?? [];

      final List<FoodItem> results = [];
      for (final raw in foods) {
        final food = raw as Map<String, dynamic>;
        final name = (food['description'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;

        final nutrients = food['foodNutrients'] as List<dynamic>? ?? [];

        final calories = _getNutrientValue(nutrients, _nutrientCalories);
        final carbs = _getNutrientValue(nutrients, _nutrientCarbs);
        final protein = _getNutrientValue(nutrients, _nutrientProtein);
        final fat = _getNutrientValue(nutrients, _nutrientFat);
        final sugar = _getNutrientValue(nutrients, _nutrientSugar);
        final fiber = _getNutrientValue(nutrients, _nutrientFiber);

        // Kalori veya karbonhidrat değeri yoksa listeye ekleme
        if (calories == 0.0 && carbs == 0.0) continue;

        results.add(FoodItem(
          name: name,
          portion: '100g',
          calories: calories.round(),
          carbs: carbs,
          protein: protein,
          fat: fat,
          sugar: sugar,
          fiber: fiber,
        ));
      }

      return results;
    } on TimeoutException {
      debugPrint('NutritionRepository.searchUSDA – zaman aşımı');
      return [];
    } catch (e) {
      debugPrint('NutritionRepository.searchUSDA hata: $e');
      return [];
    }
  }

  // ─── 3 Katmanlı Arama ────────────────────────────────────────────────────

  /// Üç katmanlı besin arama:
  ///   1. Yerel Türk besinleri (anında, offline)
  ///   2. Kullanıcının kendi besinleri – foodStats (anında, parametre olarak gelir)
  ///   3. USDA FoodData Central API (arka planda)
  ///
  /// Aynı isimli tekrarlı sonuçlar filtrelenir (büyük/küçük harf duyarsız).
  Future<List<FoodItem>> searchFoodLayered(
    String query, {
    List<FoodItem> userFoods = const [],
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Katman 1: Yerel Türk besinleri (senkron, anında)
    final localResults = TurkishFoodsData.search(trimmed);

    // Katman 2: Kullanıcının kendi besinleri (parametre olarak gelir)
    final normalizedQuery = trimmed.toLowerCase();
    final userResults = userFoods.where((food) {
      return food.name.toLowerCase().contains(normalizedQuery);
    }).toList();

    // Katman 3: USDA API (arka planda)
    final apiResults = await _searchUSDA(trimmed);

    // Tekrar eden isimleri filtrele ve birleştir
    // Sıralama: yerel → kullanıcı → API
    final seen = <String>{};
    final combined = <FoodItem>[];

    for (final item in [...localResults, ...userResults, ...apiResults]) {
      final key = item.name.toLowerCase().trim();
      if (!seen.contains(key)) {
        seen.add(key);
        combined.add(item);
      }
    }

    return combined;
  }

  // ─── Geriye Dönük Uyumluluk ──────────────────────────────────────────────

  /// [searchFoodLayered] ile aynı davranış.
  /// Eski kod `searchFood` çağırıyorsa hata vermemesi için korundu.
  Future<List<FoodItem>> searchFood(
    String query, {
    List<FoodItem> userFoods = const [],
  }) async {
    return searchFoodLayered(query, userFoods: userFoods);
  }
}

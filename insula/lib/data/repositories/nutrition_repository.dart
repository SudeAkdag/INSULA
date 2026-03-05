import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insula/data/models/index.dart';

/// Open Food Facts API ile besin arama ve barkod sorgusu yapar.
class NutritionRepository {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  static const Duration _timeout = Duration(seconds: 10);

  /// Open Food Facts üzerinden metin araması yapar.
  /// GET /cgi/search.pl?search_terms={query}&...
  /// Hata durumunda boş liste döner; exception fırlatmaz.
  Future<List<FoodItem>> searchFood(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final uri = Uri.parse('$_baseUrl/cgi/search.pl').replace(
        queryParameters: {
          'search_terms': trimmed,
          'search_simple': '1',
          'action': 'process',
          'json': '1',
          'page_size': '20',
          'fields': 'product_name,nutriments,serving_size,quantity',
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint(
          'NutritionRepository.searchFood – HTTP ${response.statusCode}',
        );
        return [];
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final List<dynamic> products = body['products'] as List<dynamic>? ?? [];

      final List<FoodItem> results = [];
      for (final raw in products) {
        final product = raw as Map<String, dynamic>;

        // product_name boş veya null olan ürünleri atla
        final name = (product['product_name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;

        final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

        // Kalori: energy-kcal_100g yoksa energy_100g / 4.184 kullan
        final double calories;
        if (nutriments.containsKey('energy-kcal_100g')) {
          calories =
              (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 0.0;
        } else {
          final energyKj =
              (nutriments['energy_100g'] as num?)?.toDouble() ?? 0.0;
          calories = energyKj / 4.184;
        }

        results.add(FoodItem(
          name: name,
          portion: '100g',
          calories: calories.round(),
          carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
          protein: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0.0,
          fat: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0.0,
          sugar: (nutriments['sugars_100g'] as num?)?.toDouble() ?? 0.0,
          fiber: (nutriments['fiber_100g'] as num?)?.toDouble() ?? 0.0,
        ));
      }

      return results;
    } on TimeoutException {
      debugPrint('NutritionRepository.searchFood – zaman aşımı');
      return [];
    } catch (e) {
      debugPrint('NutritionRepository.searchFood hata: $e');
      return [];
    }
  }

  /// Barkod ile tek ürün sorgular.
  /// GET /api/v0/product/{barcode}.json
  /// Ürün bulunamazsa veya hata oluşursa null döner.
  Future<FoodItem?> getProductByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return null;

    try {
      final uri = Uri.parse(
        '$_baseUrl/api/v0/product/$trimmed.json',
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        debugPrint(
          'NutritionRepository.getProductByBarcode – HTTP ${response.statusCode}',
        );
        return null;
      }

      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      // status 0 = ürün bulunamadı
      if ((body['status'] as num?)?.toInt() != 1) return null;

      final product = body['product'] as Map<String, dynamic>? ?? {};
      final name = (product['product_name'] as String?)?.trim() ?? '';
      if (name.isEmpty) return null;

      final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

      final double calories;
      if (nutriments.containsKey('energy-kcal_100g')) {
        calories = (nutriments['energy-kcal_100g'] as num?)?.toDouble() ?? 0.0;
      } else {
        final energyKj = (nutriments['energy_100g'] as num?)?.toDouble() ?? 0.0;
        calories = energyKj / 4.184;
      }

      return FoodItem(
        name: name,
        portion: '100g',
        calories: calories.round(),
        carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
        protein: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0.0,
        fat: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0.0,
        sugar: (nutriments['sugars_100g'] as num?)?.toDouble() ?? 0.0,
        fiber: (nutriments['fiber_100g'] as num?)?.toDouble() ?? 0.0,
      );
    } on TimeoutException {
      debugPrint('NutritionRepository.getProductByBarcode – zaman aşımı');
      return null;
    } catch (e) {
      debugPrint('NutritionRepository.getProductByBarcode hata: $e');
      return null;
    }
  }
}

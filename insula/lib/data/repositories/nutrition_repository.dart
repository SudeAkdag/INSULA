import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:insula/data/local/turkish_foods_data.dart';
import 'package:insula/data/models/index.dart';

/// Open Food Facts API ile besin arama ve barkod sorgusu yapar.
/// 3 katmanlı arama: yerel Türk besinleri → TR API → global fallback.
class NutritionRepository {
  static const String _baseUrl = 'https://world.openfoodfacts.org';
  static const Duration _timeout = Duration(seconds: 10);

  // ─── Relevance Score ───────────────────────────────────────────────────────

  /// Bir API ürününün sorguyla ne kadar alakalı olduğunu puanlar.
  /// Yüksek puan → daha alakalı.
  int _calculateRelevanceScore(Map<String, dynamic> product, String query) {
    int score = 0;
    final String productName =
        (product['product_name'] ?? '').toString().toLowerCase();
    final String queryLower = query.toLowerCase().trim();

    // Türkiye etiketi → büyük bonus
    final List countriesTags = product['countries_tags'] ?? [];
    if (countriesTags.contains('en:turkey')) score += 50;

    // Türkçe karakter içeren ürün adı → TR ürünü olabilir
    if (RegExp(r'[ğşıçöüĞŞİÇÖÜ]').hasMatch(productName)) score += 20;

    // Arama terimiyle tam eşleşme
    if (productName == queryLower) {
      score += 30;
    } else if (productName.startsWith(queryLower)) {
      score += 15;
    }

    // Türkçe ürün adı mevcutsa
    final String productNameTr = (product['product_name_tr'] ?? '').toString();
    if (productNameTr.isNotEmpty) score += 15;

    // Besin değerleri eksiksizlik kontrolü
    final nutriments = product['nutriments'] ?? {};
    final double? kcal = (nutriments['energy-kcal_100g'] as num?)?.toDouble();
    final double? carbs =
        (nutriments['carbohydrates_100g'] as num?)?.toDouble();
    final double? protein = (nutriments['proteins_100g'] as num?)?.toDouble();
    final double? fat = (nutriments['fat_100g'] as num?)?.toDouble();

    if (kcal == null || carbs == null) {
      score -= 30; // Kalori veya karb eksikse büyük ceza
    } else if (protein != null && fat != null) {
      score += 10; // Tüm besin değerleri doluysa bonus
    }

    return score;
  }

  // ─── Tek API Çağrısı (TR öncelikli) ──────────────────────────────────────

  /// Open Food Facts üzerinden metin araması yapar (cc=tr&lc=tr).
  /// Sonuçları relevance score'a göre sıralar.
  /// Hata durumunda boş liste döner; exception fırlatmaz.
  Future<List<FoodItem>> searchFood(String query) async {
    return _searchWithParams(query, trOnly: true);
  }

  /// Sadece global arama (cc/lc parametresi olmadan).
  Future<List<FoodItem>> _searchGlobal(String query) async {
    return _searchWithParams(query, trOnly: false);
  }

  /// API isteği yapar, relevance score hesaplar ve sıralar.
  Future<List<FoodItem>> _searchWithParams(
    String query, {
    required bool trOnly,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    try {
      final Map<String, String> params = {
        'search_terms': trimmed,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '10',
        'fields': 'product_name,product_name_tr,nutriments,countries_tags',
      };
      if (trOnly) {
        params['cc'] = 'tr';
        params['lc'] = 'tr';
      }

      final uri = Uri.parse('$_baseUrl/cgi/search.pl').replace(
        queryParameters: params,
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

      // (product, score) tuple listesi oluştur
      final scored = <MapEntry<Map<String, dynamic>, int>>[];
      for (final raw in products) {
        final product = raw as Map<String, dynamic>;
        final name = (product['product_name'] as String?)?.trim() ?? '';
        if (name.isEmpty) continue;
        final score = _calculateRelevanceScore(product, trimmed);
        scored.add(MapEntry(product, score));
      }

      // Score'a göre azalan sırada sırala
      scored.sort((a, b) => b.value.compareTo(a.value));

      // FoodItem'lara dönüştür
      final List<FoodItem> results = [];
      for (final entry in scored) {
        final product = entry.key;
        final name = (product['product_name'] as String?)?.trim() ?? '';
        final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

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

  // ─── 3 Katmanlı Arama ─────────────────────────────────────────────────────

  /// Üç katmanlı besin arama:
  ///   1. Yerel Türk besinleri (anında, offline)
  ///   2. Open Food Facts TR API (cc=tr&lc=tr)
  ///   3. Global fallback (TR sonucu 3'ten azsa)
  ///
  /// Aynı isimli tekrarlı sonuçlar filtrelenir (büyük/küçük harf duyarsız).
  Future<List<FoodItem>> searchFoodLayered(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    // Katman 1: Yerel Türk besinleri (senkron)
    final localResults = TurkishFoodsData.search(trimmed);

    // Katman 2: TR öncelikli API
    final trResults = await searchFood(trimmed);

    // Katman 3: Global fallback (TR sonucu 3'ten azsa)
    List<FoodItem> globalResults = [];
    if (trResults.length < 3) {
      globalResults = await _searchGlobal(trimmed);
    }

    // Tekrar eden isimleri filtrele ve birleştir
    final seen = <String>{};
    final combined = <FoodItem>[];

    for (final item in [...localResults, ...trResults, ...globalResults]) {
      final key = item.name.toLowerCase().trim();
      if (!seen.contains(key)) {
        seen.add(key);
        combined.add(item);
      }
    }

    return combined;
  }

  // ─── Barkod Sorgulama ─────────────────────────────────────────────────────

  /// Barkod ile tek ürün sorgular.
  /// GET /api/v0/product/{barcode}.json
  /// Ürün bulunamazsa veya hata oluşursa null döner.
  Future<FoodItem?> getProductByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl/api/v0/product/$trimmed.json');

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

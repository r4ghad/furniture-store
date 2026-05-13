import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class CacheService {
  static const String _cacheKey = 'products_cache_json';

  // ✅ حفظ المنتجات كـ JSON في SharedPreferences (يعمل على Web + Mobile)
  static Future<void> saveProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList); // تحويل إلى JSON String
      await prefs.setString(_cacheKey, jsonString);
      print('✅ Products cached as JSON: ${products.length} items');
    } catch (e) {
      print('Error saving products to cache: $e');
    }
  }

  // ✅ تحميل المنتجات من JSON المخزن في SharedPreferences
  static Future<List<Product>> loadProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cacheKey);

      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString); // قراءة JSON
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading products from cache: $e');
      return [];
    }
  }
}
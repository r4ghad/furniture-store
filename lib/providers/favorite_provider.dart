import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Product> _favorites = [];
  static const String _favoritesKey = 'favorites_cache_json';

  List<Product> get favorites => _favorites;
  int get favoriteCount => _favorites.length;

  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  // ✅ تحميل المفضلة من SharedPreferences عند بدء التطبيق
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('📂 لا توجد مفضلة محفوظة — قائمة فارغة');
        return;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);

      // ✅ استخدام fromFavoriteJson لأن المفضلة تحتوي على 4 حقول فقط
      _favorites = jsonList
          .map((json) => Product.fromFavoriteJson(json))
          .toList();

      notifyListeners();
      print('✅ تم تحميل ${_favorites.length} منتج من المفضلة المحفوظة');

    } catch (e) {
      print('❌ خطأ في تحميل المفضلة: $e');
      _favorites = [];
    }
  }

  // ✅ حفظ المفضلة في SharedPreferences — البيانات الضرورية فقط (4 حقول)
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ حفظ id, name, price, imageUrl فقط
      final jsonList = _favorites
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'price': p.price,
                'imageUrl': p.imageUrl,
              })
          .toList();

      final jsonString = jsonEncode(jsonList);
      await prefs.setString(_favoritesKey, jsonString);
      print('✅ تم حفظ ${_favorites.length} منتج في المفضلة المحفوظة');

    } catch (e) {
      print('❌ خطأ في حفظ المفضلة: $e');
    }
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
    _saveFavorites();
  }

  void removeFromFavorites(String productId) {
    _favorites.removeWhere((item) => item.id == productId);
    notifyListeners();
    _saveFavorites();
  }
}
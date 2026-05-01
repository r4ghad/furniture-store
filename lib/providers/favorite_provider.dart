import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Product> _favorites = [];

  List<Product> get favorites => _favorites;

  int get favoriteCount => _favorites.length;

  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favorites.removeWhere((item) => item.id == product.id);
    } else {
      _favorites.add(product);
    }
    notifyListeners();
  }

  void removeFromFavorites(String productId) {
    _favorites.removeWhere((item) => item.id == productId);
    notifyListeners();
  }
}
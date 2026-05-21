import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../services/favorites_service.dart';

class FavoriteProvider extends ChangeNotifier {
  List<Product> _favorites = [];
  bool _isLoading = false;
  StreamSubscription? _favoritesSubscription;

  List<Product> get favorites => _favorites;
  int get favoriteCount => _favorites.length;
  bool get isLoading => _isLoading;

  bool isFavorite(Product product) {
    return _favorites.any((item) => item.id == product.id);
  }

  // ✅ الاشتراك في المفضلة من Firestore باستخدام snapshots() (real-time updates)
  void subscribeToFavorites() {
    _favoritesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    // التحقق من تسجيل الدخول
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isLoading = false;
      _favorites = [];
      notifyListeners();
      return;
    }

    _favoritesSubscription = FavoritesService.getFavoritesStream().listen(
      (favorites) {
        _favorites = favorites;
        _isLoading = false;
        notifyListeners();
        print('✅ Favorites synced from Firestore: ${favorites.length}');
      },
      onError: (e) {
        print('❌ Firestore favorites error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ✅ إيقاف الاشتراك
  void unsubscribeFromFavorites() {
    _favoritesSubscription?.cancel();
    _favoritesSubscription = null;
  }

  // ✅ تحميل المفضلة عند بدء التطبيق (اختياري - يمكن استخدام subscribeToFavorites)
  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();

      final favorites = await FavoritesService.loadFavorites();
      _favorites = favorites;

      _isLoading = false;
      notifyListeners();
      print('✅ Loaded ${_favorites.length} favorites from Firestore');
    } catch (e) {
      print('❌ Error loading favorites: $e');
      _favorites = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ تبديل حالة المفضلة (إضافة/إزالة)
  // نستخدم عكس المنطق لأن الـ stream يحدث القائمة تلقائياً
  Future<void> toggleFavorite(Product product) async {
    // ✅ ننتظر لحظة للتأكد من حالة الـ stream
    await Future.delayed(const Duration(milliseconds: 100));

    final currentlyFavorite = isFavorite(product);

    if (currentlyFavorite) {
      // إذا كان في المفضلة: أزله
      await FavoritesService.removeFavorite(product.id);
    } else {
      // إذا لم يكن في المفضلة: أضفه
      await FavoritesService.addFavorite(product);
    }
    // لا حاجة لـ notifyListeners() لأن Firestore stream سيحدثها تلقائياً
  }

  // ✅ إزالة من المفضلة - الـ stream سيحدث القائمة تلقائياً
  Future<void> removeFromFavorites(String productId) async {
    await FavoritesService.removeFavorite(productId);
  }

  // ✅ تحديث بيانات منتج في المفضلة باستخدام update()
  Future<void> updateFavorite(Product product) async {
    if (isFavorite(product)) {
      await FavoritesService.updateFavorite(product);
      final index = _favorites.indexWhere((item) => item.id == product.id);
      if (index != -1) {
        _favorites[index] = product;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    unsubscribeFromFavorites();
    super.dispose();
  }
}

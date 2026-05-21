import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  bool _isOffline = false;
  StreamSubscription? _productsSubscription;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  // ✅ قراءة المنتجات من Firestore باستخدام snapshots() (real-time updates)
  void subscribeToProducts() {
    _productsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _productsSubscription = FirestoreService.getProductsStream().listen(
      (products) {
        _products = products;
        _isLoading = false;
        _isOffline = false;
        notifyListeners();
        print('✅ Products synced from Firestore: ${products.length}');
      },
      onError: (e) {
        print('❌ Firestore error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ✅ إيقاف الاشتراك
  void unsubscribeFromProducts() {
    _productsSubscription?.cancel();
    _productsSubscription = null;
  }

  // ✅ تحميل المنتجات (fallback: API ثم Cache)
  Future<void> fetchProducts({bool force = false}) async {
    if (_products.isNotEmpty && !force) return;

    _isLoading = true;
    notifyListeners();

    try {
      // جرب قراءة المنتجات من Firestore أولاً
      final snapshot = await FirestoreService.getProductsStream().first;
      if (snapshot.isNotEmpty) {
        _products = snapshot;
        _isOffline = false;
        print('✅ Products loaded from Firestore: ${_products.length}');
      } else {
        // إذا كانت Firestore فارغة، جرب API
        await _loadFromApi();
      }
    } catch (e) {
      print('❌ Firestore unavailable, trying API: $e');
      await _loadFromApi();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromApi() async {
    try {
      final products = await ApiService.fetchProducts();
      _products = products;
      _isOffline = false;

      // حفظ في Cache كنسخة احتياطية
      await CacheService.saveProducts(products);

      // حفظ في Firestore للاستخدام المستقبلي
      await FirestoreService.saveProducts(products);

      print(
        '✅ Products fetched from API and saved to Firestore: ${products.length}',
      );
    } catch (e) {
      print('❌ API Error: $e');
      // ✅ عند فشل الـ API — نعتمد على الكاش
      final cachedProducts = await CacheService.loadProducts();
      if (cachedProducts.isNotEmpty) {
        _products = cachedProducts;
        _isOffline = true;
        print(
          '📴 Offline mode — loaded ${cachedProducts.length} products from cache',
        );
      }
    }
  }

  // ✅ تحميل المنتجات من ملف JSON المحلي عند بدء التشغيل (للـ offline)
  Future<void> loadProductsFromCache() async {
    final cachedProducts = await CacheService.loadProducts();
    print('✅ Loading from cache, found: ${cachedProducts.length} products');

    if (cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _isOffline = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    unsubscribeFromProducts();
    super.dispose();
  }
}

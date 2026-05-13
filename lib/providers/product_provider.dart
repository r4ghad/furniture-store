import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false; // ✅ يبدأ بـ false — التحميل لم يبدأ بعد
  bool _isOffline = false;
  bool _hasLoaded = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;

  // تحميل المنتجات من API (مرة واحدة فقط)
  Future<void> fetchProducts({bool force = false}) async {
    // ✅ إذا تم التحميل مسبقاً — لا نعيد التحميل (الكاش كافٍ)
    if (_hasLoaded && !force) return;

    // ✅ لا نظهر شاشة التحميل إذا كان لدينا منتجات مسبقاً من الكاش
    if (_products.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final products = await ApiService.fetchProducts();
      _products = products;
      _isOffline = false; // تم الاتصال بنجاح
      await CacheService.saveProducts(products);
      print('✅ Products fetched from API and saved to cache: ${products.length}');
      _hasLoaded = true;
    } catch (e) {
      print('❌ API Error: $e');
      // ✅ عند فشل الـ API — نعتمد على الكاش ونظهر رسالة الأوفلاين
      final cachedProducts = await CacheService.loadProducts();
      if (cachedProducts.isNotEmpty) {
        _products = cachedProducts;
        _isOffline = true; // ✅ نظهر رسالة الأوفلاين هنا فقط لأن الـ API فشل
        _hasLoaded = true;
        print('📴 Offline mode — loaded ${cachedProducts.length} products from cache');
      } else {
        _products = [];
        _isOffline = true;
        print('❌ No cached products found');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ تحميل المنتجات من ملف JSON المحلي عند بدء التشغيل
  Future<void> loadProductsFromCache() async {
    final cachedProducts = await CacheService.loadProducts();
    print('✅ Loading from cache, found: ${cachedProducts.length} products');

    if (cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _isOffline = false;  // ✅ لا نظهر رسالة الأوفلاين حتى نتأكد من فشل الـ API
      _hasLoaded = false;  // ✅ نتركه false لكي يقوم fetchProducts بجلب الجديد من الإنترنت
      _isLoading = false;
      notifyListeners();
    }
  }
}
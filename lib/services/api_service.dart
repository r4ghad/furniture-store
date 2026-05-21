import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  // ✅ استخدام DummyJSON مع multiple categories للحصول على تنوع
  static const String baseUrl = 'https://dummyjson.com';

  static Future<List<Product>> fetchProducts() async {
    try {
      // جلب منتجات من تصنيفات متعددة
      final categories = [
        'furniture',
        'home-decoration',
        'kitchen-accessories',
      ];

      final List<Product> allProducts = [];

      for (final category in categories) {
        final response = await http
            .get(
              Uri.parse('$baseUrl/products/category/$category?limit=40'),
              headers: {'Accept': 'application/json'},
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                throw TimeoutException('Timeout for $category');
              },
            );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          final List<dynamic> data = jsonResponse['products'] ?? [];

          allProducts.addAll(
            data
                .map(
                  (json) =>
                      Product.fromJson(_convertToOurFormat(json, category)),
                )
                .toList(),
          );
        }
      }

      if (allProducts.isEmpty) {
        throw Exception('لم يتم تحميل أي منتجات');
      }

      return allProducts;
    } on TimeoutException catch (e) {
      throw Exception('Timeout: $e');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, dynamic> _convertToOurFormat(
    Map<String, dynamic> apiProduct,
    String category,
  ) {
    final String title = apiProduct['title']?.toString().toLowerCase() ?? '';
    final String apiCategory = category.toLowerCase();

    // توزيع التصنيفات بناءً على اسم المنتج والتصنيف الأصلي
    String categoryResult;
    if (title.contains('bed') ||
        title.contains('mattress') ||
        (apiCategory == 'furniture' && title.contains('chair'))) {
      categoryResult = 'Bedrooms';
    } else if (title.contains('chair') ||
        title.contains('sofa') ||
        title.contains('table') ||
        title.contains('lamp')) {
      categoryResult = 'Living Rooms';
    } else if (apiCategory == 'kitchen-accessories' ||
        title.contains('kitchen') ||
        title.contains('cooker') ||
        title.contains('pan') ||
        title.contains('pot')) {
      categoryResult = 'Kitchen';
    } else if (apiCategory == 'home-decoration' ||
        title.contains('plant') ||
        title.contains('mirror') ||
        title.contains('clock') ||
        title.contains('frame') ||
        title.contains('pillow')) {
      categoryResult = 'Home Decoration';
    } else {
      categoryResult = 'Living Rooms';
    }

    // الحصول على الصورة
    String imageUrl = '';
    if (apiProduct['images'] != null &&
        (apiProduct['images'] as List).isNotEmpty) {
      imageUrl = apiProduct['images'][0].toString();
    } else if (apiProduct['thumbnail'] != null) {
      imageUrl = apiProduct['thumbnail'].toString();
    }

    // حساب oldPrice من discountPercentage
    final double price = (apiProduct['price'] as num?)?.toDouble() ?? 0.0;
    final double? discountPercent = (apiProduct['discountPercentage'] as num?)
        ?.toDouble();
    final double? oldPrice = discountPercent != null
        ? price / (1 - discountPercent / 100)
        : null;

    return {
      'id': apiProduct['id'].toString(),
      'name': apiProduct['title'] ?? '',
      'category': categoryResult,
      'description': apiProduct['description'] ?? '',
      'price': price,
      'oldPrice': oldPrice,
      'imageUrl': imageUrl,
      'discountPercent': discountPercent?.toInt(),
      'timeLeft': null,
    };
  }
}

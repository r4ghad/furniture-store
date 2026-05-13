import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const String apiUrl = 'https://api.escuelajs.co/api/v1/products';

  static Future<List<Product>> fetchProducts() async {
    try {
      // ✅ Accept Header + Timeout 10 ثوانٍ
      final response = await http
          .get(
            Uri.parse(apiUrl),
            headers: {'Accept': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'انتهت مهلة الاتصال — لم يستجب الخادم خلال 10 ثوانٍ',
              );
            },
          );

      // ✅ معالجة أكواد HTTP المختلفة
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // فلترة المنتجات التي تحتوي على كلمات أثاث
        final furnitureProducts = data.where((product) {
          final title = product['title'].toLowerCase();
          final category = product['category']['name'].toLowerCase();

          return title.contains('sofa') ||
              title.contains('chair') ||
              title.contains('table') ||
              title.contains('bed') ||
              title.contains('lamp') ||
              title.contains('cabinet') ||
              title.contains('wardrobe') ||
              title.contains('desk') ||
              category.contains('furniture') ||
              category.contains('home');
        }).toList();

        // نأخذ أول 15 منتج أثاث
        final limitedData = furnitureProducts.take(15).toList();

        return limitedData
            .map((json) => Product.fromJson(_convertToOurFormat(json)))
            .toList();

      } else if (response.statusCode == 401) {
        throw Exception('غير مصرح بالوصول (401 Unauthorized)');

      } else if (response.statusCode == 404) {
        throw Exception('المسار غير موجود (404 Not Found)');

      } else if (response.statusCode == 500) {
        throw Exception('خطأ داخلي في الخادم (500 Internal Server Error)');

      } else {
        throw Exception(
          'فشل تحميل المنتجات — كود الخطأ: ${response.statusCode}',
        );
      }

    } on TimeoutException catch (e) {
      // ✅ معالجة Timeout بشكل منفصل
      throw Exception('Timeout: $e');

    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, dynamic> _convertToOurFormat(Map<String, dynamic> apiProduct) {
    final String title = apiProduct['title'].toLowerCase();
    final String apiCategory = apiProduct['category']['name'] ?? '';

    // توزيع التصنيفات
    String category;
    if (title.contains('bed') || title.contains('mattress') || apiCategory.contains('bedroom')) {
      category = 'Bedrooms';
    } else if (title.contains('dining') || title.contains('kitchen') || apiCategory.contains('kitchen')) {
      category = 'Kitchen';
    } else {
      category = 'Living Rooms';
    }

    // الحصول على أول صورة
    String imageUrl = '';
    if (apiProduct['images'] != null && apiProduct['images'].isNotEmpty) {
      imageUrl = apiProduct['images'][0];
    }

    return {
      'id': apiProduct['id'].toString(),
      'name': apiProduct['title'],
      'category': category,
      'description': apiProduct['description'] ?? '',
      'price': (apiProduct['price'] as num).toDouble(),
      'oldPrice': null,
      'imageUrl': imageUrl,
      'discountPercent': null,
      'timeLeft': null,
    };
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  // ✅ قراءة المنتجات من Firestore باستخدام snapshots() (real-time updates)
  static Stream<List<Product>> getProductsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();
    });
  }

  // ✅ قراءة منتج واحد
  static Future<Product?> getProduct(String productId) async {
    final doc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    if (doc.exists) {
      return Product.fromDoc(doc);
    }
    return null;
  }

  // ✅ حفظ منتج واحد
  static Future<void> saveProduct(Product product) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  }

  // ✅ حفظ عدة منتجات (للتهيئة الأولية)
  static Future<void> saveProducts(List<Product> products) async {
    final batch = FirebaseFirestore.instance.batch();
    
    for (final product in products) {
      final docRef = FirebaseFirestore.instance
          .collection('products')
          .doc(product.id);
      batch.set(docRef, product.toMap());
    }
    
    await batch.commit();
  }

  // ✅ حذف منتج
  static Future<void> deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .delete();
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class FavoritesService {
  static String? _getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // ✅ قراءة المفضلة من Firestore باستخدام snapshots() (real-time)
  static Stream<List<Product>> getFavoritesStream() {
    final userId = _getUserId();
    if (userId == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();
    });
  }

  // ✅ إضافة منتج للمفضلة باستخدام set()
  static Future<void> addFavorite(Product product) async {
    final userId = _getUserId();
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(product.id)
        .set(product.toMap());
  }

  // ✅ إزالة منتج من المفضلة
  static Future<void> removeFavorite(String productId) async {
    final userId = _getUserId();
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  // ✅ تحديث بيانات منتج في المفضلة باستخدام update()
  static Future<void> updateFavorite(Product product) async {
    final userId = _getUserId();
    if (userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(product.id)
        .update(product.toMap());
  }

  // ✅ التحقق إذا كان المنتج في المفضلة
  static Future<bool> isFavorite(String productId) async {
    final userId = _getUserId();
    if (userId == null) return false;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(productId)
        .get();
    
    return doc.exists;
  }

  // ✅ الحصول على كل المفضلة (للتحميل الأولي)
  static Future<List<Product>> loadFavorites() async {
    final userId = _getUserId();
    if (userId == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => Product.fromDoc(doc)).toList();
  }
}